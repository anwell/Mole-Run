display.setStatusBar(display.HiddenStatusBar)

local storyboard = require "storyboard"

splash = display.newImage("Default.png")
-- local function splash:touch (event)
-- 	main()
-- end

-- local sysFonts = native.getFontNames()
-- for k,v in pairs(sysFonts) do print(v) end

local function main()
   splash:removeEventListener("touch", main)
   splash:removeSelf()
   splash = nil
   storyboard.gotoScene( "menu", "fade", 400 )
   timer.pause(splashTimer)
end
splashTimer = timer.performWithDelay(2500, main, 1)
splash:addEventListener("touch", main)