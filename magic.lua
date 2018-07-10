Magic = {}
Magic.__index = Magic

function Magic:init()
	MagicTypeFire = {
		image = FireballImg,
		shader = shad,
		size = 20,
		Restitution = 0,
		Friction = 0.1,
		Damage = 10,
		ImpulseCoef = 1000,
		mass = 1,
		Init = nil,  --magic type function. Is called when created
		Collis = nil --magic type function. Is called when collided with anything else
	}
end

function Magic:new(x, y, vx, vy, type, dmg)
	self = setmetatable({}, self)
	
	self.type = type
	
	self.body = love.physics.newBody(world, x, y, "dynamic")
	self.body:setMass(type.mass)
	self.body:setBullet(true)
	
	
	self.shape = love.physics.newRectangleShape(type.size, type.size)
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setRestitution(type.Restitution)
	self.fixture:setFriction(type.Friction)
	
	self.damage = self.type.Damage
	
	self.image = type.image
	self.shader = self.type.shader
	
	self.body:applyLinearImpulse(self.type.ImpulseCoef*vx, self.type.ImpulseCoef*vy)
	self.body:setAngle(45)
	
	return self
end

function Magic:draw()
	local x, y = self.body:getWorldPoints(self.shape:getPoints())
	--local x, y = self.body:getPosition()
	love.graphics.draw(self.image, x, y, self.body:getAngle())
	--love.graphics.setColor(0.8, 1, 0.01)
	--love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end

MagicCont = {}
MagicCont.__index = MagicCont

function MagicCont:new()
	self = setmetatable({}, self)
	
	self.list = nil
	
	return self
end

function MagicCont:add(val)
	self.list = {next = self.list, value = val}
end

function MagicCont:CheckDraw()
	local tmp = self.list
	
	
	while tmp ~= nil do 
		love.graphics.setShader(tmp.value.shader)
		tmp.value:draw()
		love.graphics.setShader()
		tmp = tmp.next
	end
end
