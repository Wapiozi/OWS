Mana = {fire = 1, water = 2, air = 3, earth = 4}


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

	MagicTypeFire.Collis = function(px, py)

	end
	MagicTypeWater.Collis = function(px, py)

	end
	MagicTypeAir.Collis = function(px, py)

	end
	MagicTypeIce.Collis = function(px, py)

	end
	MagicTypeGround.Collis = function(px, py)

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


function Magic:new(x, y, vx, vy, type, owner)
	self = setmetatable({}, self)

	x, y = pcoords(x, y)

	self.type = type
	self.name = "magic"
	self.owner = owner

	self.image = self.type.image
	self.scale, self.width, self.height = imageProps(self.type.size, self.image)

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

	self.damage = self.type.Damage
	self.ricCnt = 0

	self.canDelete = false


	if type.psystem then particles:add(Particle:new(type.psystem, self.body)) end
	lights:add(flen(x), flen(y), 0.1, false, self.body, self.type.color.r, self.type.color.g, self.type.color.b)--1, 0.3, 0)

	if self.type.Init ~= nil then self.type.Init() end

	return self
end

function Magic:draw()
	if not self.canDelete then
		local x, y = self.body:getWorldPoints(self.shape:getPoints())
		love.graphics.draw(self.image, x, y, self.body:getAngle(), self.scale)
	end
end

function Magic:delete()
	self.canDelete = true
	self.fixture:destroy()
	self.shape:release()
	self.body:destroy()
end

function Magic:update(dt)

end

function Magic:collision()
	if (not self.canDelete) and (self.type.Collis ~= nil) then self.type.Collis(self.body:getX(), self.body:getY()) end
	if self.type.ricochet and self.ricCnt < self.type.maxRic then
		self.ricCnt = self.ricCnt + 1
	else
		self:delete()
	end
end
