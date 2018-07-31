EnvObject = {}
EnvObject.__index = EnvObject

function EnvObject:new(x, y, image, canBeMoved, mass, height)
    self = setmetatable({}, self)

	x, y = pcoords(x, y)

    self.image = image
    self.scale, self.width, self.height = imageProps(height, self.image)

	self.name = "EnvObject"
    if canBeMoved then
        self.body = love.physics.newBody(world, x, y, "dynamic")
    else
        self.body = love.physics.newBody(world, x, y, "static")
    end
	self.shape = love.physics.newRectangleShape(pcoords(self.width, self.height))
	self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setFriction(plen(0.1))
    self.body:setMass(mass)
	self.fixture:setCategory(16)
	self.fixture:setUserData(self)

    self.angle = angle or 0
    self.canDelete = false
    self.state = false --off

	return self

end

function EnvObject:draw()
    if not self.canDelete then
		local x, y = self.body:getWorldPoints(self.shape:getPoints())
		love.graphics.draw(self.image, x, y, self.body:getAngle(), self.scale)
	end
end

function EnvObject:interact()
    if self.state then self.state = false else self.state = true end

end

function EnvObject:update(dt)

end

Torch = {}
Torch.__index = Torch

function Torch:new(x, y)
    self = EnvObject:new(x, y, TorchImg, true, 5, 0.05)
    self.__index = self
    self = setmetatable({}, self)
    lights:add(x, y, 0.01, true, self.body, 1, 0.7, 0.05)
    return self
end
