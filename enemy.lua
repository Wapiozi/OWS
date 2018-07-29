-- Enemy Implementation --------------------------------------------
Enemy = {}
Enemy.__index = Enemy
Enemy.type = 'enemy'

function Enemy:init()

	--[[
			there will be several parts of behaviour : 
			1) movement :
				victim  = run from player
				stalker	= run to player
				neutral	= do nothing
			2) sensor : 
				vision  = will start movement after eye contact
				smell = will start movemnt after some time of being in same room with player
				noise = will start movement if player run or doing smth loud
			3) ...
	]]--

	EnemyTypeRat = {
		image = EnemyRatImg,
		imgturn = -1,
		size = 0.028,
		Restitution = 0,
		Friction = 0.09,
		Damage = 0,
		hp = 1,
		Reload = 0,
		mass = 70,

		behaviour = {
			movement_bd = "move", 
			movement_ad = "victim", 
			sensor = {vision = true, smell = false, noise = true},
			playerdist = 0 },

		timer = 5,
		Init = nil
		--Collis = nil
	}
	EnemyTypeMadwizard = {
		image = EnemyMadwizardImg,
		imgturn = -1,
		size = 0.2,
		Restitution = 0,
		Friction = 0.1,
		Damage = 0, -- later
		hp = 100,
		Reload = 0,
		mass = 70,
		manaMax = 100,

		behaviour = { 
			movement_bd = "slow_move", 
			movement_ad = "aggressive", 
			attack = "magic",
			sensor = {vision = true, smell = false, noise = true},
			playerdist = 0.35}, -- movement_bd = before detect | ad = after detect

		timer = 5,
		Init = nil
	}
	
	EnemyTypeRat.Collis = function(px, py)
	end
	EnemyTypeMadwizard.Collis = function(px, py)
	end
end

function Enemy:new(type, x, y) -- + class of enemy, warior, magician..

	self = setmetatable({}, self)
	
	x, y = pcoords(x, y)

	self.type = type 
	self.image = self.type.image
	self.imgturn = self.type.imgturn
	self.scale, self.width, self.height = imageProps(self.type.size, self.image)
	
	self.body = love.physics.newBody(world, x, y, "dynamic")
	self.body:setAngle(0)
	self.body:setFixedRotation(true)
	
	self.name = "enemy"

	self.movDirection = love.math.random(2)
	if self.movDirection == 2 then self.movDirection = -1 end
	self.side = self.movDirection
	self.step = love.math.random(10)
	self.player_detect = false
	
	self.shape = love.physics.newRectangleShape(pcoords(self.width, self.height))
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setRestitution(0.1)
	self.fixture:setFriction(5)
	self.canAttack = false
	
	self.body:setMass(self.type.mass)
	
	self.hp, self.maxHP = self.type.hp, self.type.hp

	self.behaviour = self.type.behaviour
	self.timer = 0
	self.mana = 0
	self.canDelete = false
	
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
	self.fixture:setCategory(3)
	self.fixture:setMask(3)
	self.fixture:setUserData(self)

	return self
end
--[[
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
--]]

function Enemy:attack()
	local x, y = self:getMagicCoords()
	if self.behaviour.attack == "magic" then 
		if Magic:canShoot(self, MagicTypeFire) then bullets:add(Magic:new(x, y, 50*self.side*self.type.imgturn, 1, MagicTypeFire, self.name)) end
	end

end

function Enemy:standartMovement()
	--check for the floor (in future)
	if self.behaviour.movement_bd == "move" then

		local xveloc, yveloc = self.body:getLinearVelocity()
		
		if (xveloc < plen(0.45)) and (self.movDirection == 1) then self.body:applyForce(100000, 0) 
		elseif (xveloc > -plen(0.45)) and (self.movDirection == -1) then self.body:applyForce(-100000, 0) 
		elseif (self.movDirection == 0) then
			if (xveloc > 0.2) then 
				self.body:applyForce(-10000, 0)
			elseif (xveloc < -0.2) then 
				self.body:applyForce(10000, 0)
			end
		end

	elseif self.behaviour.movement_bd == "slow_move" then

		local xveloc, yveloc = self.body:getLinearVelocity()
		
		if (xveloc < plen(0.09)) and (self.movDirection == 1) then self.body:applyForce(100000, 0) 
		elseif (xveloc > -plen(0.09)) and (self.movDirection == -1) then self.body:applyForce(-100000, 0) 
		elseif (self.movDirection == 0) then
			if (xveloc > 0.2) then 
				self.body:applyForce(-10000, 0)
			elseif (xveloc < -0.2) then 
				self.body:applyForce(10000, 0)
			end
		end


	end

end

