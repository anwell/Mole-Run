display.setStatusBar (display.HiddenStatusBar)

--require
require("levelData")
local levels = levelData.levels
local ui = require("ui")
local widget = require "widget"
require ("sprite")
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
storyboard.lastLevel = #levels
local levelInfo = levelData.levelInfo

--constants
local STATE_IDLE = "Idle"
local STATE_WALKING = "Walking"
local DIRECTION_UP = 1
local DIRECTION_DOWN = 3
local DIRECTION_RIGHT = 0
local DIRECTION_LEFT = 2
local TILE_WIDTH = 26
local TIME_LIMIT = 45
local OFFSET = TILE_WIDTH / 2
local SPEED = 85
local SPEED_ENEMY = SPEED + 100
local SCORE_MULTIPLIER = 10
local gameState = false
local currentLevel = storyboard.currentLevel
local score = storyboard.score
local volume = storyboard.volume > 0

--images
local background = display.newImage ("images/background.png")
local playerSheet = sprite.newSpriteSheet("images/mole3.png", TILE_WIDTH, TILE_WIDTH)
local playerSet = sprite.newSpriteSet (playerSheet, 1, 21)
local player = sprite.newSprite(playerSet)
local key = display.newImage("images/key.png")
local doorSheet = sprite.newSpriteSheet("images/Door Sprite Sheet.png", TILE_WIDTH, TILE_WIDTH)
local doorSet = sprite.newSpriteSet (doorSheet, 1, 6)
local door = sprite.newSprite(doorSet)
local enemySheet = sprite.newSpriteSheet("images/Enemy Sprite Sheet.png", TILE_WIDTH, TILE_WIDTH)
local enemySet = sprite.newSpriteSet(enemySheet, 1, 4)
sprite.add (enemySet, "enemyleft", 1, 2, 100, 0)
sprite.add (enemySet, "enemyright", 4, 3, 100, 0)
local explosionSheet = sprite.newSpriteSheet("images/Explosion Sprite Sheet.png", TILE_WIDTH * 3, TILE_WIDTH * 3)
local explosionSet = sprite.newSpriteSet(explosionSheet, 1, 7)

--dpad
local up
local down
local left
local right

--header info
local timerText = TIME_LIMIT
local timeLeft = display.newText(timerText,240,0,native.systemFontBold,20)
local lives = display.newImage("images/Mole lives.png")
local suicideButton
local pauseButton
local scoreText = display.newText("Sc: "..score,300,0,"Courier",15)
local levelText = display.newText("Lv: "..currentLevel,100,0,"Courier",15)

--display groups
local dpadGroup = display.newGroup()
local headerGroup = display.newGroup()
local walls = display.newGroup()
local sands = display.newGroup()
local boulders = display.newGroup()
local bombs = display.newGroup()
local stones = display.newGroup()
local enemies = display.newGroup()

--sounds
local rewardSFX = media.newEventSound("sounds/reward.mp3")
local explosionSFX = media.newEventSound("sounds/explosion.wav")

--functions
local explodeBomb
local snapPlayerToGrid
local gravityObjects

--save info
local json = require 'json'
local saveData, loadData
local filePath = system.pathForFile( "levelInfoTable.json", system.DocumentsDirectory )

function saveData()
	file = io.open(filePath, "w")
	if file then
		contents = json.encode (levelInfo)
		file:write(contents)
		io.close(file)
	end
end

function loadData()	
	local file = io.open( filePath, "r" )
	local contents
	if file then
		contents = file:read("*a")
		--levelInfo = nil
		grid = json.decode(contents)
		--levelInfo = json.decode(contents)
		if #grid < #levelInfo then
			for i = #grid + 1, #levelInfo do
				grid[i] = levelInfo[i]
			end
		end
		levelInfo = grid
		io.close(file)
	end
end

--create objects
local function createPlayer()
	sprite.add (playerSet, "playerleft", 8, 2, 100, 0)
	sprite.add (playerSet, "playerright", 1, 2, 100, 0)
	sprite.add (playerSet, "playerdead", 15, 7, 100, 1)
	player.state = STATE_IDLE
	player.direction = DIRECTION_RIGHT
	player.lives = 3
	player:prepare("playerright")
end

