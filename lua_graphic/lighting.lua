Lights = {}
Lights.__index = Lights

function Lights:create()
	self = setmetatable({}, self)
	self.lightSources = {}
	self.data = {}
	self.colors = {}

	self.bodies = {}
	self.bodCnt = 0

	self.lines = {}   --x, y, xv, yv
	self.lineCnt = 0

	self.shapes = {}
	self.shapeCnt = 0

	self.triGl = nil
	self.triCnt = 0

	self.pdegs = {{0, 0}}

	self.shadowThread = love.thread.newThread("lua_graphic/lightsCalc.lua")

	for i = 1, 100 do
		local data = {0, 0, 0, 0}   --{x, y, 0, bright}
		self.lightSources[i] = data
	end
	for i = 1, 100 do
		local color = {1, 1, 1, 0}   --{r, g, b, idk}
		self.colors[i] = color
	end
	for i = 1, 100 do
		local data = {isFired = false, body = nil}
		self.data[i] = data
	end

	self.count = 0
	self.shader = love.graphics.newShader("shaders/lights.frag", "shaders/lights.vert")
	return self
end

function Lights:add(x, y, bright, isFire, fbody, r, g, b)
	x, y = pcoords(x, y)
	bright = plen(bright)
	local light = {x, y, 0, bright}

	--self.count = self.count + 1
	local place = 1
	while (place <= 100) and (self.lightSources[place][4] ~= 0) do place = place+1 end
	if place > 100 then return end
	self.lightSources[place] = light
	self.data[place].isFired = isFire
	self.data[place].body = fbody
	if r ~= nil and g ~= nil and b ~= nil then self.colors[place] = {r, g, b, 1} end

	self.lightss = self.lightSources
end

function Lights:getLines()  --get lines of all bodies attached
	for i = 1, self.bodCnt do
		if not self.bodies[i].body:isDestroyed() then
			local x1, y1, x2, y2, x3, y3, x4, y4 = self.bodies[i].body:getWorldPoints(self.bodies[i].shape:getPoints())

			self.shapeCnt = self.shapeCnt + 1
			self.shapes[self.shapeCnt] = {x1 = x1, y1 = y1, x2 = x2, y2 = y2, x3 = x3, y3 = y3, x4 = x4, y4 = y4}
			--[[
			self.lineCnt = self.lineCnt + 1
			self.lines[self.lineCnt] = {x = x1, y = y1, xv = x2, yv = y2, body = i}

			self.lineCnt = self.lineCnt + 1
			self.lines[self.lineCnt] = {x = x2, y = y2, xv = x3, yv = y3, body = i}

			self.lineCnt = self.lineCnt + 1
			self.lines[self.lineCnt] = {x = x3, y = y3, xv = x4, yv = y4, body = i}

			self.lineCnt = self.lineCnt + 1
			self.lines[self.lineCnt] = {x = x4, y = y4, xv = x1, yv = y1, body = i} ]]
		end
	end
end

function Lights:addBody(obj)
	if obj ~= nil then
		self.bodCnt = self.bodCnt + 1
		self.bodies[self.bodCnt] = obj
	end
end

function Lights:draw(camx, camy) --all objects after this will be lightened
	self.shadowThread:wait()
	self.lineCnt = 0
	self.shapeCnt = 0

	self.triGl = love.thread.getChannel("triangles"):pop()
	self.triCnt = love.thread.getChannel("triangCnt"):pop()
	if self.triCnt ~= nil then
		self.pdegs = love.thread.getChannel("pdegs"):pop()
		self.lightss = love.thread.getChannel("lights"):pop()
	end

	self.shader:send("triangles", unpack(self.triGl or self.lightss))
	self.shader:send("lights", unpack(self.lightss))
	self.shader:send("camPos", {camx or 0, camy or 0})
	self.shader:send("pdegs", unpack(self.pdegs))
	self.shader:send("colors", unpack(self.colors))
	love.graphics.setShader(self.shader)
end

function Lights:endDraw()  --all object after this will NOT be lightened
	love.graphics.setShader()
	self:getLines()
	for i = 1, 100 do
		if (self.data[i].body ~= nil) and (not self.data[i].body:isDestroyed()) then
			self.lightSources[i][1] = self.data[i].body:getX()
			self.lightSources[i][2] = self.data[i].body:getY()
		elseif (self.data[i].body ~= nil) and (self.data[i].body:isDestroyed()) and (self.lightSources[i][4] > 0) then
			self.lightSources[i] = {0, 0, 0, 0}
		end
	end
	self.shadowThread:start(self.shapes, self.shapeCnt, self.lightSources)
end

function Lights:addBodyFunc() --return function which can be called in Container:exec()
	tabl = self
	return function(obj)
		if obj then tabl:addBody(obj) end
	end
end
