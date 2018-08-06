Traps = {}
Traps.__index = Traps

function Traps:init()
    TrapTypeSpikes = {
        image = SpikeImg,
        damage = 10,
        move = "static",
        reload = 1,
        Collis = nil
    }
end

function Traps:new(x, y, type)
    self = setmetatable({}, self)

    x, y = pcoords(x, y)

    self.type = type
    self.image = type.image
	self.scale, self.width, self.height = imageProps(0.05, self.image)

	self.name = "trap"
	self.body = love.physics.newBody(world, x, y, type.move)
	self.shape = love.physics.newRectangleShape(pcoords(self.width, self.height))
	self.fixture = love.physics.newFixture(self.body, self.shape)

    self.lt = 0
    self.maxTime = type.reload

    self.fixture:setUserData(self)

    return self
end

function Traps:update(dt)
    self.lt = math.min(self.lt + dt, self.maxTime)
end

function Traps:attack(obj)
    if self.lt >= self.maxTime then
        obj.body:applyLinearImpulse(1000, -20000)
        return self.type.damage
    end
    return 0
end

function Traps:draw()
    if self.body ~= nil then
        local x, y = self.body:getWorldPoints(self.shape:getPoints())
        love.graphics.draw(self.image, x, y, self.body:getAngle(), self.scale)
    end
end