local function createDoor()
	sprite.add (doorSet, "dooropen", 1, 6, 100, 1)
	door.name = "door"
	door.open = false
	door:prepare("dooropen")
end

local function createHeader()
	suicideButton = ui.newButton{
		default = "images/suicide button.png",
		over = "images/suicide button.png",
		onEvent = onSuicideButton
	}
	pauseButton = ui.newButton{
		default = "images/pause button.png",
		over = "images/pause button select.png",
		onEvent = onPauseButton
	}
	scoreText:setReferencePoint(display.TopRightReferencePoint)
	scoreText.x = 400
	scoreText.y = 0
	suicideButton.x = 429
	suicideButton.y = OFFSET
	pauseButton.x = 455
	pauseButton.y = OFFSET
	headerGroup:insert(suicideButton)
	headerGroup:insert(timeLeft)
	headerGroup:insert(lives)
	headerGroup:insert(pauseButton)
	headerGroup:insert(levelText)
	headerGroup:insert(scoreText)
end

--collisions


--clear game
local function clearGame()
	gameState = false
	player.x = -26
	key.x = -26
	dpadGroup.isVisible = false
	door.isVisible = false
	headerGroup.isVisible = false
	
	for i = 1, #walls do
		walls[i]:removeSelf()
	end
	walls = display.newGroup()
	for i = 1, #enemies do
		enemies[i]:removeSelf()
	end
	enemies = display.newGroup()
	for i = 1, #boulders do
		boulders[i]:removeSelf()
	end
	boulders = display.newGroup()
	for i = 1, #stones do
		stones[i]:removeSelf()
	end
	stones = display.newGroup()

	if #bombs > 0 then
		for i = 1, #bombs do
			bombs[i]:removeSelf()
		end
	end
	bombs = display.newGroup()

	if #sands > 0 then
		for i = 1, #sands do	
			sands[i]:removeSelf()
		end
	end
	sands = display.newGroup()
end

--reset the level if you still have lives left
local function resetLevel( event )
	clearGame()
	buildLevel(levels[currentLevel])
	dpadGroup.isVisible = true
	door.isVisible = true
	door.open = false
	door:prepare("dooropen")
	key.isVisible = true
	headerGroup.isVisible = true
	player:prepare("playerright")
	timer.resume(countdownTimer)
	player.alive = true
end

local function killPlayer()
	if player.alive == true then
		if volume then 
			media.playEventSound(explosionSFX)
		end
		player.state = STATE_IDLE
		player.alive = false
		dpadGroup.isVisible = false
		player.lives = player.lives - 1
		if player.lives > 0 then
			timer.pause(countdownTimer)
			timerText = TIME_LIMIT
			timeLeft.text = timerText
			player:prepare("playerdead")
			player:play()
			lives:removeSelf()
			if player.lives == 2 then
				lives = display.newImage("images/Mole lives 2.png")
				headerGroup:insert(lives)
			elseif player.lives == 1 then
				lives = display.newImage("images/Mole lives 1.png")
				headerGroup:insert(lives)
			end
			timer.performWithDelay( 1000, resetLevel )

		else
			lives:removeSelf()
			lives = display.newImage("images/Mole lives 0.png")
			headerGroup:insert(lives)
			player:prepare("playerdead")
			player:play()
			local function retry()
				storyboard.score = score
				Runtime:removeEventListener("enterFrame", gravityObjects)
				Runtime:removeEventListener("enterFrame", testCollisions)
				storyboard.currentLevel = currentLevel
				storyboard.gotoScene( "retry", "slideLeft", 800 )
			end
			timer.performWithDelay( 1000, retry )
		end
	end
end


local function snapPlayerToGrid()
	if player.direction == DIRECTION_RIGHT then
		player.j = player.j + 1
	elseif player.direction == DIRECTION_UP then
		player.i = player.i - 1
	elseif player.direction == DIRECTION_LEFT then
		player.j = player.j - 1
	elseif player.direction == DIRECTION_DOWN then
		player.i = player.i + 1
	end
end