function Enemy:trigerredMovement()
	local xveloc, yveloc = self.body:getLinearVelocity()
	local x1, y1 = self.body:getPosition()
	local x2, y2 = player1.body:getPosition()
	
	if self.behaviour.movement_ad == "victim" then
		if (x1 > x2) then 
			self.movDirection = 1
			self.side = 1 * self.type.imgturn 
		else 
			self.movDirection = -1 
			self.side = -1 * self.type.imgturn
		end
		if (xveloc < plen(0.55)) and (self.movDirection == 1) then self.body:applyForce(100000, 0) 
		elseif (xveloc > -plen(055)) and (self.movDirection == -1) then self.body:applyForce(-100000, 0)
		end
	elseif self.behaviour.movement_ad == "aggressive" then
		if (x1 < x2) then 
			self.movDirection = 1
			self.side = 1 * self.type.imgturn 
		else 
			self.movDirection = -1 
			self.side = -1 * self.type.imgturn
		end
		if ((flen(math.abs(x2 - x1)) < self.behaviour.playerdist + 0.02) and (flen(math.abs(x2 - x1)) > self.behaviour.playerdist - 0.02) ) then 
			--if (xveloc < plen(0.1)) and (self.movDirection == 1) then self.body:applyForce(100000, 0) 
			--elseif (xveloc > -plen(0.1)) and (self.movDirection == -1) then self.body:applyForce(-100000, 0) 
			--else
			self.body:setLinearVelocity(0, yveloc)
			self.canAttack = true
			--end
		elseif (flen(math.abs(x2 - x1)) > self.behaviour.playerdist) then
			if (xveloc < plen(0.3)) and (self.movDirection == 1) then self.body:applyForce(100000, 0) 
			elseif (xveloc > -plen(0.3)) and (self.movDirection == -1) then self.body:applyForce(-100000, 0) end
			self.canAttack = false
		elseif (flen(math.abs(x2 - x1)) < self.behaviour.playerdist) then
			if (xveloc < plen(0.15)) and (self.movDirection == -1) then self.body:applyForce(100000, 0) 
			elseif (xveloc > -plen(0.15)) and (self.movDirection == 1) then self.body:applyForce(-100000, 0) end
			self.canAttack = true
		end	
	end
	--check for the floor (in future)
	--[[
	-- find player, decide what to do
	local xveloc, yveloc = self.body:getLinearVelocity()
	
	if (xveloc < plen(0.45)) and (self.movDirection == 1) then self.body:applyForce(100000, 0) 
	elseif (xveloc > -plen(0.45)) and (self.movDirection == -1) then self.body:applyForce(-100000, 0) 
	elseif (self.movDirection == 0) then
		if (xveloc > 0.2) then 
			self.body:applyForce(-100000, 0)
		elseif (xveloc < -0.2) then 
			self.body:applyForce(100000, 0)
		end
	end
	--]]
end

function Enemy:detect()
	if self.behaviour.sensor.vision then
		local x1, y1 = self.body:getPosition()
		local x2, y2 = player1.body:getPosition()
		local canBeSeen = false
		world:rayCast(x1, y1, x2, y2, rayCast_vision)
		--if ((self.movDirection == 1) and (x2 > x1)) or ((self.movDirection == -1) and (x1 < x2))then local canBeSeen = true end
		if ((self.movDirection == 1) and (x2 > x1)) or ((self.movDirection == -1) and (x2 < x1)) then canBeSeen = true end
		for i, hit in ipairs(Ray.hitList) do
			local obj = hit.fixture:getUserData()
			if (obj.name == "player") then
				if hit.fraction > 0.92 then canBeSeen = false end 
				--player1.hp = hit.fraction
				break
			elseif (obj.name ~= "enemy") and (obj.name ~= "item") then
				canBeSeen = false
			end
		end
		--local RayLeng1th = plen(0.2)
		--local x2 = x1 + (RayLength * self.side)
		--local y2 = y1 + plen(0.1)
		--local y3 = y1 - plen(0.1)
		--local xn, yn, fraction = self.fixture:rayCast(x1, y1, x2, y1, RayLength, 1)
		
		--[[
		while (xn ~= nil) and (xn <= RayLength) do
			hitx, hity = x1 + (x2 - x1) * fraction, y1 + (y1 - y1) * fraction
			if player1.fixture:testPoint(hitx, hity) then 
				return true
			end
			local x1 = hitx
			local xn, yn, fraction = self.fixture:rayCast(x1, y1, x2, y1, RayLength, 1)
		end
		]]--
		-- Clear fixture hit list.
		Ray.hitList = {}
		return canBeSeen
	end
	if self.behaviour.sensor.smell then


		return false
	end
	if self.behaviour.sensor.noise then


		return false
	end
end

function Enemy:update(dt)
	-- every tic function
	self.player_detect = self:detect()
	if self.player_detect then self.timer = self.type.timer end
	if (self.type.manaMax ~= nil) and (self.mana < self.type.manaMax) then self.mana = self.mana + dt*3 end
	if self.canAttack then self:attack() end
	if self.timer > 0 then
		self.timer = self.timer - dt
		self:trigerredMovement()
	else
		self.step = self.step - 1
		if self.step == 0 then
			self.side = self.side * -1
			self.movDirection = self.side * self.imgturn
			self.step = love.math.random(1000,1000)
		end
		self:standartMovement()
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

function Enemy:getMagicCoords()  --where magic need to spawn
	local x, y = self:getCoords()
	x = x + (self.width/2 + 0.03)*self.side*self.type.imgturn
	y = y - self.height/2 + 0.05
	return x, y
end

function Enemy:destroy()
	self.canDelete = true
	self.fixture:destroy()
	self.shape:release()
	self.body:destroy()
end

function Enemy:getDamage(dmg, magic)
	self.timer = self.type.timer
	self.hp = self.hp-dmg
	if self.hp < 0 then self:destroy() end
end
