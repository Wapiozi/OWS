Inventory = {}
Inventory.__index = Item

function Inventory:init()
	-- X3
end

function Inventory:new(size)
	self = setmetatable({}, self)
	self.size = size
	
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

function Inventory:draw()
	-- there should be some pojebenj
end
