Mana = {fire = 1, water = 2, air = 3, earth = 4}


------------------Magic----------------------------------------------------

Magic = {}
Magic.__index = Magic

function Magic:init()
	MagicTypeFire = {
		image = FireballImg,
		shader = FireShader,
		psystem = nil, --ParticleSystem
		size = 20,
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
		size = 30,
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
		size = 30,
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
		size = 15,
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
		size = 25,
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
		particles:add(Particle:new(px, py, 0.1, 0.3, FireballImg))
	end
end

function Magic:new(x, y, vx, vy, type, dmg, owner)
	self = setmetatable({}, self)
	
	x, y = pcoords(x, y)
	
	self.type = type
	self.name = "magic"
	self.owner = owner
	
	self.body = love.physics.newBody(world, x, y, "dynamic")
	self.body:setMass(type.mass)
	self.body:setBullet(true)
	
	
	self.shape = love.physics.newRectangleShape(type.size, type.size)
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setRestitution(type.Restitution)
	self.fixture:setFriction(type.Friction)
	
	self.damage = self.type.Damage
	self.reload = self.type.Reload
	
	self.image = self.type.image
	self.shader = self.type.shader
	
	self.Collis = function()
		if not self.canDelete then self.type.Collis(self.body:getX(), self.body:getY()) end
	end
	
	if self.type.Init ~= nil then self.type.Init() end 
	
	self.body:applyLinearImpulse(self.type.ImpulseCoef*vx, self.type.ImpulseCoef*vy)
	self.body:setAngle(45)
	
	self.fixture:setUserData(self)
	
	self.canDelete = false
	
	return self
end

function Magic:draw()
	local x, y = self.body:getWorldPoints(self.shape:getPoints())
	--local x, y = self.body:getPosition()
	love.graphics.draw(self.image, x, y, self.body:getAngle())
	--love.graphics.setColor(0.8, 1, 0.01)
	--love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end

function Magic:delete()
	self.canDelete = true
	self.fixture:destroy()
	self.shape:release()
	self.body:destroy()
end



