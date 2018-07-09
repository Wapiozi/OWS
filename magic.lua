Magic = {}
Magic.__index = Magic

function Magic:new(x, y, vx, vy, type)
	self = setmetatable({}, self)
	
	self.body = love.physics.newBody(world, x, y, "kinematic")
	self.body:setMass(1)
	self.body:setBullet(true)
	self.body:applyLinearImpulse(1000*vx, 1000*vy)
	
	self.shape = love.physics.newRectangleShape(20, 20)
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setRestitution(1)
	self.fixture:setFriction(5)
	
	self.type = type
end

function Magic:draw()
	love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end
