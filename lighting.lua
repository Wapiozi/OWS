Lights = {}
Lights.__index = Lights

function Lights:create()
	self = setmetatable({}, self)
	self.lightSources = {}
	self.data = {}
	
	for i = 1, 50 do
		local data = {0, 0, 0, 0}
		self.lightSources[i] = data
	end
	for i = 1, 50 do
		local data = {isFired = false, body = nil}
		self.data[i] = data
	end
	
	self.count = 0
	self.shader = love.graphics.newShader("lights.frag", "lights.vert")
	return self
end

function Lights:add(x, y, bright, isFire, fbody)
	x, y = pcoords(x, y)
	bright = plen(bright)
	local light = {x, y, 0, bright}
	
	--self.count = self.count + 1
	local place = 1
	while (place <= 50) and (self.lightSources[place][4] ~= 0) do place = place+1 end
	if place > 50 then return end
	self.lightSources[place] = light
	self.data[place].isFired = isFire
	self.data[place].body = fbody
end

function Lights:draw(camx, camy)
	for i = 1, 50 do
		if (self.data[i].body ~= nil) and (not self.data[i].body:isDestroyed()) then 
			self.lightSources[i][1] = self.data[i].body:getX()
			self.lightSources[i][2] = self.data[i].body:getY()
		elseif (self.data[i].body ~= nil) and (self.data[i].body:isDestroyed()) then
			self.lightSources[i] = {0, 0, 0, 0}
		end
	end

	self.shader:send("lights", unpack(self.lightSources))
	self.shader:send("camPos", {camx or 0, camy or 0})
	love.graphics.setShader(self.shader)
end

function Lights:endDraw()
	love.graphics.setShader(self.shader)
end

function Lights:setLightPosition(ind, x, y)
	x, y = pcoords(x, y)
	
	self.lightSources[ind][1] = x
	self.lightSources[ind][2] = y
end
