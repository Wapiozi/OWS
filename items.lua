Item = {}
Item.__index = Item

function Item:init() 
	WandObj{			
		image = WandSdImg -- Wand standart image 
		size = ItemSize
		mass = 1
		init = nil
	}

	ClothObj{
		image = ClothSdImg --Clothes standart image
		size = ItemSize
		mass = 1
		init = nil
	}
	-- more to add
end

function Item:new(x, y, itemID, SpecialImg)
	self = setmetatable({}, self)

	self.type = itemID.type 

	if SpecialImg <> 0 then
		self.type.image = SpecialImg
	
	self.body = love.physics.newBody(world, x, y, "dynamic")
	self.body:setMass(type.mass)
	
	self.shape = love.physics.newRectangleShape(type.size, type.size)
	self.fixture = love.physics.newFixture(self.body, self.shape)

	self.image = self.type.image

	return self
end
