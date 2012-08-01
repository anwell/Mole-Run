----------------------------------------------------------------------------------
--
-- scenetemplate.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local json = require "json"
local scene = storyboard.newScene()
local score = storyboard.score

local grid = {}
print("f"..#grid)

local loadData, saveData, compare
local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )

local nameTextBox

local background = display.newImage ("images/dirtBackground.png")

local levelScore = display.newText("score: "..score,240,70,"Courier",30)
levelScore:setReferencePoint(display.CenterReferencePoint)
levelScore.x = 240
local nameLabel = display.newText("Enter your name:",240,120,native.systemFont,15)
nameLabel:setReferencePoint(display.CenterReferencePoint)
nameLabel.x = 240

local pauseText = display.newText( "Save score", 0, 0, native.systemFontBold, 40 )

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
		loadData()
		grid[#grid + 1] = {score, nameTextBox.text}
		table.sort(grid, compare)
		if #grid > 5 then
			for i = 5, #grid do
				table.remove(grid, i)
				print("test")
			end
		end
		saveData()
		storyboard.removeScene("play")
		storyboard.gotoScene( "menu", "slideDown", 800  )
	end
end

local menuButton = ui.newButton{
	default = "images/Save Score Button.png",
	over = "images/Save Score Button select.png",
	onEvent = onMenuButton
}

function loadData()	
	local file = io.open( filePath, "r" )
	if file then
		contents = file:read("*a")
		grid = json.decode(contents)
		io.close(file)
	end
end

function saveData()
	file = io.open(filePath, "w")
	if file then
		contents = json.encode (grid)
		file:write(contents)
		io.close(file)
	end
end

function compare(a,b)
	return a[1] > b[1]
end

local function removeKeyboard()
	 native.setKeyboardFocus( nil )
end

---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	group:insert(background)
	group:insert(resumeButton)
	group:insert(menuButton)
	group:insert(levelScore)
	group:insert(pauseText)
	group:insert(nameLabel)
	resumeButton.x = 240
	resumeButton.y = 280
	menuButton.x = 240
	menuButton.y = 210
	pauseText.x = 240
	pauseText.y = 30

	if storyboard.currentLevel == storyboard.lastLevel + 1 then
		resumeButton.isVisible = false
	end
	-----------------------------------------------------------------------------
		
	--	CREATE display objects and add them to 'group' here.
	--	Example use-case: Restore 'group' from previously saved state.
	
	-----------------------------------------------------------------------------
	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	background:addEventListener("touch", removeKeyboard)
	nameTextBox = native.newTextField(130, 147, 220, 36)
	nameTextBox.text = "Name"
	-----------------------------------------------------------------------------
		
	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
	-----------------------------------------------------------------------------
	
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	nameTextBox:removeSelf()
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