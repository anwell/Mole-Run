--[[
-------------------------
-- Usage
-------------------------

Put this at the top of the file where you want to use the DPad
	
	local dpadMgr = require "dpad"
	local dpad = nil

Create a new DPad like this:
Replace localGroup with whatever your main display group is called.
Set the x and y coordinates as the center of your DPad at first appeareance.
You should pass the touch coordinates as x and y coordinates.

	dpad = dpadMgr.create(x_coordinate, y_coordinate)
	localGroup:insert(dpad)
	dpad.isVisible = true

The readings you can have from the DPad are the angle and the magnitude.

To get the angle in degress where your finger is pointing use getAngle
passing your actual dpad and the touch event or anything that has x and y values.
It will return an angle in degrees ready to use.

	dpadMgr.getAngle(dpad, event)
	
To get the magnitude aka distance of your touch from the center of the DPad use getMagnitude
passing your actual dpad and the touch event or anything that has x and y values.
It will return a Vector2D ready to use.

	dpadMgr.getMagnitude(dpad, event)
	
You can also drag the DPad around like follows, passing your actual dpad and
the touch event or anything that has x and y values.

	dpadMgr.moveToTouch(dpad, event)

When you need to delete the DPad, do it like this:

	dpadMgr.destroy(dpad)
	dpad = nil

And finally, when you no longer need the DPad (your level is finished)
you can clean the manager from memory like this:

	dpadMgr.destroy()
	dpadMgr = nil

Remember to set the local variables as you need them (overall the path to the image) and
you will be good to go!

So that's it! Hope you enjoyed it!

-------------------------

Alejandro Jiménez Vilarroya
07/11/2011
	
]]


-------------------------
-- Mandatory Table
-------------------------

-- We will be storing our DPad manager in this table
local T = {}


-------------------------
-- Local variables
-------------------------

local dpadImage = "images/dpad.png"
local dpadRadius = 64
local dpadNilRadius = 10
local dpadActiveRadius = 50


-------------------------
-- Functions
-------------------------

-- Constrains the DPad inside the screen
local function fixBorders(dpad)
	if (dpad ~= nil) then
		if (dpad.x < dpadRadius) then dpad.x = dpadRadius end
		if (dpad.x > display.contentWidth - dpadRadius) then dpad.x = display.contentWidth - dpadRadius end
		if (dpad.y < dpadRadius) then dpad.y = dpadRadius end
		if (dpad.y > display.contentHeight - dpadRadius) then dpad.y = display.contentHeight - dpadRadius end
	end
end

-- Gets the angle of your touch position considering the center of the DPad
local function getAngle(dpad, event)
	if (dpad ~= nil and not pointInCircle(event.x, event.y, dpad.x, dpad.y, dpadNilRadius)) then
		return pointAngle(dpad.x, dpad.y, event.x, event.y)
	end
	return nil
end

T.getAngle = getAngle

-- Gets the magnitude of your touch position considering the center of the DPad
local function getMagnitude(dpad, event)
	if (dpad ~= nil and not pointInCircle(event.x, event.y, dpad.x, dpad.y, dpadNilRadius)) then
		return Vector2D:new(event.x - dpad.x, event.y - dpad.y)
	end
	return nil
end

T.getMagnitude = getMagnitude

-- Constrains the DPad to its Active Radius considering your touch position
local function moveToTouch(dpad, event)
	if (dpad ~= nil and not pointInCircle(event.x, event.y, dpad.x, dpad.y, dpadActiveRadius)) then
		local largeVector = Vector2D:new(event.x - dpad.x, event.y - dpad.y)
		local radiusMargin = forcesByAngle(dpadActiveRadius, getAngle(dpad, event))
		local shortVector = Vector2D:new(radiusMargin.x - dpad.x, radiusMargin.y - dpad.y)
		largeVector:sub(shortVector)
		dpad.x = largeVector.x
		dpad.y = largeVector.y
		fixBorders(dpad)
	end
end

T.moveToTouch = moveToTouch


-------------------------
-- Mandatory Constructor
-------------------------

-- Creates and returns a new DPad
local create = function(x, y)
	local dpad = display.newImageRect(dpadImage, dpadRadius*2, dpadRadius*2, false)
	dpad:setReferencePoint(display.CenterReferencePoint)
	dpad.x, dpad.y = x, y
	dpad.alpha = .4
	dpad.angle = nil
	dpad.isVisible = false
	fixBorders(dpad)
	return dpad
end

T.create = create


-------------------------
-- Mandatory Destructor
-------------------------

-- Destroys manager and local variables if any
local destroyMgr = function()

end

T.destroyMgr = destroyMgr

-- Destroys a passed dpad
local destroy = function(dpad)
	if (dpad == nil) then return end
	display.remove(dpad)
	dpad = nil
end

T.destroy = destroy


-------------------------
-- Mandatory Return
-------------------------

return T