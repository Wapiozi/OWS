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
	
	while (tmp ~= nil) and (tmp.value.canDelete)  do
		tmp = tmp.next
		self.list.value = nil
		self.list = nil
		self.list = tmp
	end
	
	while tmp ~= nil do 
		if tmp.value.shader ~= nil then love.graphics.setShader(tmp.value.shader) end
		tmp.value:draw()
		love.graphics.setShader()
		
		if tmp.next ~= nil and tmp.next.value.canDelete then
			local tmnext = tmp.next.next
			tmp.next.value = nil
			tmp.next = nil
			tmp.next = tmnext
		end
		
		tmp = tmp.next
	end
end
