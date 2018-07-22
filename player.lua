Player = {}
Player.__index = Player
Player.type = 'player'

function Player:new(mana, x, y)
	self = setmetatable({}, self)
	
	x, y = pcoords(x, y)
	
	self.image = PlayerImg
	self.scale, self.width, self.height = imageProps(0.17, self.image)
	
	self.magic_delay = md or 1
	self.magic_fire  = Mana[fire] or 0
	self.magic_water = Mana[water] or 0
	self.magic_air   = Mana[air] or 0
	self.magic_earth = Mana[earth] or 0
	
	self.name = "player"
	self.hp = 200
	self.maxHP = 200
	self.movDirection = 0    --   1 right      -1 left      0 no
	self.side = 1            --   1 right      -1 left
	
	self.body = love.physics.newBody(world, x, y, "dynamic")  --create new dynamic body in world
	self.body:setAngle(0)
	self.body:setFixedRotation(true)
	self.shape = love.physics.newRectangleShape(pcoords(self.width, self.height))      --wizard figure
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setRestitution(0.1)
	self.fixture:setFriction(0)
	self.body:setMass(70) -- 70kg wizard
	self.fixture:setUserData(self)
	--lights:add(flen(x), flen(y), 1, false, self.body)
	return self
end

function Player:draw()
	--love.graphics.draw(PlayerImg, 100, 100)
	-- by now, it is only like that :P
	local x, y = self.body:getWorldPoints(self.shape:getPoints())
	if self.side == 1 then 
		love.graphics.draw(self.image, x, y, 0, self.scale, self.scale)
	elseif self.side == -1 then
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
	local vx, vy = self.body:getLinearVelocity()
	if vy ~= 0 then self.body:setLinearVelocity(vx, 0) end 
	self.body:applyLinearImpulse(0, -30000)
end

function Player:updateSpeed()
	local xveloc, yveloc = self.body:getLinearVelocity()
	
	if (xveloc < plen(0.45)) and (self.movDirection == 1) then self.body:applyForce(1000000, 0) 
	elseif (xveloc > -plen(0.45)) and (self.movDirection == -1) then self.body:applyForce(-1000000, 0) 
	elseif (self.movDirection == 0) then
		if (xveloc > 5) then 
			self.body:applyForce(-100000, 0)
		elseif (xveloc < -5) then 
			self.body:applyForce(100000, 0)
		end
	end
	
end

function Player:getCoords()
	local x, y = self.body:getPosition()
	return fcoords(x, y)
end

function Player:getMagicCoords()
	local x, y = self:getCoords()
	x = x + (self.width/2 + 0.03)*self.side
	y = y - self.height/2 + 0.05
	return x, y
end

function Player:drawHP()
	local len = self.hp/self.maxHP
	
	local x, y, x1 = plen(0.02), plen(0.05), plen(0.2)
	
	love.graphics.setColor(0, 0.5, 0)
	love.graphics.rectangle("fill", x, y-plen(0.01), x1-x, plen(0.01))

	love.graphics.setColor(0, 1, 0)
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
