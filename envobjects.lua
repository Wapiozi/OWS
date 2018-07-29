EnvObject = {}
EnvObject.__index = EnvObject

function EnvObject:new(x, y, image, canBeMoved, mass)
    self = setmetatable({}, self)

	x, y = pcoords(x, y)

    self.image = image
    self.scale, self.width, self.height = imageProps(0.3, self.image)

	self.name = "EnvObject"
    if canBeMoved then
        self.body = love.physics.newBody(world, x, y, "dynamic")
    else
        self.body = love.physics.newBody(world, x, y, "static")
    end
	self.shape = love.physics.newRectangleShape(pcoords(self.width, self.height))
	self.fixture = love.physics.newFixture(self.body, self.shape)

	self.angle = angle or 0

    self.body:setMass(mass)

	self.fixture:setCategory(16)
	self.fixture:setUserData(self)

    self.canDelete = false

	return self

end

function EnvObject:draw()
    if not self.canDelete then
		local x, y = self.body:getWorldPoints(self.shape:getPoints())
		love.graphics.draw(self.image, x, y, self.body:getAngle(), self.scale)
	end
end
