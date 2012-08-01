----------------------------------------------------------------------------------
--
-- scenetemplate.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local widget = require "widget"
local scene = storyboard.newScene()
local json = require "json"

storyboard.score = 0

local background = display.newImage ("images/dirtBackground.png")
local levelsTitle = display.newText( "High Scores", 0, 0, native.systemFontBold, 40 )

local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )

local grid = {}
local noScoresText= display.newText("No high scores! (yet)", 80, 100, native.systemFontBold, 30 );
noScoresText:setTextColor( 255, 255, 136, 255 );
noScoresText.isVisible = false

local scoresTable = {
	{100, "Tim"},
	{50, "Frank"},
	{50, "Ted"},
	{50, "Ted"},
	{50, "Ted"},
}

function compare(a,b)
	return a[1] > b[1]
end
table.sort(scoresTable, compare)
--sorting the tables by the first value (which is the score)

local onLevelsButton = function(event)
	if event.phase == "press" then
		storyboard.gotoScene( "levels", "slideDown", 800  )
	end
end

local levelsButton = ui.newButton{
	default = "images/levels_button.png",
	over = "images/levels_button_select.png",
	onEvent = onLevelsButton
}

local onScoresButton = function(event)
	if event.phase == "press" then
		storyboard.gotoScene( "menu", "slideDown", 800  )
	end
end

local scoresButton = ui.newButton{
	default = "images/MenuButton.png",
	over = "images/MenuButtonselect.png",
	onEvent = onScoresButton
}


----------------------
-- Save/load functions

function saveData()
	file = io.open(filePath, "w")
	if file then
		contents = json.encode (scoresTable)
		file:write(contents)
		io.close(file)
	end
end

function loadData()	
	local file = io.open( filePath, "r" )
	if file then
		contents = file:read("*a")
		grid = json.decode(contents)
		io.close(file)
		if #grid == 0 then
			noScoresText.isVisible = true
		end
	else 
		noScoresText.isVisible = true
	end
end
---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	
	group:insert(background)
	-- group:insert(nextLevelButton)
	-- group:insert(level2Button)
	group:insert(levelsTitle)
	group:insert(levelsButton)
	group:insert(scoresButton)
	group:insert(noScoresText)

	levelsTitle.x = 240
	levelsTitle.y = 30
	levelsButton.x = 380
	levelsButton.y = 275
	scoresButton.x = 100
	scoresButton.y = 275

	--saveData()
	loadData()

	-- show retrieved data
	y = 80
	local t
	for i = 1, #grid do
		if i == 1 then
			local t = display.newText(i..". "..grid[i][2]..": "..grid[i][1].." points", 240, y, native.systemFontBold, 30 );
			t:setReferencePoint(display.CenterReferencePoint)
			t.x = 240
			t:setTextColor( 255, 255, 136, 255 );
			group:insert(t)
			y = y + 10
		else
			y = y + 30
			local t = display.newText(i..". "..grid[i][2]..": "..grid[i][1].." points", 240, y, native.systemFontBold, 20 );
			t:setReferencePoint(display.CenterReferencePoint)
			t.x = 240
			t:setTextColor( 255, 255, 136, 255 );
			group:insert(t)
		end
	end
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