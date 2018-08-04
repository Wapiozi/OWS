
Brick = {}
Brick.__index = Brick

function Brick:new(x, y, sizex, sizey, mean, angle, image)
	self = setmetatable({}, self)

	x, y = pcoords(x, y)
	sizex, sizey = pcoords(sizex, sizey)

	self.name = "brick"
	self.mean = mean
	self.body = love.physics.newBody(world, x, y, "static")
	self.body:setAngle(angle or 0)
	self.shape = love.physics.newRectangleShape(sizex, sizey)
	self.fixture = love.physics.newFixture(self.body, self.shape)

	self.image = image or BrickImg --image will be copied as much times as needed

	self.scale, self.width, self.height = imageProps(0.07, self.image)

	self.image:setWrap("repeat", "repeat")
	self.quad = love.graphics.newQuad(x, y, sizex, sizey, pcoords(self.width, self.height))

	self.angle = angle or 0

	self.fixture:setCategory(5)
	self.fixture:setUserData(self)

	return self
end

function Brick:draw()
	local x, y = self.body:getWorldPoints(self.shape:getPoints())
	love.graphics.draw(self.image, self.quad, x, y, self.angle)
end
