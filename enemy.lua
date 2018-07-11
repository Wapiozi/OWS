-- Enemy Implementation --------------------------------------------
Enemy = {}
Enemy.__index = Enemy
Enemy.type = 'enemy'

function Enemy:new(hp, x, y) -- + class of enemy, warior, magician..
	self = setmetatable({}, self)
	
	x, y = pcoords(x, y)
	
	self.body = love.physics.newBody(world, x, y, "dynamic")
	self.body:setMass(70)
	self.body:setAngle(0)
	self.body:setFixedRotation(true)
	
	self.shape = love.physics.newRectangleShape(80, 120)
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setRestitution(0.1)
	self.fixture:setFriction(5)
	
	self.hp = hp

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

function Enemy:draw()
	-- there should be more enemies sprites
	-- self:choose_sprite(red) 
	-- 		find max red[] and choose a sprite 
	--love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
	
	local x, y = self.body:getWorldPoints(self.shape:getPoints())
	love.graphics.draw(EnemyImg, x, y)
end	

function Enemy:getCoords()
	local x, y = self.body:getPosition()
	return fcoords(x, y)
end