--MOVING THE PLAYER
local function changeDirection(test)
	if hasCollidedRectangle(test, right) then
		if player.direction == DIRECTION_RIGHT then
			return
		else
			display.getCurrentStage():setFocus(right)
			player.direction = DIRECTION_RIGHT
			player:prepare("playerright")
		end
	elseif hasCollidedRectangle(test, up) then
		if player.direction == DIRECTION_UP then
			return
		else
			display.getCurrentStage():setFocus(up)
			player.direction = DIRECTION_UP
		end
	elseif hasCollidedRectangle(test, left) then
		if player.direction == DIRECTION_LEFT then
			return
		else
			player.direction = DIRECTION_LEFT
			display.getCurrentStage():setFocus(left)
			player:prepare("playerleft")
		end
	elseif hasCollidedRectangle(test, down) then
		if player.direction == DIRECTION_DOWN then
			return
		else
			player.direction = DIRECTION_DOWN
			display.getCurrentStage():setFocus(down)
		end
	end
	completeMoving()
end

local onButtonRightEvent = function(event)
	player.direction = DIRECTION_RIGHT
	player:prepare("playerright")
	if event.phase == "press" and canMove() then
		if canPushBoulder() and player.state == STATE_IDLE then
			--action = true
			player.state = STATE_WALKING
			player:play("playerright")
			-- transition.to(player, {time=SPEED, x=player.x+TILE_WIDTH, y=player.y})
			 player.j = player.j + 1
			-- timer1 = timer.performWithDelay(250, completeMoving)
			-- print("A")
			completeMoving()
			--action = false
			-- snapPlayerToGrid()
		end
	elseif event.phase == "moved" then
		local test = display.newRect( event.x, event.y, 0, 0 )
		changeDirection(test)
		test:removeSelf()
		--player.state = STATE_IDLE
	end
end

local onButtonUpEvent = function(event)
	player.direction = DIRECTION_UP	
	if event.phase == "press" and canMove() then
		if canPushBoulder() and player.state == STATE_IDLE then
			player.state = STATE_WALKING
			player:play()
			-- transition.to(player, {time=SPEED, x=player.x, y=player.y-TILE_WIDTH})
			-- timer1 = timer.performWithDelay(250, completeMoving)
			 player.i = player.i - 1
			-- snapPlayerToGrid()
			completeMoving()
		end
	elseif event.phase == "moved" then
		local test = display.newRect( event.x, event.y, 0, 0 )
		changeDirection(test)
		test:removeSelf()
	end
end

local onButtonLeftEvent = function(event)
	player.direction = DIRECTION_LEFT
	player:prepare("playerleft")
	if event.phase == "press" and canMove() then
		if canPushBoulder() and player.state == STATE_IDLE then
		player.state = STATE_WALKING
		player:play("playerleft")
		-- transition.to(player, {time=SPEED, x=player.x-TILE_WIDTH, y=player.y})
		-- timer1 = timer.performWithDelay(250, completeMoving)
		 player.j = player.j - 1
		-- 	-- snapPlayerToGrid()
		completeMoving()
		end
	elseif event.phase == "moved" then
		local test = display.newRect( event.x, event.y, 0, 0 )
		changeDirection(test)
		test:removeSelf()
		--player.state = STATE_IDLE
	end
end

local onButtonDownEvent = function(event)
		--timer.cancel(timer1)
		player.direction = DIRECTION_DOWN
	if event.phase == "press" and canMove() then
	if canPushBoulder() and player.state == STATE_IDLE then

		--print("a")
		 player.state = STATE_WALKING
		player:play()
		-- transition.to(player, {time=SPEED, x=player.x, y=player.y+TILE_WIDTH})
		-- timer.performWithDelay(250, completeMoving)
		 player.i = player.i + 1
		completeMoving()
			-- snapPlayerToGrid()
		end
	elseif event.phase == "moved" then
		local test = display.newRect( event.x, event.y, 0, 0 )
		changeDirection(test)
		test:removeSelf()
		--player.state = STATE_IDLE
	end
end
local action = true

completeMoving2 = function()
	action = true
	completeMoving()
end
completeMoving = function(obj)
	--timer.cancel(timer1)
	if player.state == STATE_WALKING and canMove() and action then

		if canPushBoulder() then
			action = false
			player:play()
			local nextPlayer = createPossibleObject(player, player.direction)
			
			transition.to(player, {time=SPEED, x=nextPlayer.x, y=nextPlayer.y, onComplete=completeMoving2})
			
			nextPlayer:removeSelf()
			snapPlayerToGrid()
			
		end
	end
