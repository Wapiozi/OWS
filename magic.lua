Magic = {}
Magic.__index = Magic

function Magic:new(x, y, vx, vy, type, dmg)
	self = setmetatable({}, self)
	
	self.body = love.physics.newBody(world, x, y, "dynamic")
	self.body:setMass(1)
	self.body:setBullet(true)
	
	
	self.shape = love.physics.newRectangleShape(20, 20)
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setRestitution(0)
	self.fixture:setFriction(0.1)
	
	self.type = type
	self.damage = dmg
	
	self.image = love.graphics.newImage("Fireball.png")
	
	self.shader = shad
	
	self.body:applyLinearImpulse(1000*vx, 1000*vy)
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
