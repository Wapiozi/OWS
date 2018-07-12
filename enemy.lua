-- Enemy Implementation --------------------------------------------
Enemy = {}
Enemy.__index = Enemy
Enemy.type = 'enemy'

function Enemy:new(hp, x, y) -- + class of enemy, warior, magician..
	self = setmetatable({}, self)
	
	x, y = pcoords(x, y)
	
	self.image = EnemyImg
	self.scale, self.width, self.height = imageProps(0.17, self.image)
	
	self.body = love.physics.newBody(world, x, y, "dynamic")
	self.body:setAngle(0)
	self.body:setFixedRotation(true)
	
	self.name = "enemy"
	
	self.shape = love.physics.newRectangleShape(pcoords(self.width, self.height))
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setRestitution(0.1)
	self.fixture:setFriction(0)
	
	self.body:setMass(70)
	
	self.hp, self.maxHP = hp, hp
	
	self.side = 1

	 -- also, there should be some agilities of different classes
	 -- for ex. immortal, reduce fire dmg or smth like that
	 
	--[[
	red = {}
	self:randomGen(red)  --WTF IS THAT???????
	self.fire_r  = red[f] -- if red[f] = 0 then fire cant affect
	self.earth_r = red[e]
	self.water_r = red[w]
	self.air_r   = red[a]
	]]--
	
	self.fixture:setUserData(self)

	return self
end

function Enemy:randomGen(red)
	red[f] = math.random(0,3)
	red[e] = math.random(0,3)
	red[w] = math.random(0,3)
	red[a] = math.random(0,3)

	if red[f] + red[e] + red[w] + red[a] < 3 and red[f] + red[e] + red[w] + red[a] > 8 then
		self:randomGen(red)
	end 
end

function Enemy:applyMagic(Dmg_fire, Dmg_water, Dmg_earth, Dmg_air)
	-- check for special agil. of enemy , if no, then --> 
	f = Dmg_fire  * self.fire_r
	w = Dmg_water * self.water_r
	e = Dmg_earth * self.earth_r
	a = Dmg_air   * self.air_r
	dmg = f + w + e + a
	self.hp = self.hp - dmg

	if self.hp < 0 then
		-- add score
	end
end

function Enemy:drawHP()
	local len = self.hp/self.maxHP
	
	local x, y, x1, y1 = self.body:getWorldPoints(self.shape:getPoints())
	
	love.graphics.setColor(0, 0.5, 0)
	love.graphics.rectangle("fill", x, y-plen(0.01), x1-x, plen(0.01))

	love.graphics.setColor(0, 1, 0)
	love.graphics.rectangle("fill", x, y-plen(0.01), (x1-x)*len, plen(0.01))

	love.graphics.setColor(1, 1, 1)
end

function Enemy:draw()
	-- there should be more enemies sprites
	-- self:choose_sprite(red) 
	-- 		find max red[] and choose a sprite 
	--love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
	
	local x, y = self.body:getWorldPoints(self.shape:getPoints())
	if self.side == 1 then 
		love.graphics.draw(self.image, x, y, 0, self.scale, self.scale)
	elseif self.side == -1 then
		love.graphics.draw(self.image, x+plen(self.width), y, 0, self.scale*self.side, self.scale)
	end
	
	self:drawHP()
end	

function Enemy:getCoords()
	local x, y = self.body:getPosition()
	return fcoords(x, y)
end

function Enemy:destroy()
	self.canDelete = true
	self.fixture:destroy()
	self.shape:release()
	self.body:destroy()
end

function Enemy:getDamage(dmg, magic)
	self.hp = self.hp-dmg
	if self.hp < 0 then self:destroy() end
end

