------------------Magic----------------------------------------------------

--[[
	magicType.type
		1 - ballistic
		2 - ballistic shotgun
		3 - laser
		4 - area

]]

Magic = {}
Magic.__index = Magic

function Magic:init()
	MagicTypeFire = {
		type = 1,
		image = FireballImg,
		color = { r = 1, g = 0.3, b = 0.0},
		psystem = FireImg, --ParticleSystem
		size = 0.028,
		Damage = 10,
		ImpulseCoef = 50000, --speed of magic
		mass = 1,
		mana = 10, --used mana
		aim = true,
		Init = nil,  --magic type function. Is called when created
		Collis = nil --magic type function. Is called when collided with anything else
	}

	MagicTypeWater = {
		type = 1,
		image = WaterballImg,
		color = { r = 0.01, g = 0.01, b = 0.41},
		psystem = FireImg,
		size = 0.0417,
		Damage = 25,
		ImpulseCoef = 5000,
		mass = 5,
		mana = 20,
		aim = true,
		Init = nil,
		Collis = nil
	}

	MagicTypeAir = {
		type = 1,
		image = AirballImg,
		color = { r = 0.05, g = 0.05, b = 0.05},
		psystem = FireImg,
		size = 0.0417,
		Damage = 5,
		ImpulseCoef = 500000,
		mass = 0.1,
		mana = 5,
		aim = true,
		Init = nil,
		Collis = nil
	}

	MagicTypeIce = {
		type = 1,
		image = IceballImg,
		color = { r = 0.01, g = 0.01, b = 0.56},
		psystem = FireImg,
		size = 0.02,
		Damage = 15,
		ImpulseCoef = 100000,
		mass = 2,
		mana = 10,
		aim = false,
		ricochet = true,
		maxRic = 2,
		Init = nil,
		Collis = nil
	}

	MagicTypeGround = {
		type = 1,
		image = GroundballImg,
		color = { r = 0.01, g = 0.54, b = 0.01},
		psystem = FireImg,
		size = 0.0347,
		Damage = 40,
		ImpulseCoef = 25000,
		mass = 20,
		mana = 20,
		aim = false,
		ricochet = false,
		Init = nil,
		Collis = nil
	}

	MagicTypeTinyLaser = {
		type = 3,
		image = LaserImg,
		color = { r = 1, g = 0, b = 0},
		psystem = FireeImg,
		size = 0.01,
		Damage = 101,
		mana = 50,
		fade = 1, -- 1 second to fade
		maxLen = 3,
		aim = true,
		ricochet = false,
		Init = nil,
		Collis = nil
	}

	MagicTypeFuckingExplosion = {
		type = 4,
		color = {r = 1, g = 1, b = 1},
		psystem = FireImg,
		radius = 0.2,
		Damage = 10,
		mana = 20,
		fade = 5,
		aim = false,
		ricochet = false,
		Init = nil,
		Collis = nil
	}

	MagicTypeFire.Collis = function(px, py)

	end

	MagicTypeGround.Collis = function(px, py)
		px, py = fcoords(px, py)
		bullets:add(Magic:new(px, py, 0, 0, MagicTypeFuckingExplosion))
	end

	MagicTypeTinyLaser.Collis = function(fixt, x, y, xn, yn, fraction)
		obj = fixt:getUserData()

		if obj ~= nil and obj.name ~= nil then
			if obj.name == "player" or obj.name == "enemy" then
				obj:getDamage(MagicTypeTinyLaser.Damage)
			end
		end

		x, y = fcoords(x, y)
		particles:add(Particle:new(MagicTypeTinyLaser.psystem, nil, false, x, y, 0.1))
		return 1
	end

	MagicTypeFuckingExplosion.Collis = function(fixt)
		obj = fixt:getUserData()

		if obj ~= nil and obj.name ~= nil then
			if obj.name == "player" or obj.name == "enemy" then
				obj:getDamage(MagicTypeFuckingExplosion.Damage)
			end
		end

		return true
	end

end

function Magic:canShoot(player, magicType)
	if player.mana ~= nil and magicType.mana ~= nil then
		if player.mana >= magicType.mana then
			player.mana = player.mana - magicType.mana
			return magicType.aim, true
		end
	end
	return magicType.aim, false
end

