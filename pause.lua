----------------------------------------------------------------------------------
--
-- scenetemplate.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local background = display.newImage ("images/dirtBackground.png")
local pauseText = display.newText( "Pause", 0, 0, native.systemFontBold, 40 )

local currentLevel = storyboard.currentLevel
print("something"..currentLevel)

local onResumeButton = function(event)
	if event.phase == "press" then
		storyboard.gotoScene( "play", "slideDown", 800  )
	end
end

local resumeButton = ui.newButton{
	default = "images/ResumeButton.png",
	over = "images/ResumeButtonselect.png",
	onEvent = onResumeButton
}

local onMenuButton = function(event)
	if event.phase == "press" then
		storyboard.gotoScene( "quit", "slideDown", 800  )
	end
end

local menuButton = ui.newButton{
	default = "images/Quit Button.png",
	over = "images/quit button select.png",
	onEvent = onMenuButton
}

local mole = display.newImage("images/matt128.png")
mole.x = 240
mole.y = 110
---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	group:insert(background)
	group:insert(resumeButton)
	group:insert(menuButton)
	group:insert(pauseText)
	group:insert(mole)
	resumeButton.x = 240
	resumeButton.y = 210
	menuButton.x = 240
	menuButton.y = 280
	pauseText.x = 240
	pauseText.y = 30
	-----------------------------------------------------------------------------
		
	--	CREATE display objects and add them to 'group' here.
	--	Example use-case: Restore 'group' from previously saved state.
	
	-----------------------------------------------------------------------------
	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
		
	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
	-----------------------------------------------------------------------------
	
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