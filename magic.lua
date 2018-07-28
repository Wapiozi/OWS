Mana = {fire = 1, water = 2, air = 3, earth = 4}


------------------Magic----------------------------------------------------

Magic = {}
Magic.__index = Magic

function Magic:init()
	MagicTypeFire = {
		image = FireballImg,
		psystem = FireImg, --ParticleSystem
		size = 0.028,
		Restitution = 0,
		Friction = 0.1,
		Damage = 10,
		ImpulseCoef = 1000, --speed of magic
		mass = 1,
		mana = 10, --used mana
		Init = nil,  --magic type function. Is called when created
		Collis = nil --magic type function. Is called when collided with anything else
	}

	MagicTypeWater = {
		image = WaterballImg,
		psystem = nil,
		size = 0.0417,
		Restitution = 0,
		Friction = 100,
		Damage = 25,
		ImpulseCoef = 100,
		mass = 5,
		mana = 20,
		Init = nil,
		Collis = nil
	}

	MagicTypeAir = {
		image = AirballImg,
		psystem = nil,
		size = 0.0417,
		Restitution = 0,
		Friction = 0.01,
		Damage = 5,
		ImpulseCoef = 10000,
		mass = 0.1,
		mana = 5,
		Init = nil,
		Collis = nil
	}

	MagicTypeIce = {
		image = IceballImg,
		psystem = nil,
		size = 0.02,
		Restitution = 0.7,
		Friction = 0.01,
		Damage = 15,
		ImpulseCoef = 2000,
		mass = 2,
		mana = 10,
		Init = nil,
		Collis = nil
	}

	MagicTypeGround = {
		image = GroundballImg,
		psystem = nil,
		size = 0.0347,
		Restitution = 0.4,
		Friction = 4,
		Damage = 40,
		ImpulseCoef = 500,
		mass = 20,
		mana = 20,
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
	self.fixture:setRestitution(type.Restitution)
	self.fixture:setFriction(type.Friction)

	self.body:setMass(type.mass)

	self.damage = self.type.Damage

	self.Collis = function()
		if (not self.canDelete) and (self.type.Collis ~= nil) then self.type.Collis(self.body:getX(), self.body:getY()) end
	end

	if self.type.Init ~= nil then self.type.Init() end

	self.body:applyLinearImpulse(self.type.ImpulseCoef*vx, self.type.ImpulseCoef*vy)
	self.body:setAngle(45)

	self.fixture:setCategory(6)
	self.fixture:setUserData(self)

	particles:add(Particle:new(FireImg, self.body))

	self.canDelete = false

	lights:add(flen(x), flen(y), 0.05, false, self.body)

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
	self.partic = nil
end

function Magic:update(dt)
	if self.partic ~= nil then self.partic:update(dt) end
end

function Magic:canShoot(player, magicType)
	if player.mana ~= nil and magicType.mana ~= nil then
		if player.mana >= magicType.mana then
			player.mana = player.mana - magicType.mana
			return true
		end
	end
	return false
end
