----------------------------------------------------------------------------------
--
-- scenetemplate.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local score = storyboard.score

local background = display.newImage ("images/background.png")
--local currentLevel = storyboard.currentLevel
local levelScore = display.newText(score,240,100,"Courier",30)
levelScore:setReferencePoint(display.CenterReferencePoint)
levelScore.x = 240

local levelCompleteText = display.newText("Game Over",200,75,display.systemFontBold,20)
levelCompleteText:setReferencePoint(display.CenterReferencePoint)
levelCompleteText.x = 240

local onRetryButton = function(event)
	if event.phase == "press" then
		storyboard.gotoScene( "play", "slideRight", 800  )
	end
end

local retryButton = ui.newButton{
	default = "images/retry button.png",
	over = "images/retry button select.png",
	onEvent = onRetryButton
}

local onMenuButton = function(event)
	if event.phase == "press" then
		storyboard.gotoScene( "menu", "slideRight", 800  )
	end
end

local menuButton = ui.newButton{
	default = "images/MenuButton.png",
	over = "images/MenuButtonselect.png",
	onEvent = onMenuButton
}

local mole = display.newImage("images/matt128dead.png")
mole.x = 70
mole.y = 90

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	menuButton.x = 150
	menuButton.y = 220
	retryButton.x = 350
	retryButton.y = 220
	group:insert(background)
	group:insert(mole)
	group:insert(levelScore)
	group:insert(retryButton)
	group:insert(menuButton)
	group:insert(levelCompleteText)
	-----------------------------------------------------------------------------
		
	--	CREATE display objects and add them to 'group' here.
	--	Example use-case: Restore 'group' from previously saved state.
	
	-----------------------------------------------------------------------------
	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	storyboard.removeScene( "play")
	-----------------------------------------------------------------------------
		
	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
	-----------------------------------------------------------------------------
	
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	storyboard.score = 0
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