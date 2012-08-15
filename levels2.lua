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
local levelsTitle = display.newText( "Levels (11-20)", 0, 0, native.systemFontBold, 40 )

local page = 1
local BUTTON_SPACE = 90
local OFFSET = 30

local buildLevelsPage

local json = require "json"
local saveData, loadData
local filePath = system.pathForFile( "levelInfoTable.json", system.DocumentsDirectory )

-- {level #, row #, unlocked or not}
local levelInfo = {
	{1, 1, true},
	{2, 1, false},
	{3, 1, false},
	{4, 1, false},
	{5, 1, false},
	{6, 2,false},
	{7, 2,false},
	{8, 2,false},
	{9, 2,false},
	{10, 2,false},
	{11,1, false},
	{12, 1,false},
	{13,1, false},
	{14, 1,false},
	{15,1, false},
	{16, 2,false},
	{17,2, false},
	{18, 2,false},
	{19,2, false},
	{20, 2,false},
	{21, 1, false},
	{22, 1, false},
	{23, 1, false},
	{24, 1, false},
	{25, 1, false},
	{26, 2,false},
	{27, 2,false},
	{28, 2,false},
	{29, 2,false},
	{30, 2,false},
	{31, 1, false},
	{32, 1, false},
	{33, 1, false},
	{34, 1, false},
	{35, 1, false},
	{36, 2,false},
	{37, 2,false},
	{38, 2,false},
	{39, 2,false},
	{40, 2,false},
	{41, 1, false},
	{42, 1, false},
	{43, 1, false},
	{44, 1, false},
	{45, 1, false},
	{46, 2,false},
	{47, 2,false},
	{48, 2,false},
	{49, 2,false},
	{50, 2,false},
	{51, 1, false},
	{52, 1, false},
	{53, 1, false},
	{54, 1, false},
	{55, 1, false},
	{56, 2,false},
	{57, 2,false},
	{58, 2,false},
	{59, 2,false},
	{60, 2,false},
}

local levelMin = 11
local levelMax = 20

function saveData()
	file = io.open(filePath, "w")
	local contents
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

local onMenuButton = function(event)
	if event.phase == "press" then
		storyboard.gotoScene( "menu", "slideDown", 800  )
	end
end

local menuButton = widget.newButton{
	default = "images/MenuButton.png",
	over = "images/MenuButtonselect.png",
	onEvent = onMenuButton
}

local onScoresButton = function(event)
	if event.phase == "press" then
		storyboard.gotoScene( "scores", "slideUp", 800  )
	end
end

local scoresButton = widget.newButton{
	default = "images/high score button.png",
	over = "images/high score button select.png",
	onEvent = onScoresButton
}

local onNextPageButton = function(event)
	if event.phase == "press" then
		storyboard.gotoScene(  "levels"..(levelMax / 10 + 1), "slideLeft", 800  )
	end
end

local nextPageButton = widget.newButton{
	default = "images/Dpad Key right.png",
	over = "images/Dpad Key right.png",
	onEvent = onNextPageButton
}

local onPreviousPageButton = function(event)
	if event.phase == "press" then
		storyboard.gotoScene( "levels", "slideRight", 800  )
	end
end

local previousPageButton = ui.newButton{
	default = "images/Dpad Key left.png",
	over = "images/Dpad Key left.png",
	onEvent = onPreviousPageButton
}

local function doNothing()
end

---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	local onLevelButton = function(buttonEvent)
		--if event.phase == "press" then
			storyboard.currentLevel = buttonEvent.target.name
			storyboard.gotoScene( "play", "slideDown", 800  )
		--end
	end
	function buildLevelsPage(levelsPage)
		local j = 1
		for i = levelMin, levelMax do -- table height
			--for j =1, 5 do -- table length
			local levelButton
			local lock = display.newImage("images/lockbutton.png")
			lock.isVisible = false
			if levelsPage[i][3] then
				levelButton = widget.newButton{
				default = "images/level_button_blank.png",
				over = "images/level_button_blank.png",
				onPress = onLevelButton,
				label = levelsPage[i][1],
				font = "Bauhaus93",
				fontSize = 42,
				labelColor = {default = {255, 255, 0, 255}, over = {0}}
				}
			else
				levelButton = widget.newButton{
				default = "images/level_button_blank.png",
				over = "images/level_button_blank.png",
				onPress = doNothing,
				label = levelsPage[i][1],
				font = "Bauhaus93",
				fontSize = 42,
				labelColor = {default = {255, 255, 0, 255}, over = {0}}
				}
				lock.isVisible = true
			end
			levelButton.x = j * BUTTON_SPACE - OFFSET
			lock.x = j * BUTTON_SPACE - OFFSET
			if j < 5 then
				j = j +1
			else
				j = 1
			end
			levelButton.y = levelsPage[i][2] * BUTTON_SPACE + OFFSET - 10
			lock.y = levelsPage[i][2] * BUTTON_SPACE + OFFSET - 20
			levelButton.name = levelsPage[i][1]
			group:insert(levelButton)
			group:insert(lock)
			--end
		end
	end

	group:insert(background)
	-- group:insert(nextLevelButton)
	-- group:insert(level2Button)
	group:insert(levelsTitle)
	group:insert(menuButton)
	group:insert(scoresButton)
	group:insert(nextPageButton)
	group:insert(previousPageButton)
	--buildLevelsPage(levelsPages[page])
	loadData()
	buildLevelsPage(levelInfo)
	levelsTitle.x = 240
	levelsTitle.y = 30
	menuButton.x = 380
	menuButton.y = 275
	scoresButton.x = 100
	scoresButton.y = 275
	nextPageButton.x = 430
	nextPageButton.y = 35
	previousPageButton.x = 50
	previousPageButton.y = 35
	-- previousPageButton.isVisible = false
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