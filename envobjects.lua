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
    --self.fixture:setFriction(plen(0.1))
    self.body:setMass(mass)
	self.fixture:setCategory(16)
	self.fixture:setUserData(self)
    self.obstacle = true

    self.angle = angle or 0
    self.canDelete = false
    self.state = false --off
    self.canInteract = false

	return self

end

function EnvObject:draw()
    if not self.canDelete then
		local x, y = self.body:getWorldPoints(self.shape:getPoints())
		love.graphics.draw(self.image, x, y, self.body:getAngle(), self.scale)
	end
end

function EnvObject:interact(obj)
    if self.state then self.state = false else self.state = true end
end

function EnvObject:update(dt)

end

Torch = {}
Torch.__index = Torch

function Torch:new(x, y)
    self = setmetatable({}, self)

	x, y = pcoords(x, y)

    self.image = TorchImg
    self.scale, self.width, self.height = imageProps(0.05, self.image)

	self.name = "EnvObject"
    self.body = love.physics.newBody(world, x, y, "dynamic")
	self.shape = love.physics.newRectangleShape(pcoords(self.width, self.height))
	self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setFriction(plen(0.1))
    self.body:setMass(5)
	self.fixture:setCategory(16)
    self.obstacle = true
	self.fixture:setUserData(self)

    self.angle = angle or 0
    self.canDelete = false
    self.state = false --off
    self.canInteract = false
    self.attachedBody = nil
    self.joint = nil
    lights:add(x, y, 0.01, true, self.body, 1, 0.7, 0.05)
    return self
end

function Torch:interact(obj)
    if self.state then self.state = false elseif (not self.state) and self.canInteract then self.state = true end

    if self.state then
        self.fixture:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
        self.obstacle = false
        self.body:setAngle(0)
        local _, _, x, y = obj.body:getWorldPoints(obj.shape:getPoints())
        self.body:setPosition(x, y+plen(0.05))
        self.joint = love.physics.newRevoluteJoint(obj.body, self.body, x, y)
        self.joint:setLimitsEnabled(true)
        self.joint:setLimits(-1, 1)
    elseif self.joint ~= nil and (not self.joint:isDestroyed()) then
        self.obstacle = true
        self.joint:destroy()
        self.fixture:setMask()
    end
end

function Torch:draw()
    if not self.canDelete then
		local x, y = self.body:getWorldPoints(self.shape:getPoints())
		love.graphics.draw(self.image, x, y, self.body:getAngle(), self.scale)
	end
end
