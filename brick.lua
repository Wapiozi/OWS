
Brick = {}
Brick.__index = Brick

function Brick:new(x, y, sizex, sizey, angle, image) 
	self = setmetatable({}, self)
	
	x, y = pcoords(x, y)
	sizex, sizey = pcoords(sizex, sizey)
	
	self.name = "brick"
	
	self.body = love.physics.newBody(world, x, y, "static")
	self.body:setAngle(angle or 0)
	self.shape = love.physics.newRectangleShape(sizex, sizey)
	self.fixture = love.physics.newFixture(self.body, self.shape)
	
	self.image = image
	self.shader = nil
	
	return self
end

function Brick:draw()
	love.graphics.setColor(0.5, 0.9, 0.1)
	love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end

