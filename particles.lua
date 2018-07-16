
Particle = {}
Particle.__index = Particle

function Particle:new(x, y, lifetmin, lifetmax, image) 
	self = setmetatable({}, self)
	
	self.name = "particle"
	
	self.partic = love.graphics.newParticleSystem(image, 1000)
	self.partic:setParticleLifetime(lifetmin, lifetmax)
	self.partic:setEmissionRate(300)
	self.partic:setSizeVariation(0.01)
	self.partic:setLinearAcceleration(-2000, -2000, 2000, 2000)
	self.partic:setColors(255, 255, 255, 255, 255, 255, 127, 255)
	self.partic:setPosition(x, y)
	
	self.image = image
	self.shader = nil
	
	self.lifetime = 0
	
	self.canDelete = false
	
	return self
end

function Particle:draw()
	love.graphics.setColor(1, 1, 1)
	if not self.canDelete then love.graphics.draw(self.partic) end
end

function Particle:update(dt)
	self.partic:update(dt)
	self.lifetime = self.lifetime + 1
	
	if self.lifetime > 5 then
		self.canDelete = true
	end
end
