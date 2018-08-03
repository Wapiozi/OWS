local tabSorter = {}

function tabSorter:__lt(next)

end

Player = {}
Player.__index = Player
Player.type = 'player'

function Player:new(x, y)
	self = setmetatable({}, self)

	x, y = pcoords(x, y)

	self.image = PlayerImg
	self.scale, self.width, self.height = imageProps(0.17, self.image)

	self.name = "player"
	self.movDirection = 0    --   1 right      -1 left      0 no
	self.side = 1            --   1 right      -1 left

	self.maxMana = 50
	self.mana = 0
	self.manaPerSecond = 20
	self.hp = 200
	self.maxHP = 200
	self.maxJumps = 2
	self.jumpCount = 0

	self.aimList = {}
	self.objCnt = 0
	self.contCallback = function(obj)
		if not obj.body:isDestroyed() then
			local curx, cury = self.body:getPosition()
		    local xx, yy = obj.body:getPosition()
			local aimChoosen = nil
		    world:rayCast(curx, cury, xx, yy, self.rayCallback)
			for i, aims in ipairs(self.aimList) do
				local obj = aims.fixture:getUserData()
				if (obj.name == "enemy") then
					if aims.fraction > 0.92 then
						if enemy_fraction ~= nil then
							if aims.fraction < enemy_fraction then
								enemy_fraction = math.min(aims.fraction, enemy_fraction)
								aimChoosen = obj
							end
						else
							local enemy_fraction = aims.fraction
							aimChoosen = obj
						end
					end
				end
			end
			return aimChoosen
		end
	end

	self.rayCallback = function(fixture, x1, y2, x2, y2, fraction)
	    local obj = fixt:getUserData()

	    if obj ~= nil and obj.name == "enemy" then
			local aims = {}
			aims.fixture = fixture
			aims.x, aims.y = x1, y1
			aims.xn, hit.yn = x2, y2
			aims.fraction = fraction

			table.insert(self.aimList, aims)
			--[[
			self.objCnt = self.objCnt + 1
			local curx, cury = self:getMagicCoords()
			curx, cury = pcoords(curx, cury)

	        self.aimList[self.objCnt] = {obj = obj, x = xx, y = yy, fraction = fraction, dist = getDist(curx, cury, xx, yy)}
			]]--
	    end
	    return 1
	end

	self.body = love.physics.newBody(world, x, y, "dynamic")  --create new dynamic body in world
	self.body:setAngle(0)
	self.body:setFixedRotation(true)
	self.shape = love.physics.newRectangleShape(pcoords(self.width, self.height))      --wizard figure
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setRestitution(0.1)
	self.fixture:setFriction(plen(0.001))
	self.body:setMass(70) -- 70kg wizard
	self.fixture:setCategory(2)
	self.fixture:setUserData(self)
	return self
end

function Player:draw()
	local x, y = self.body:getWorldPoints(self.shape:getPoints())
	if self.side == 1 then  --draw normal
		love.graphics.draw(self.image, x, y, 0, self.scale, self.scale)
	elseif self.side == -1 then  --draw mirrored
		love.graphics.draw(self.image, x+plen(self.width), y, 0, self.scale*self.side, self.scale)
	end
end

function Player:moveRight()
	if self.movDirection >= 0 then
		self.movDirection = 1
		self.side = 1
	else
		self.movDirection = 0
	end
end

function Player:moveLeft()
	if self.movDirection <= 0 then
		self.movDirection = -1
		self.side = -1
	else
		self.movDirection = 0
	end
end

function Player:jump()
	if self.jumpCount < self.maxJumps then
		local vx, vy = self.body:getLinearVelocity()
		if vy ~= 0 then self.body:setLinearVelocity(vx, 0) end
		self.body:applyLinearImpulse(0, -30000)
		--self.jumpCount = self.jumpCount + 1
	end
end

function Player:getCoords()
	local x, y = self.body:getPosition()
	return fcoords(x, y)
end