end

local function unheld (event)
	--print(event.phase)
	if event.phase == "ended" then
		--timer.cancel(timer1)
		player.state = STATE_IDLE
		player:pause()
		if (player.i == (player.y + OFFSET) / TILE_WIDTH) == false or (player.j == (player.x + OFFSET) / TILE_WIDTH) == false then
		-- 	player.x = player.j * TILE_WIDTH - OFFSET
		-- 	player.y = player.i * TILE_WIDTH - OFFSET
		 end
		--print( player.state)
	end
end

local function createDpad()
	up = widget.newButton{
		default = "images/Dpad Key up.png",
		over = "images/Dpad Key up.png",
		onEvent = onButtonUpEvent
	}
	down = widget.newButton{
		default = "images/Dpad Key down.png",
		over = "images/Dpad Key down.png",
		onEvent = onButtonDownEvent
	}
	left = widget.newButton{
		default = "images/Dpad Key left.png",
		over = "images/Dpad Key left.png",
		onEvent = onButtonLeftEvent
	}
	right = widget.newButton{
		default = "images/Dpad Key right.png",
		over = "images/Dpad Key right.png",
		onEvent = onButtonRightEvent
	}

	up.x = 80
	up.y = 210
	down.x = 80
	down.y = 290
	left.x = 27
	left.y = 250
	right.x = 133
	right.y = 250
	up:addEventListener("touch", unheld)
	down:addEventListener("touch", unheld)
	left:addEventListener("touch", unheld)
	right:addEventListener("touch", unheld)
	dpadGroup:insert(up)
	dpadGroup:insert(down)
	dpadGroup:insert(left)
	dpadGroup:insert(right)

	down:addEventListener("touch", onButtonDownEvent)
	up:addEventListener("touch", onButtonUpEvent)
	right:addEventListener("touch", onButtonRightEvent)
	left:addEventListener("touch", onButtonLeftEvent)
end

--cleaning the screen
local function cleanGroups(group)
	for i = 1, #group do
		group[i]:removeSelf()
	end
	group = display.newGroup()
end

local function onSuicideButton(event)
	if event.phase == "press" then
		killPlayer()
	end
end

local function onPauseButton(event)
	if event.phase == "press" then
		storyboard.currentLevel = currentLevel
		storyboard.gotoScene( "pause", "slideUp", 800 )
	end
end

local function subtractTime()
	if timerText - 1 < 0 then
		killPlayer()
	else
	timerText = timerText - 1
	timeLeft.text = timerText
	end
end

function explodeBomb(bomb)
	if volume then 
		media.playEventSound(explosionSFX)
	end
	bomb.isVisible = false
	local explosionRight = display.newRect(0,0,0,0)
	local explosionRightUp = display.newRect(0,0,0,0)
	local explosionUp = display.newRect(0,0,0,0)
	local explosionLeftUp = display.newRect(0,0,0,0)
	local explosionLeft = display.newRect(0,0,0,0)
	local explosionLeftDown = display.newRect(0,0,0,0)
	local explosionDown = display.newRect(0,0,0,0)
	local explosionRightDown = display.newRect(0,0,0,0)

	explosionRight.x = bomb.x + TILE_WIDTH
	explosionRight.y = bomb.y
	explosionRightUp.x = bomb.x + TILE_WIDTH
	explosionRightUp.y = bomb.y - TILE_WIDTH
	explosionUp.x = bomb.x 
	explosionUp.y = bomb.y - TILE_WIDTH
	explosionLeftUp.x = bomb.x - TILE_WIDTH
	explosionLeftUp.y = bomb.y - TILE_WIDTH
	explosionLeft.x = bomb.x - TILE_WIDTH
	explosionLeft.y = bomb.y 
	explosionLeftDown.x = bomb.x - TILE_WIDTH
	explosionLeftDown.y = bomb.y + TILE_WIDTH
	explosionDown.x = bomb.x 
	explosionDown.y = bomb.y + TILE_WIDTH
	explosionRightDown.x = bomb.x + TILE_WIDTH
	explosionRightDown.y = bomb.y + TILE_WIDTH

	explosionUp.name = "explosion"
	explosionRightUp.name = "explosion"
	explosionRight.name = "explosion"
	explosionLeftUp.name = "explosion"
	explosionLeft.name = "explosion"
	explosionLeftDown.name = "explosion"
	explosionDown.name = "explosion"
	explosionRightDown.name = "explosion"

	testPossibleCollision(explosionDown)
	testPossibleCollision(explosionUp)
	testPossibleCollision(explosionLeft)
	testPossibleCollision(explosionLeftUp)
	testPossibleCollision(explosionRight)
	testPossibleCollision(explosionRightUp)
	testPossibleCollision(explosionRightDown)
	testPossibleCollision(explosionLeftDown)

	local explosionSprite = sprite.newSprite(explosionSet)
	explosionSprite.x = bomb.x
	explosionSprite.y = bomb.y
	sprite.add (explosionSet, "explosion", 1, 7, 150, 1)
	explosionSprite:prepare("explosion")
	explosionSprite:play()
	local function removeExplosion()
		explosionSprite:removeSelf()
	end
	timer.performWithDelay(150, removeExplosion, 1)

	explosionUp:removeSelf()
	explosionRightUp:removeSelf()
	explosionRight:removeSelf()
	explosionLeftUp:removeSelf()
	explosionLeft:removeSelf()
	explosionLeftDown:removeSelf()
	explosionDown:removeSelf()
	explosionRightDown:removeSelf()
