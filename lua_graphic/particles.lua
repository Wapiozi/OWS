
Particle = {}
Particle.__index = Particle

function Particle:new(image, body, toUp, x, y, emissionTime, accel)
	self = setmetatable({}, self)

	self.body = body

	self.name = "particle"

	self.partic = love.graphics.newParticleSystem(image, 100)
	self.partic:setParticleLifetime(0.1, 0.3)
	self.partic:setEmissionRate(100)
	self.partic:setSizeVariation(0.01)
	if accel ~= nil then 
		self.partic:setLinearAcceleration(-accel, -accel, accel, accel)
	else
		self.partic:setLinearAcceleration(-2000, -2000, 2000, 2000)
	end

	self.partic:setColors(1, 1, 1, 1, 1, 1, 1, 1)
	if body ~= nil then
		self.partic:setPosition(self.body:getPosition())
	else
		self.partic:setPosition(pcoords(x, y))
	end
	self.partic:setRelativeRotation(true)

	self.image = image

	self.lifetime = 0
	self.prevlt = self.lifetime

	self.emissionTime = emissionTime or 0

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
	elseif (self.lifetime < self.emissionTime) then
		self.prevlt = self.lifetime
	else
		if self.partic:getEmissionRate() > 0 then self.partic:setEmissionRate(0) end
		if self.lifetime-5 > self.prevlt then self.canDelete = true end
	end
	self.partic:update(dt)
	self.lifetime = self.lifetime + dt
end
