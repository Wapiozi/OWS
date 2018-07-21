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
	for i = 1, self.size do
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
			self.slot[place] = item1
			--item1:despawn()
		end
	end
end

function Inventory:loseItem(ind, player_x, player_y)
	item1 = self.slot[ind].id
	self.slot[i] = nil

	item1:spawn(player_x+50, player_y)
end

function Inventory:dragging()
	mx, my = love.mouse.getPosition()
	x1, y1, i1, j1= self:findWindow()
	if x1 ~= -1 then
		released = false
  		item1 = self.slot[i1*9+j1]
  		--local scl, w, h = imageProps(0.038, item1.image)
  		if item1 ~= nil then 
  			love.mouse.setVisible(false)
  			--love.mouse.setCursor(love.mouse.newCursor(item1.imageData, 0, 0))
  			cursorItem = item1.image
  		end
  		--love.mouse.setVisible(false)
 		--love.mouse.setGrab(true)	
		--while love.mouse.isDown(1) do
			--love.graphics.draw(cursor.image, love.mouse.getX(), love.mouse.getY(), 0, scl)
		--end
		return x1, y1, i1, j1, item1
	end
end

function Inventory:draggingEnd(x1, y1, i1, j1, item1)
	mx, my = love.mouse.getPosition()
	x2, y2, i2, j2= self:findWindow()
	--love.mouse.setCursor()
	cursorItem = nil
	love.mouse.setVisible(true)
	--love.mouse.setVisible(true)
 	--love.mouse.setGrab(false)
 	if x2 ~= -1 then
 		self.slot[i1*9+j1] = self.slot[i2*9+j2]
 		self.slot[i2*9+j2] = item1
 	else
 		--drop on the floor
 		self.slot[i1*9+j1] = nil

 		local px, py = player1.body:getWorldPoints(player1.shape:getPoints())
 		items:add(Item:new(flen(px) + 0.15,flen(py) ,item1.type))
 	end
end
	
function Inventory:findWindow()
	mx, my = love.mouse.getPosition()
	local x, y = self.lastInventoryPoint.x, self.lastInventoryPoint.y
	local x1, y1 = x + self:fcord(14,"x"), y + self:fcord(143,"y")    --какого куя тут пиксельные координаты? юзать flen() plen()  -- x = 14 y = 143
	for i = 0, self.h-1 do
		for j = 1, self.w do
			if  mx >= x1 and mx <= x1 + self:fcord(30.5,"x") and
				my >= y1 and my <= y1 + self:fcord(30,"y") then
					return x1, y1, i, j
			end
			x1 = x1 + self:fcord(30.5,"x") 
		end 
		x1 = x + self:fcord(14,"x")
		y1 = y1 + self:fcord(30,"y")  
	end
	return -1
end

function Inventory:checkInventoryMode(mx, my)
	x1, y1, i, j = self:findWindow()
	if x1 ~= -1 then 
		x1 = x1 - self:fcord(0.1,"x")
		y1 = y1 - self:fcord(0.1,"y")
		local scl,h,w = imageProps(0.039,InvborderImg)
		love.graphics.draw(InvborderImg, x1, y1, 0, scl)
		if love.mouse.isDown(1) and released then
			self.x1, self.y1, self.i1, self.j1, self.item1 = self:dragging()
			--self:draggingEnd(x1, y1, i1, j1, item1)
		end
	end
end


function Inventory:pcord(fcrd, ch)
	if ch == "x" then
		fcrd = pcrd / (plen(self.width) / 300)
	elseif ch == "y" then
		fcrd = pcrd / (plen(self.height) / 283)
	end
	return fcrd
end

function Inventory:fcord(pcrd, ch)
	if ch == "x" then
		fcrd = pcrd * (plen(self.width) / 300)
	elseif ch == "y" then
		fcrd = pcrd * (plen(self.height) / 283)
	end
	return fcrd
end

function Inventory:drawItem(x, y, item1)
    -- for items
    local img,h,w = imageProps(0.038, item1.image)
    love.graphics.draw(item1.image, x, y, 0, img)
end

function Inventory:draw()
	-- there should be some pojebenj
	local x, y = self.lastInventoryPoint.x, self.lastInventoryPoint.y
	--love.graphics.draw(self.image, x, y)
	love.graphics.draw(self.image, x, y, 0, self.scale)
	local x1, y1 = x + self:fcord(14,"x"), y + self:fcord(143,"y")    --какого куя тут пиксельные координаты? юзать flen() plen()  -- x = 14 y = 143
	for i = 0, self.h-1 do
		for j = 1, self.w do
			if self.slot[i*9+j] ~= nil then
				self:drawItem(x1, y1, self.slot[i*9+j])
			end
			x1 = x1 + self:fcord(30.5,"x") 
		end 
		x1 = x + self:fcord(14,"x")
		y1 = y1 + self:fcord(30,"y")  
	end
end