function Player:getMagicCoords()  --where magic need to spawn
	local x, y = self:getCoords()
	x = x + (self.width/2 + 0.03)*self.side
	y = y - self.height/2 + 0.05
	return x, y
end

function Player:drawHP()  --draw mana and hp lines
	local len = self.hp/self.maxHP
	local x, y, x1 = plen(0.02), plen(0.05), plen(0.2)

	love.graphics.setColor(0, 0.5, 0)
	love.graphics.rectangle("fill", x, y-plen(0.01), x1-x, plen(0.01))
	love.graphics.setColor(0, 1, 0)
	love.graphics.rectangle("fill", x, y-plen(0.01), (x1-x)*len, plen(0.01))

	local len = self.mana/self.maxMana
	local x, y, x1 = plen(0.02), plen(0.1), plen(0.2)

	love.graphics.setColor(0, 0, 0.5)
	love.graphics.rectangle("fill", x, y-plen(0.01), x1-x, plen(0.01))
	love.graphics.setColor(0, 0, 1)
	love.graphics.rectangle("fill", x, y-plen(0.01), (x1-x)*len, plen(0.01))

	love.graphics.setColor(1, 1, 1)
end

function Player:destroy()
	self.canDelete = true
	self.fixture:destroy()
	self.shape:release()
	self.body:destroy()
end

function Player:getDamage(dmg, magic)
	self.hp = self.hp-dmg
	if self.hp < 0 then self:destroy() end
end

function Player:update(dt)
	local xveloc, yveloc = self.body:getLinearVelocity()

	if (xveloc < plen(0.45)) and (self.movDirection == 1) then self.body:setLinearVelocity(plen(0.45), yveloc)
	elseif (xveloc > -plen(0.45)) and (self.movDirection == -1) then self.body:setLinearVelocity(-plen(0.45), yveloc)
	elseif (self.movDirection == 0) then
		if (xveloc > plen(0.07) ) then
			self.body:applyForce(-100000, 0)
		elseif (xveloc < plen(-0.07)) then
			self.body:applyForce(100000, 0)
		end
	end
	if self.mana < self.maxMana then
		self.mana = math.min(self.mana + self.manaPerSecond*dt, self.maxMana)
	end

	self.aimList = {}
	self.objCnt = 0
	enemies:exec(self.contCallback)
end

function Player:collidedWithFloor()
	if self.jumpCount > 0 then self.jumpCount = 0 end
end

function Player:shoot(gesture)
	local closestEnemy = self.aimList[1]

	for i = 2, self.objCnt do
		if self.aimList[i].dist < closestEnemy.dist then closestEnemy = self.aimList[i] end
	end

	local x, y = self:getMagicCoords()
	local xx, yy = pcoords(self:getMagicCoords())
	local ex, ey = closestEnemy.obj.body:getPosition()
	local vx, vy = (ex - xx)/closestEnemy.dist, (ey - yy)/closestEnemy.dist

	local i = 1
	while gesture[i] ~= 10 do   --check for end code
		if gesture[i] == 1 then

		elseif gesture[i] == 2 then
			if Magic:canShoot(self, MagicTypeGround) then bullets:add(Magic:new(x, y, vx, vy, MagicTypeGround, "player")) end
		elseif gesture[i] == 3 then
			if Magic:canShoot(self, MagicTypeWater) then bullets:add(Magic:new(x, y, vx, vy, MagicTypeWater, "player")) end
		elseif gesture[i] == 4 then
			if Magic:canShoot(self, MagicTypeFire) then bullets:add(Magic:new(x, y, vx, vy, MagicTypeFire, "player")) end
		elseif gesture[i] == 5 then

		elseif gesture[i] == 6 then
			if Magic:canShoot(self, MagicTypeAir) then bullets:add(Magic:new(x, y, vx, vy, MagicTypeAir, "player")) end
		elseif gesture[i] == 7 then

		elseif gesture[i] == 8 then
			if Magic:canShoot(self, MagicTypeIce) then bullets:add(Magic:new(x, y, 1*self.side, 0, MagicTypeIce, "player")) end
		end
		i = i+1
	end
end
