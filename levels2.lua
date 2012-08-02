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
}

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
	if file == nil then
		print("pleasepleaseplease")
	end
	if file then
		print("blab")
		contents = file:read("*a")
		--levelInfo = nil
		levelInfo = json.decode(contents)
		if #levelInfo == 0 then
			print("hooray")
		end
		io.close(file)
	end
end

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
		for i = 11, 20 do -- table height
			--for j =1, 5 do -- table length
			local levelButton
			if levelsPage[i][3] then
				levelButton = widget.newButton{
				default = "images/Level Button"..levelsPage[i][1]..".png",
				over = "images/Level Button"..levelsPage[i][1]..".png",
				onPress = onLevelButton
				}
			else
				levelButton = widget.newButton{
				default = "images/Level Button"..levelsPage[i][1]..".png",
				over = "images/Level Button"..levelsPage[i][1]..".png",
				defaultColor = { 255, 255, 255, 75 },
				overColor = { 255, 255, 255, 75 }
				}
			end
			levelButton.x = j * BUTTON_SPACE - OFFSET
			if j < 5 then
				j = j +1
			else
				j = 1
			end
			levelButton.y = levelsPage[i][2] * BUTTON_SPACE + OFFSET - 10
			levelButton.name = levelsPage[i][1]
			group:insert(levelButton)
			--end
		end
	end

	group:insert(background)
	-- group:insert(nextLevelButton)
	-- group:insert(level2Button)
	group:insert(levelsTitle)
	group:insert(menuButton)
	group:insert(scoresButton)
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
	previousPageButton.x = 50
	previousPageButton.y = 35
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