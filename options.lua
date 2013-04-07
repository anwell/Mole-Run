----------------------------------------------------------------------------------
--
-- scenetemplate.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require "widget"

local background = display.newImage("images/background.png")

local muteSound, clearScoresButton
local onMuteButton, onClearScoresButton

local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )

local onBackButton = function(event)
	storyboard.gotoScene( "menu", "slideLeft", 800  )
end

local backButton = widget.newButton{
	defaultFile = "images/MenuButton.png",
	overFile = "images/MenuButtonselect.png",
	onPress = onBackButton
}
backButton.x = 240
backButton.y = 280

local function checkSound()
	if storyboard.sound then
		muteSound:setLabel("Turn sound off")
	else
		muteSound:setLabel("Turn sound on")
	end
end
 onMuteButton = function(event)
	if storyboard.sound then
		media.pauseSound()
		storyboard.sound = false
	else
		media.playSound()
		storyboard.sound = true
	end
	checkSound()
end


 muteSound = widget.newButton{
 	defaultFile = "images/blankOptionsButton.png",
	label = "Turn sound off",
	onPress = onMuteButton,
	font = "Bauhaus 93",
	labelColor = {default = {255, 255, 0, 255}, over = {0}}
}
muteSound.x = 240
muteSound.y = 100

function onClearScoresButton(event)
	os.remove(filePath)
end

clearScoresButton = widget.newButton{
	width = 200,
 	defaultFile = "images/blankOptionsButton.png",
	label = "Clear high scores",
	onPress = onMuteButton,
	font = "Bauhaus 93",
	labelColor = {default = {255, 255, 0, 255}, over = {0}}
}
clearScoresButton.x = 240
clearScoresButton.y = 180


local optionsHeader = display.newText( "Options", 0, 0, native.systemFontBold, 40 )
-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view


		group:insert(background)
		group:insert( backButton )
		group:insert(muteSound)
		group:insert(clearScoresButton)
		
		optionsHeader.x = display.contentWidth/2
		optionsHeader.y = 30
		group:insert( optionsHeader )

		local function loadMain()
			storyboard.gotoScene( "menu", "slideRight", 800  )
			mainGroup.isVisible = true
		end
		checkSound()
		
	-----------------------------------------------------------------------------
		
	--	CREATE display objects and add them to 'group' here.
	--	Example use-case: Restore 'group' from previously saved state.
	
	-----------------------------------------------------------------------------
	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	 -- Runtime:addEventListener("enterFrame", checkSound)
	-----------------------------------------------------------------------------
		
	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
	-----------------------------------------------------------------------------
	
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	-- Runtime:removeEventListener("enterFrame", checkSound)
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