end

function gravityObjects()
	--if gameState then
	if #boulders > 0 then
		for i = 1, #boulders do
			if canGravityObject(boulders[i]) then
				transition.to(boulders[i], {time=0, x=boulders[i].x, y=boulders[i].y + TILE_WIDTH})
				--boulders[i].y = boulders[i].y + TILE_WIDTH
				boulders[i].falling = true
			elseif boulders[i].falling == true then
				local possibleBoulder = createPossibleObject(boulders[i], DIRECTION_DOWN)
				if hasCollided(possibleBoulder, player) and boulders[i].falling == true then
					--boulders[i].y = boulders[i].y + TILE_WIDTH
					transition.to(boulders[i], {time=0, x=boulders[i].x, y=boulders[i].y + TILE_WIDTH})
				end
				for ienemies = 1, #enemies do
					if hasCollided(possibleBoulder, enemies[ienemies]) and boulders[i].falling == true then
						--boulders[i].y = boulders[i].y + TILE_WIDTH
						transition.to(boulders[i], {time=0, x=boulders[i].x, y=boulders[i].y + TILE_WIDTH})
					end
				end
				for ibombs = 1, #bombs do
					if hasCollided(possibleBoulder, bombs[ibombs]) and boulders[i].falling == true then
						--boulders[i].y = boulders[i].y + TILE_WIDTH
						transition.to(boulders[i], {time=0, x=boulders[i].x, y=boulders[i].y + TILE_WIDTH})
						explodeBomb(bombs[ibombs])
					end
				end
				boulders[i].falling = false
				possibleBoulder:removeSelf()
			end
		end
	end
	if canGravityObject(key) then
		transition.to(key, {time=0, x=key.x, y=key.y + TILE_WIDTH})
		--key.y = key.y + TILE_WIDTH
	end
	if #bombs > 0 then
		for i = 1, #bombs do
			if canGravityObject(bombs[i]) and bombs[i].exploded == false then
				--bombs[i].y = bombs[i].y + TILE_WIDTH
				transition.to(bombs[i], {time=0, x=bombs[i].x, y=bombs[i].y + TILE_WIDTH})
				bombs[i].falling = true
			elseif bombs[i].falling == true then
				bombs[i].exploded = true
				bombs[i].isVisible = false
				bombs[i].falling = false
				explodeBomb(bombs[i])
			end
		end
	end
end

--enemy AI
local function calculateDistance( object1, object2 )
	local distance = math.sqrt(
		math.pow(object1.x - object2.x, 2) +
		math.pow(object1.y - object2.y, 2))
	return distance
end

