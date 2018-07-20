Item = {}
Item.__index = Item

function Item:init() 
	WandObj = {			
		image = WandSdImg, -- Wand standart image 
		init = nil,
		size = 0.05,
	}

	ClothObj = {
		image = ClothSdImg, --Clothes standart image
		init = nil,
		size = 0.05,
	}
	-- more to add
end

function Item:new(x, y, type, ID, SpecialImg)
	self = setmetatable({}, self)
	
	x, y = pcoords(x, y)

	self.type = type 
	self.name = "item"

	self.image = self.type.image
	if SpecialImg ~= nil then
		self.image = SpecialImg
	end

	self.scale, self.width, self.height = imageProps(self.type.size, self.image)

	self.ItemCanBeTaken = false
	self.body = love.physics.newBody(world, x, y, "dynamic")
	--self.body:setMass(self.type.mass)
	
	self.shape = love.physics.newRectangleShape(pcoords(self.width, self.height))
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setFriction(10)
	self.fixture:setRestitution(0.4)
	--self.fixture:setSensor(true)

	--self.image = self.type.image
	self.canDelete = false

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
	self.canDelete = true
	--self.fixture:destroy()
	--self.shape:release()
	--self.body:destroy()
	--self:release()
end

function Item:draw()
	if self.body ~= nil then  --Haha, classic
		local x, y = self.body:getWorldPoints(self.shape:getPoints())
		love.graphics.draw(self.image, x, y, self.body:getAngle(), self.scale)
	end
end

function Item:getCoords()
	local x, y = self.body:getPosition()
	return fcoords(x, y)
end
