-------------------------
-- Mandatory Table
-------------------------

-- We will be storing our Player manager in this table
local T = {}


-------------------------
-- Aux Functions
-------------------------

-- Moves the player using its constant speed and a passed angle
local move = function(player)
	-- if (angle == nil) then
	-- 	player:setLinearVelocity(0, 0)
	-- 	return
	-- end
	
	-- local forces = forcesByAngle(player.walkSpeed, angle)
	-- player:setLinearVelocity(forces.x, forces.y)
	-- player.rotation = -angle
	local direction = player.direction
	if direction == 0 then 
		transition.to(player, {time=SPEED, x=player.x + 26, y= player.y})
	elseif direction == 1 then
		transition.to(player, {time=SPEED, x=player.x, y= player.y - 26})
	elseif direction == 2 then
		transition.to(player, {time=SPEED, x=player.x - 26, y= player.y})
	elseif direction == 3 then
		transition.to(player, {time=SPEED, x=player.x, y= player.y + 26})
	end
end

T.move = move


-------------------------
-- Mandatory Constructor
-------------------------

-- Creates and returns a new player
local create = function(tileSize, x, y)
	local playerSheet = sprite.newSpriteSheet("images/mole3.png", tileSize, tileSize)
	local playerSet = sprite.newSpriteSet (playerSheet, 1, 21)
	local player = sprite.newSprite(playerSet)
	sprite.add (playerSet, "playerleft", 8, 2, 100, 0)
	sprite.add (playerSet, "playerright", 1, 2, 100, 0)
	sprite.add (playerSet, "playerdead", 15, 7, 100, 1)
	player.state = STATE_IDLE
	player.direction = DIRECTION_RIGHT
	player.lives = 3
	player:prepare("playerright")
	
	player.x, player.y = x, y
	
	return player
end

T.create = create


-------------------------
-- Mandatory Destructor
-------------------------

-- Destroys manager and local variables if any
local destroyMgr = function()

end

T.destroyMgr = destroyMgr

-- Destroys a passed player
local destroy = function(player)
	if (player == nil) then return end
	display.remove(player)
	player = nil
end

T.destroy = destroy


-------------------------
-- Mandatory Return
-------------------------

return T