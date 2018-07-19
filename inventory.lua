Inventory = {}
Inventory.__index = Inventory

function Inventory:init()
	-- X3
end

function Inventory:new(size, len, height)
	self = setmetatable({}, self)
	self.size = 27 or size or 50
	self.w = 9 or len or (size / 5)
	self.h = 3
	self.lastInventoryPoint={x = plen(0.25), y = plen(0.01)}
	self.image = MinecraftInv
	self.scale, self.width, self.height = imageProps(0.4, self.image)

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
	self.slot[i] = nil

	item1:spawn(player_x+50, player_y)
end

function Inventory:drawItem(x, y, item1)
    -- for items
    local img = imageProps(0.01 * self.scale, item1.image)
    love.graphics.draw(item1.image, x, y, 0, img)
end

function Inventory:dragging()
	--
end

function Inventory:pcord(fcrd, ch)
	if ch == "x" then
		fcrd = pcrd / (self.width / 300)
	elseif ch == "y" then
		fcrd = pcrd / (self.height / 283)
	end
	return fcrd
end

function Inventory:fcord(pcrd, ch)
	if ch == "x" then
		fcrd = pcrd * (self.width / 300)
	elseif ch == "y" then
		fcrd = pcrd * (self.height / 283)
	end
	return fcrd
end

function Inventory:draw()
	-- there should be some pojebenj
	local x, y = self.lastInventoryPoint.x, self.lastInventoryPoint.y
	--love.graphics.draw(self.image, x, y)
	love.graphics.draw(self.image, x, y, 0, self.scale)
	local x1, y1 = x + self:fcord(14,"x"), y + self:fcord(143,"y")    --какого куя тут пиксельные координаты? юзать flen() plen()
	for i = 0, self.h-1 do
		for j = 0, self.w-1 do
			if self.slot[i*9+j] ~= nil then
				self:drawItem(x1, y1, self.slot[i*9+j])
			end
			x1 = x1 + self:fcord(30,"x") 
		end 
		y1 = y1 + self:fcord(30,"y")  
	end
end
