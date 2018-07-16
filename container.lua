--[[
	If object contains field "canDelete" which is set to true this 
	object will be deleted on next CheckDraw()
	
	Container can hold any objects
	
	Storable object must have method draw() optionally can have field
	with shader

]]--

Container = {}
Container.__index = Container

function Container:new()
	self = setmetatable({}, self)
	
	self.list = nil
	
	return self
end

function Container:add(val)
	self.list = {next = self.list, value = val}
end

function Container:CheckDraw()
	local tmp = self.list
	
	while (tmp ~= nil) and (tmp.value ~= nil) and (tmp.value.canDelete)  do
		tmp = tmp.next
		self.list.value = nil
		self.list = nil
		self.list = tmp
	end
	
	while tmp ~= nil do 
--		if tmp.value.shader ~= nil then love.graphics.setShader(tmp.value.shader) end
		tmp.value:draw()
--		love.graphics.setShader(tmp.value.shader)
		
		if tmp.next ~= nil and tmp.next.value.canDelete then
			local tmnext = tmp.next.next
			tmp.next.value = nil
			tmp.next = nil
			tmp.next = tmnext
		end
		
		tmp = tmp.next
	end
end

function Container:update(dt)
	local tmp = self.list

	while tmp ~= nil do
		if tmp.value.update ~= nil then
			tmp.value:update(dt)
		end

		tmp = tmp.next
	end
end
