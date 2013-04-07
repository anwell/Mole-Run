
local ui = require("ui")
----------------------------------------------------------------------------------
--
-- scenetemplate.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local sprite = require "sprite"
local movePlayerLeft
local movePlayerRight

local playerSheet = sprite.newSpriteSheet("images/mole3.png", 26, 26)
local playerSet = sprite.newSpriteSet (playerSheet, 1, 21)
local player = sprite.newSprite(playerSet)
sprite.add (playerSet, "playerleft", 8, 2, 100, 0)
sprite.add (playerSet, "playerright", 1, 2, 100, 0)

function movePlayerLeft()
	player.x = 506
	player.y = math.random(320)
	player:prepare("playerleft")
	player:play()
	transition.to(player, {time=math.random(2000, 6000), x=-26, y=player.y, onComplete=movePlayerRight})
end

function movePlayerRight()
	player.x = -26
	player.y = math.random(320)
	player:prepare("playerright")
	player:play()
	transition.to(player, {time=math.random(2000, 6000), x=506, y=player.y, onComplete=movePlayerLeft})
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	local background = display.newImage("images/background.png")
	local title = display.newImage( "images/Mole run title.png" )
	local playButton 
	local optionsButton
	local levelsButton
	local function loadOptions(event)
		if event.phase == "press" then
			storyboard.gotoScene( "options", "slideRight", 800 )
		end
	end
	local loadLevelOne = function(event)
		if event.phase == "press" then
			storyboard.currentLevel = 1
			storyboard.score = 0
			storyboard.gotoScene( "play", "slideLeft", 800 )
		end
	end
	local loadLevels = function(event)
		if event.phase == "press" then
			storyboard.gotoScene( "levels1", "slideUp", 800 )
		end
	end
	local function loadButtons()
		playButton = ui.newButton{
			default = "images/play.png",
			over = "images/playselect.png",
			onEvent = loadLevelOne
		}
		levelsButton = ui.newButton{
			default = "images/levels_button.png",
			over = "images/levels_button_select.png",
			onEvent = loadLevels
		}
		optionsButton = ui.newButton{
			default = "images/Options button.png",
			over = "images/Options button select.png",
			onEvent = loadOptions
		}
		levelsButton.x = 380
		levelsButton.y = 250
		optionsButton.x = 100
		optionsButton.y = 250
		playButton.x = display.contentWidth/2
		playButton.y = 198
		title.x = display.contentWidth/2
		title.y = 100
	end
	local function main()
		loadButtons()
		group:insert(background)
		group:insert(player)
		group:insert(title)
		group:insert(playButton)
		group:insert(levelsButton)
		group:insert(optionsButton)
		movePlayerLeft()
	end
	main()
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	storyboard.removeScene("quit")
	storyboard.removeScene("scores")
	storyboard.removeScene("play")
	if storyboard.sound == nil then
		media.playSound("sounds/Pinball Spring.mp3", true)
	end
	storyboard.sound = true
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	
	-----------------------------------------------------------------------------
	
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. remove listeners, widgets, save state, etc.)
	
	-----------------------------------------------------------------------------
	
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
