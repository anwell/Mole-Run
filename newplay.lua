display.setStatusBar (display.HiddenStatusBar)

--require
require("levelData")
Vector2D = require "Vector2D"
require "auxFunctions"
local levels = levelData.levels
local ui = require("ui")
local widget = require "widget"
require ("sprite")
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
storyboard.lastLevel = #levels
local levelInfo = levelData.levelInfo
local Dpad = require "dpad"
local dpad = nil
local Player = require "player"
local player = nil

--constants
local STATE_IDLE = "Idle"
local STATE_WALKING = "Walking"
local DIRECTION_RIGHT = 0
local DIRECTION_UP = 1
local DIRECTION_LEFT = 2
local DIRECTION_DOWN = 3
local DIRECTIONS = {DIRECTION_RIGHT, DIRECTION_UP, DIRECTION_LEFT, DIRECTION_DOWN}
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


local function touchManager(event)
	if (event.phase == "cancelled" or event.phase == "ended") then

	end

	if (event.phase == "began" and dpad == nil) then

	end

	if (dpad ~= nil) then
		-- Move dpad if touch gets away its range
		Dpad.moveToTouch(dpad, event)
		
		local angle = Dpad.getAngle(dpad, event) 
		if angle ~= nil then
			local angleDirection = math.floor((angle + 45) / 90)
			player.direction = angleDirection
			Player.move(player)
		end
		
		-- Move player according to dpad angle
		--playerMgr.move(player, Dpad.getAngle(dpad, event))
	end
	
	return true
end
	
	
----------------------------
-- STORY BOARD FUNCTIONS
----------------------------
-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	-- 0: empty
	-- 1: player
	-- 2: wall
	-- 3: sand
	-- 4: boulder
	-- 5: bomb
	-- 6: enemy
	-- 7: stone
	-- 8: key
	-- 9: door
	-- 11: info
	function buildLevel(level)
		for i = 1, #level do
			for j = 1, #level[1] do
				local spriteCode = level[i][j]
				if (spriteCode == 0) then
					--goto continue
				elseif (spriteCode == 1) then
					player = Player.create(TILE_WIDTH, TILE_WIDTH * j, TILE_WIDTH * i)
				elseif(level[i][j] == 8) then 
					key.x = TILE_WIDTH * j
					key.y = TILE_WIDTH * i
				elseif(level[i][j] == 9) then 
					door.x = TILE_WIDTH * j
					door.y = TILE_WIDTH * i
				elseif (spriteCode == 6) then
					local enemy = sprite.newSprite(enemySet)
					enemy:prepare("enemyleft")
					enemy.x = TILE_WIDTH * j
					enemy.y = TILE_WIDTH * i
				else
					display.newImage("images/" .. spriteCode .. ".png", TILE_WIDTH * j - OFFSET, TILE_WIDTH * i - OFFSET)
				end
				--::continue::
			end
		end
	end
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	buildLevel(levels[1])
	dpad = Dpad.create(100, 250)
	--group:insert(dpad)
	dpad.isVisible = true
	background:addEventListener("touch", touchManager)
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
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