local function moveEnemy()
	local function findSmallestNumber(group)
		local smallest = 1
		for i = 1, #group do
			if group[smallest] > group[i] then
				smallest = i
			end
		end
		return smallest
	end
	for i = 1, #enemies do
		if enemies[i].isVisible then
			local distances = display.newGroup()
			local enemyRight = createPossibleObject(enemies[i], DIRECTION_RIGHT)
			local enemyUp = createPossibleObject(enemies[i], DIRECTION_UP)
			local enemyLeft = createPossibleObject(enemies[i], DIRECTION_LEFT)
			local enemyDown = createPossibleObject(enemies[i], DIRECTION_DOWN)
			enemyRight.name = "enemy"
			enemyUp.name = "enemy"
			enemyLeft.name = "enemy"
			enemyDown.name = "enemy"
			local distanceRight = calculateDistance(
				enemyRight,
				player)
			table.insert(distances, distanceRight)
			local distanceUp = calculateDistance(
				enemyUp,
				player)
			table.insert(distances, distanceUp)
			local distanceLeft = calculateDistance(
				enemyLeft,
				player)
			table.insert(distances, distanceLeft)
			local distanceDown = calculateDistance(
				enemyDown,
				player)
			table.insert(distances, distanceDown)

			enemyRight:removeSelf()
			enemyUp:removeSelf()
			enemyLeft:removeSelf()
			enemyDown:removeSelf()
			local distanceEnemy = calculateDistance(
				enemies[i],
				player)

			-- print(distances[findSmallestNumber(distances)])
			-- print("right"..distanceRight)
			-- print("up"..distanceUp)
			-- print("left"..distanceLeft)
			-- print("down"..distanceDown)

			local function transitionEnemy()
				local smallestNumber = findSmallestNumber(distances)
				if distanceEnemy < distances[smallestNumber] then
					enemies[i]:pause()
					return
				end
				if distances[smallestNumber] == distanceRight then
					if (enemies[i].direction == DIRECTION_RIGHT) == false then
						enemies[i].xScale = -1
						enemies[i].direction = DIRECTION_RIGHT
					end
					if testPossibleCollision(enemyRight) then
						enemies[i]:play()
						transition.to(enemies[i], {time=SPEED_ENEMY, x=enemies[i].x+TILE_WIDTH})
						return
					else
						distances[smallestNumber] = 480
						transitionEnemy()
						return
					end
				end
				if distances[smallestNumber] == distanceUp then
					if testPossibleCollision(enemyUp) then
						transition.to(enemies[i], {time=SPEED_ENEMY, y=enemies[i].y-TILE_WIDTH})
						return
					else
						distances[smallestNumber] = 480
						transitionEnemy()
						return
					end
				end
				if distances[smallestNumber] == distanceLeft then
					if (enemies[i].direction == DIRECTION_LEFT) == false then
						enemies[i].xScale = 1
						enemies[i].direction = DIRECTION_LEFT
					end
					if testPossibleCollision(enemyLeft) then
						enemies[i]:play()
						transition.to(enemies[i], {time=SPEED_ENEMY, x=enemies[i].x-TILE_WIDTH})
						return
					else
						distances[smallestNumber] = 480
						transitionEnemy()
						return
					end
				end
				if distances[smallestNumber] == distanceDown then
					if testPossibleCollision(enemyDown) then
						transition.to(enemies[i], {time=SPEED_ENEMY, y=enemies[i].y+TILE_WIDTH})
						return
					else
						distances[smallestNumber] = 480
						transitionEnemy()
						return
					end
				end
			end
			transitionEnemy()
		end
	end
end

