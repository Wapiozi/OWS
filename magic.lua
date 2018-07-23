Mana = {fire = 1, water = 2, air = 3, earth = 4}


------------------Magic----------------------------------------------------

Magic = {}
Magic.__index = Magic

function Magic:init()
	MagicTypeFire = {
		image = FireballImg,
		shader = FireShader,
		psystem = FireImg, --ParticleSystem
		size = 0.028,
		Restitution = 0,
		Friction = 0.1,
		Damage = 10,
		Reload = 2,
		ImpulseCoef = 1000,
		mass = 1,
		Init = nil,  --magic type function. Is called when created
		Collis = nil --magic type function. Is called when collided with anything else
	}
	
	MagicTypeWater = {
		image = WaterballImg,
		shader = WaterShader,
		psystem = nil,
		size = 0.0417,
		Restitution = 0,
		Friction = 100,
		Damage = 25,
		Reload = 3,
		ImpulseCoef = 100,
		mass = 5,
		Init = nil,
		Collis = nil
	}
	
	MagicTypeAir = {
		image = AirballImg,
		shader = AirShader,
		psystem = nil,
		size = 0.0417,
		Restitution = 0,
		Friction = 0.01,
		Damage = 5,
		Reload = 0.5,
		ImpulseCoef = 10000,
		mass = 0.1,
		Init = nil,
		Collis = nil
	}
	
	MagicTypeIce = {
		image = IceballImg,
		shader = IceShader,
		psystem = nil,
		size = 0.02,
		Restitution = 0.7,
		Friction = 0.01,
		Damage = 15,
		Reload = 1,
		ImpulseCoef = 2000,
		mass = 2,
		Init = nil,
		Collis = nil
	}
	
	MagicTypeGround = {
		image = GroundballImg,
		shader = nil,
		psystem = nil,
		size = 0.0347,
		Restitution = 0.4,
		Friction = 4,
		Damage = 40,
		Reload = 4,
		ImpulseCoef = 500,
		mass = 20,
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
	self.reload = self.type.Reload
	
	self.shader = self.type.shader
	
	self.Collis = function()
		if (not self.canDelete) and (self.type.Collis ~= nil) then self.type.Collis(self.body:getX(), self.body:getY()) end
	end
	
	if self.type.Init ~= nil then self.type.Init() end 
	
	self.body:applyLinearImpulse(self.type.ImpulseCoef*vx, self.type.ImpulseCoef*vy)
	self.body:setAngle(45)
	
	self.fixture:setUserData(self)
	
	--[[
	self.partic = love.graphics.newParticleSystem(FireImg, 1000)
	self.partic:setParticleLifetime(0.1, 0.3)
	self.partic:setEmissionRate(300)
	self.partic:setSizeVariation(0.01)
	self.partic:setLinearAcceleration(-2000, -2000, 2000, 2000)
	self.partic:setColors(255, 255, 255, 255, 255, 255, 127, 255)
	self.partic:setPosition(x, y)
	self.partic:setRelativeRotation(true)
	]]--
	
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
