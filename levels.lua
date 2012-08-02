----------------------------------------------------------------------------------
--
-- scenetemplate.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local widget = require "widget"
local scene = storyboard.newScene()

storyboard.score = 0

local background = display.newImage ("images/dirtBackground.png")
local levelsTitle = display.newText( "Levels (1-10)", 0, 0, native.systemFontBold, 40 )

local page = 1
local BUTTON_SPACE = 90
local OFFSET = 30

local buildLevelsPage

local levelsPages = {}
levelsPages[1] = {{1,2,3,4,5},
				 {6,7,8,9,10},}

local onMenuButton = function(event)
	if event.phase == "press" then
		storyboard.gotoScene( "menu", "slideDown", 800  )
	end
end

local menuButton = ui.newButton{
	default = "images/MenuButton.png",
	over = "images/MenuButtonselect.png",
	onEvent = onMenuButton
}

local onScoresButton = function(event)
	if event.phase == "press" then
		storyboard.gotoScene( "scores", "slideUp", 800  )
	end
end

local scoresButton = ui.newButton{
	default = "images/high score button.png",
	over = "images/high score button select.png",
	onEvent = onScoresButton
}

local onNextPageButton = function(event)
	if event.phase == "press" then
		storyboard.gotoScene( "levels2", "slideLeft", 800  )
	end
end

local nextPageButton = ui.newButton{
	default = "images/Dpad Key right.png",
	over = "images/Dpad Key right.png",
	onEvent = onNextPageButton
}

---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	local onLevelButton = function(event)
		if event.phase == "press" then
			storyboard.currentLevel = event.target.name
			storyboard.gotoScene( "play", "slideDown", 800  )
		end
	end
	function buildLevelsPage(levelsPage)
		for i = 1, 2 do -- table height
			for j =1, 5 do -- table length
				levelButton = widget.newButton{
				default = "images/Level Button"..levelsPage[i][j]..".png",
				over = "images/Level Button"..levelsPage[i][j]..".png",
				onEvent = onLevelButton
				}
				levelButton.x = j * BUTTON_SPACE - OFFSET
				levelButton.y = i * BUTTON_SPACE + OFFSET - 10
				levelButton.name = levelsPage[i][j]
				group:insert(levelButton)
			end
		end
	end
	group:insert(background)
	-- group:insert(nextLevelButton)
	-- group:insert(level2Button)
	group:insert(levelsTitle)
	group:insert(menuButton)
	group:insert(scoresButton)
	group:insert(nextPageButton)
	buildLevelsPage(levelsPages[page])
	levelsTitle.x = 240
	levelsTitle.y = 30
	menuButton.x = 380
	menuButton.y = 275
	scoresButton.x = 100
	scoresButton.y = 275
	nextPageButton.x = 430
	nextPageButton.y = 35
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