----------------------------
-- STORY BOARD FUNCTIONS
----------------------------
-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	loadData()
	levelInfo[currentLevel][3] = true
	saveData()
	function buildLevel(level)
		for i = 1, 13 do -- table height
			for j =1, 19 do -- table length
				if(level[i][j] == 0) then 
				elseif(level[i][j] == 1) then 
					player.x = TILE_WIDTH * j - OFFSET
					player.y = TILE_WIDTH * i - OFFSET
					player.alive = true
					player.i = i
					player.j = j
				elseif(level[i][j] == 2) then 
					local wall = display.newImage("images/Stone 2 sprite.png")
					wall.name = "wall"
					wall.x = TILE_WIDTH * j - OFFSET
					wall.y = TILE_WIDTH * i - OFFSET
					table.insert(walls, wall)
					group:insert(wall)
				elseif(level[i][j] == 3) then 
					local sand = display.newImage("images/sand.png")
					sand.name = "sand"
					sand.x = TILE_WIDTH * j - OFFSET
					sand.y = TILE_WIDTH * i - OFFSET
					table.insert(sands, sand)
					group:insert(sand)
				elseif(level[i][j] == 4) then 
					local boulder = display.newImage("images/Rock.png")
					boulder.x = TILE_WIDTH * j - OFFSET
					boulder.y = TILE_WIDTH * i - OFFSET
					boulder.falling = false
					table.insert(boulders, boulder)
					group:insert(boulder)
				elseif(level[i][j] == 5) then 
					local bomb = display.newImage("images/Bomb sprite.png")
					bomb.x = TILE_WIDTH * j - OFFSET
					bomb.y = TILE_WIDTH * i - OFFSET
					bomb.falling = false
					bomb.exploded = false
					table.insert(bombs, bomb)
					group:insert(bomb)
				elseif(level[i][j] == 6) then 
					local enemy = sprite.newSprite(enemySet)
					enemy:prepare("enemyleft")
					enemy.direction = DIRECTION_LEFT
					enemy.x = TILE_WIDTH * j - OFFSET
					enemy.y = TILE_WIDTH * i - OFFSET
					table.insert(enemies, enemy)
					group:insert(enemy)
				elseif(level[i][j] == 7) then 
					local stone = display.newImage("images/stone.png")
					stone.name = "stone"
					stone.x = TILE_WIDTH * j - OFFSET
					stone.y = TILE_WIDTH * i - OFFSET
					table.insert(stones, stone)
					group:insert(stone)
				elseif(level[i][j] == 8) then 
					key.x = TILE_WIDTH * j - OFFSET
					key.y = TILE_WIDTH * i - OFFSET
				elseif(level[i][j] == 9) then 
					door.x = TILE_WIDTH * j - OFFSET
					door.y = TILE_WIDTH * i - OFFSET
				elseif(level[i][j] == 11) then 
					local infoText
					if currentLevel == 1 then
						infoText = "Push the key into the door."
					elseif currentLevel == 2 then
						infoText = "You can walk through sand."
					end
					local info = display.newText(infoText,200,75,display.systemFontBold,15)
					info:setReferencePoint(display.TopLeftReferencePoint)
					info.x = TILE_WIDTH * j - OFFSET * 2
					info.y = TILE_WIDTH * i - OFFSET * 2
					group:insert(info)
					info:toBack()
					background:toBack()
				end
			end
		end
		gameState = true
		dpadGroup:toFront()
	end

	local groupInsert = function()
		group:insert(background)
		group:insert(player)
		group:insert(door)
		group:insert(key)
		group:insert(dpadGroup)
		group:insert(headerGroup)
	end
	local main = function()
		key.name = key
		createPlayer()
		createDoor()
		groupInsert()
		buildLevel(levels[currentLevel])
		createDpad()
		createHeader()
	end
	main()
	
end

local function add2Numbers( Number1, Number2 )
	
	return Number1 + Number2
end

local number = add2Numbers(2, 3)


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	--Runtime:addEventListener("enterFrame", gravityObjects)\
	storyboard.removeScene("completedLevel")
	storyboard.removeScene("levels")
	storyboard.removeScene("levels2")
	storyboard.removeScene("retry")

	countdownTimer = timer.performWithDelay(1000,subtractTime,0)
	enemyTimer = timer.performWithDelay(300,moveEnemy,0)
	gravityTimer = timer.performWithDelay(200,gravityObjects,0)

	Runtime:addEventListener("enterFrame", testCollisions)

	if audio.getSessionProperty( audio.OtherAudioIsPlaying  ) == 1 then 
    	audio.setSessionProperty(audio.MixMode, audio.AmbientMixMode)
		media.setSoundVolume(0)
	end
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	timer.pause(countdownTimer)
	timer.pause(enemyTimer)
	timer.pause(gravityTimer)

	--Runtime:removeEventListener("enterFrame", gravityObjects)
	Runtime:removeEventListener("enterFrame", testCollisions)
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
	--Runtime:removeEventListener("enterFrame", gravityObjects)
	--Runtime:removeEventListener("enterFrame", testCollisions)
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

return scene
