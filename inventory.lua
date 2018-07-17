Inventory = {}
Inventory.__index = Item

function Inventory:init()
	-- X3
end

function Inventory:new(size, len, height)
	self = setmetatable({}, self)
	self.size = 27 or size or 50
	self.length = 9 or len or (size / 5)
	self.height = 3
	self.lastInventoryPoint={x = 240, y = 20}
	self.image = MinecraftInv

	self.slot = {}
	
	for i = 0, self.size do
		self.slot[i] = nil    
	end
	return self
end

function Inventory:getFirstEmpty()
	for i = 0, self.size do
		if self.slot[i] == nil then 
			return i
		end
	end
	return -1
end

function Inventory:addItem(item1)
	if item1.ItemCanBeTaken then
		local place = self:getFirstEmpty()
		if place ~= -1 then
			self.slot[i] = item1
			item1:despawn()
		end
	end
end

function Inventory:loseItem(ind, player_x, player_y)
	item1 = self.slot[ind].id
	self.slot.i{id = nil}

	item1:spawn(player_x+50, player_y)
end

function Inventory:drawItem(x, y, item1)
    -- for items
    love.graphics.draw(item1.image, x, y)
end

function Inventory:draw()
	-- there should be some pojebenj
	love.event.quit()
	local x, y = self.lastInventoryPoint[x], self.lastInventoryPoint[y]
	love.graphics.draw(self.image, x, y)
	local x1, y1 = x + 14, y + 143    --какого куя тут пиксельные координаты? юзать flen() plen()
	for i = 0, self.height-1 do
		for j = 0, self.length-1 do
			if self.slot[i*9+j] ~= nil then
				self:drawItem(x1, y1, self.slot[i*9+j])
			end
			x1 = x1 + 30 
		end 
		y1 = y1 + 30  
	end
end
