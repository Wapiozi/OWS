
Particle = {}
Particle.__index = Particle

function Particle:new(image, body)
	self = setmetatable({}, self)

	self.body = body

	self.name = "particle"

	self.partic = love.graphics.newParticleSystem(image, 1000)
	self.partic:setParticleLifetime(0.1, 0.3)
	self.partic:setEmissionRate(300)
	self.partic:setSizeVariation(0.01)
	self.partic:setLinearAcceleration(-2000, -2000, 2000, 2000)
	self.partic:setColors(255, 255, 255, 255, 255, 255, 127, 255)
	self.partic:setPosition(self.body:getPosition())
	self.partic:setRelativeRotation(true)

	self.image = image

	self.lifetime = 0
	self.prevlt = self.lifetime

	self.canDelete = false

	return self
end

function Particle:draw()

	love.graphics.setColor(1, 1, 1)
	if not self.canDelete then love.graphics.draw(self.partic) end
end

function Particle:update(dt)
	if (self.body ~= nil) and (not self.body:isDestroyed()) then
		self.partic:setPosition(self.body:getPosition())
		self.prevlt = self.lifetime
	else
		if self.partic:getEmissionRate() > 0 then self.partic:setEmissionRate(0) end
		if self.lifetime-5 > self.prevlt then self.canDelete = true end
	end
	self.partic:update(dt)
	self.lifetime = self.lifetime + dt
end
