----------------------------------------------------------------------------------
--
-- scenetemplate.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local background = display.newImage ("images/background.png")
local currentLevel = storyboard.currentLevel
local score = storyboard.score
local timeBonus = storyboard.timeBonus

local levelCompleteText = display.newText("Level "..(currentLevel-1).." Complete!",200,75,display.systemFontBold,20)
levelCompleteText:setReferencePoint(display.CenterReferencePoint)
levelCompleteText.x = 240
local levelScore = display.newText(score,240,100,"Courier",30)
levelScore:setReferencePoint(display.CenterReferencePoint)
levelScore.x = 240
local timeBonusText = display.newText("Time Bonus: "..timeBonus,240,150,"Courier",20)
timeBonusText:setReferencePoint(display.CenterReferencePoint)
timeBonusText.x = 240

local onNextLevelButton = function(event)
	if event.phase == "press" then
		if currentLevel - 1 < storyboard.lastLevel then
			storyboard.score = score
			storyboard.timeBonus = 0
			storyboard.gotoScene( "play", "slideLeft", 800  )
		else
			storyboard.gotoScene( "menu", "slideRight", 800  )
		end
	end
end

local nextLevelButton = ui.newButton{
	default = "images/next_button.png",
	over = "images/next_button_select.png",
	onEvent = onNextLevelButton
}

local onLevelsButton = function(event)
	if event.phase == "press" then
		storyboard.score = score
		storyboard.timeBonus = 0
		storyboard.gotoScene( "quit", "slideUp", 800  )
	end
end

local levelsButton = ui.newButton{
	default = "images/Quit Button.png",
	over = "images/quit button select.png",
	onEvent = onLevelsButton
}


-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	
	if currentLevel - 1 == storyboard.lastLevel then
		print(storyboard.lastLevel)
		levelCompleteText.text = "You have won! Your final score is:"
		nextLevelButton:removeSelf()
		nextLevelButton = ui.newButton{
			default = "images/MenuButton.png",
			over = "images/MenuButtonselect.png",
			onEvent = onNextLevelButton
		}
		levelsButton:removeSelf()
		levelsButton = ui.newButton{
			default = "images/Save Score Button.png",
			over = "images/Save Score Button select.png",
			onEvent = onLevelsButton
		}
		group:insert(levelsButton)
		group:insert(nextLevelButton)
	end

	levelsButton.x = 150
	levelsButton.y = 220
	nextLevelButton.x = 350	
	nextLevelButton.y = 220
	
	group:insert(background)
	group:insert(levelCompleteText)
	group:insert(levelScore)
	group:insert(nextLevelButton)
	group:insert(levelsButton)
	group:insert(timeBonusText)
	-----------------------------------------------------------------------------
		
	--	CREATE display objects and add them to 'group' here.
	--	Example use-case: Restore 'group' from previously saved state.
	
	-----------------------------------------------------------------------------
	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	storyboard.removeScene( "play")
	media.playSound("sounds/Speed Kills.WAV", true)
	local function addBonus()
		if timeBonus > 0 then
			timeBonus = timeBonus - 10
			timeBonusText.text = "Time Bonus: "..timeBonus
			group:insert(timeBonusText)
			score = score + 10
			levelScore.text = score
		else
			timer.pause(addBonusTimer)
		end
	end
	addBonusTimer = timer.performWithDelay(1, addBonus, 0)

	local function completeAddBonus()
		timer.pause(addBonusTimer)
		score = score + timeBonus
		timeBonus = 0
		levelScore.text = score
		timeBonusText.text = "Time Bonus: "..timeBonus
		background:removeEventListener("touch", completeAddBonus)
	end
	background:addEventListener("touch", completeAddBonus)
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