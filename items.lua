Item = {}
Item.__index = Item

ItemSize = 5

function Item:init() 
	WandObj = {			
		image = WandSdImg, -- Wand standart image 
		size = ItemSize,
		init = nil,
	}

	ClothObj = {
		image = ClothSdImg, --Clothes standart image
		size = ItemSize,
		init = nil,
	}
	-- more to add
end

function Item:new(x, y, itemID, SpecialImg)
	self = setmetatable({}, self)
	
	x, y = pcoords(x, y)

	self.type = itemID.type 
	self.name = "item"

	if SpecialImg ~= nil then
		self.type.image = SpecialImg
	end
	self.ItemCanBeTaken = false
	self.body = love.physics.newBody(world, x, y, "dynamic")
	self.body:setMass(type.mass)
	
	self.shape = love.physics.newRectangleShape(type.size, type.size)
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setSensor(true)

	self.image = self.type.image

	self.body:setAngle(45)
	self.fixture:setUserData(self)
	return self
end

--[[  look in main
function Item:checkcollis(x, y)
	if math.abs(self.x - x) <= self.r and math.abs(self.y - y) <= self.r then
		return true
	end
end
--]]
function Item:spawn(x, y)
	self.body:setPosition(x, y)
	self.body:setActive(true)
end

function Item:despawn()
	self.body:setActive(false)
end

function Item:destroy()
	self:release()
end

function Item:draw()
	if self.body:isActive() then
		local x, y = self.body:getWorldPoints(self.shape:getPoints())
		love.graphics.draw(self.image, x, y, self.body:getAngle())
	end
end

function Item:getCoords()
	local x, y = self.body:getPosition()
	return fcoords(x, y)
end
