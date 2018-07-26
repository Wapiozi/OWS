Lights = {}
Lights.__index = Lights

function Lights:create()
	self = setmetatable({}, self)
	self.lightSources = {}
	
	self.bodies = {}
	self.bodCnt = 0
	
	self.lines = {}   --x, y, xv, yv
	self.lineCnt = 0
	
	self.data = {}
	
	self.triGl = nil
	self.triCnt = 0
	
	self.shadowThread = love.thread.newThread("lightsCalc.lua")
	
	for i = 1, 50 do
		local data = {0, 0, 0, 0}   --{x, y, 0, bright}
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
	
	self.lightss = self.lightSources
end

function Lights:getLines()
	for i = 1, self.bodCnt do 
		local x1, y1, x2, y2, x3, y3, x4, y4 = self.bodies[i].body:getWorldPoints(self.bodies[i].shape:getPoints())
		
		self.lineCnt = self.lineCnt + 1
		self.lines[self.lineCnt] = {x = x1, y = y1, xv = x2, yv = y2}
		
		self.lineCnt = self.lineCnt + 1
		self.lines[self.lineCnt] = {x = x2, y = y2, xv = x3, yv = y3}
		
		self.lineCnt = self.lineCnt + 1
		self.lines[self.lineCnt] = {x = x3, y = y3, xv = x4, yv = y4}
		
		self.lineCnt = self.lineCnt + 1
		self.lines[self.lineCnt] = {x = x4, y = y4, xv = x1, yv = y1}
	end
end

function Lights:addBody(obj)
	if obj ~= nil then 
		self.bodCnt = self.bodCnt + 1
		self.bodies[self.bodCnt] = obj
	end
end

function Lights:draw(camx, camy)
	self.shadowThread:wait()
	self.lineCnt = 0
	
	self.triGl = love.thread.getChannel("triangles"):pop()
	self.triCnt = love.thread.getChannel("triangCnt"):pop()
	if self.triCnt ~= nil then self.lightss = love.thread.getChannel("lights"):pop() end

	self.shader:send("triangles", unpack(self.triGl or self.lightss))
	self.shader:send("lights", unpack(self.lightss))
	self.shader:send("camPos", {camx or 0, camy or 0})
	love.graphics.setShader(self.shader)
end

function Lights:endDraw()
	love.graphics.setShader()
	self:getLines()
	for i = 1, 50 do
		if (self.data[i].body ~= nil) and (not self.data[i].body:isDestroyed()) then 
			self.lightSources[i][1] = self.data[i].body:getX()
			self.lightSources[i][2] = self.data[i].body:getY()
		elseif (self.data[i].body ~= nil) and (self.data[i].body:isDestroyed()) and (self.lightSources[i][4] > 0) then
			self.lightSources[i] = {0, 0, 0, 0}
		end
	end
	self.shadowThread:start(self.lines, self.lineCnt, self.lightSources)
end

function Lights:setLightPosition(ind, x, y)
	x, y = pcoords(x, y)
	
	self.lightSources[ind][1] = x
	self.lightSources[ind][2] = y
end

function Lights:addBodyFunc()
	tabl = self
	return function(obj)
		if obj then tabl:addBody(obj) end
	end
end
