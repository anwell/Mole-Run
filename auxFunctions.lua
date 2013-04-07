-------------------------
-- Math
-------------------------

-- Distance between two given points
function pointDistance(xA, yA, xB, yB)
    local xDistance = xB - xA
	local yDistance = yB - yA
	
    return math.sqrt((xDistance * xDistance) + (yDistance * yDistance))
end

-- Is a point inside a circle?
function pointInCircle(xA, yA, xCircle, yCircle, radiusCircle)
	return (pointDistance(xCircle, yCircle, xA, yA) <= radiusCircle)
end

-- Horizontal angle between two given points
function pointAngle(xA, yA, xB, yB)
	local angle = math.atan2(yB - yA, xB - xA)
	
	if (angle < 0) then
        angle = math.abs(angle)
    else
        angle = 2 * math.pi - angle
	end
	
	return math.deg(angle)
end

-- Forces to apply based on total force and desired angle
function forcesByAngle(totalForce, angle)
	local forces = {}
	local radians = -math.rad(angle)
	
	forces.x = math.cos(radians) * totalForce
	forces.y = math.sin(radians) * totalForce
	
	return forces
end