function Magic:ballisticInit(x, y, vx, vy, type)
	self.body = love.physics.newBody(world, x, y, "dynamic")
	self.body:setBullet(true)
	self.shape = love.physics.newRectangleShape(pcoords(self.width, self.height))
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setRestitution(1.5)
	self.fixture:setFriction(1)
	self.body:setMass(type.mass)
	self.body:applyLinearImpulse(self.type.ImpulseCoef*vx, self.type.ImpulseCoef*vy)
	self.body:applyAngularImpulse(math.random(1000)+1000)
	self.body:setAngle(45)
	self.fixture:setCategory(6)
	self.fixture:setUserData(self)
	if type.psystem then particles:add(Particle:new(type.psystem, self.body)) end
	lights:add(flen(x), flen(y), 0.1, false, self.body, self.type.color.r, self.type.color.g, self.type.color.b)
end

function Magic:laserInit(x, y, vx, vy, type, scale)
	self.quad = love.graphics.newQuad(x, y, plen(type.maxLen), plen(type.size), scale, scale)

	self.x = x
	self.y = y
	self.vx = vx
	self.vy = vy
	self.alphaCol = 1
	self.lifetime = 0

	world:rayCast(x, y, x + plen(self.type.maxLen)*vx, y + plen(self.type.maxLen)*vy, type.Collis)

	if (vx < 0) and (vy >= 0) then
		vx = -vx
		self.angle = math.atan(vx/vy) + math.pi/2
	elseif (vx < 0) and (vy < 0) then
		vx = -vx
		vy = -vy
		self.angle = math.atan(vy/vx) + math.pi
	elseif (vx >= 0) and (vy < 0) then
		vy = -vy
		self.angle = math.atan(vx/vy) + math.pi + math.pi/2
	elseif (vx >= 0) and (vy >= 0) then
		self.angle = math.atan(vy/vx)
	end
end

function Magic:areaInit(x, y, type)
	world:queryBoundingBox(x - plen(type.radius), y - plen(type.radius), x + plen(type.radius), y + plen(type.radius), type.Collis)

	self.lifetime = 0

	x, y = fcoords(x, y)
	particles:add(Particle:new(type.psystem, nil, false, x, y, 0.1, 10000))
end


function Magic:new(x, y, vx, vy, type, owner)
	self = setmetatable({}, self)

	x, y = pcoords(x, y)

	self.type = type
	self.name = "magic"
	self.owner = owner

	if self.type.Init ~= nil then self.type.Init() end

	self.image = self.type.image
	if self.image ~= nil then self.scale, self.width, self.height = imageProps(self.type.size, self.image) end

	if type.type == 1 then
		self:ballisticInit(x, y, vx, vy, self.type)
	elseif type.type == 3 then
		self:laserInit(x, y, vx, vy, self.type, self.scale)
	elseif type.type == 4 then
		self:areaInit(x, y, self.type)
	end

	self.damage = self.type.Damage
	self.ricCnt = 0

	self.canDelete = false

	return self
end

function Magic:draw()
	if not self.canDelete then
		if self.type.type == 1 then
			local x, y = self.body:getWorldPoints(self.shape:getPoints())
			love.graphics.draw(self.image, x, y, self.body:getAngle(), self.scale)
		elseif self.type.type == 3 then
			local r, g, b, a = love.graphics.getColor()
			love.graphics.setColor(self.alphaCol, self.alphaCol, self.alphaCol, 1)
			love.graphics.draw(self.image, self.quad, self.x, self.y, self.angle)
			--love.graphics.line(self.x, self.y, self.x + plen(self.type.maxLen*self.vx), self.y + plen(self.type.maxLen*self.vy))
			love.graphics.setColor(r, g, b, a)
		end
	end
end

function Magic:delete()
	self.canDelete = true
	if self.fixture ~= nil then self.fixture:destroy() end
	if self.shape ~= nil then self.shape:release() end
	if self.body ~= nil then self.body:destroy() end
	if self.quad ~= nil then self.quad:release() end
end

function Magic:update(dt)
	if self.type.type == 3 then
		self.lifetime = self.lifetime + dt

		self.alphaCol = math.max(self.type.fade - self.lifetime, 0)/self.type.fade

		if self.alphaCol == 0 then self:delete() end
	elseif self.type.type == 4 then
		self.lifetime = self.lifetime + dt
		if self.lifetime > self.type.fade then self:delete() end
	end
end

function Magic:collision()
	if (not self.canDelete) and (self.type.Collis ~= nil) then self.type.Collis(self.body:getX(), self.body:getY()) end
	if self.type.ricochet and self.ricCnt < self.type.maxRic then
		self.ricCnt = self.ricCnt + 1
	else
		self:delete()
	end
end
