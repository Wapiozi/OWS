-- Enemy Implementation --------------------------------------------
Enemy = {}
Enemy.__index = Enemy
Enemy.type = 'enemy'

phraseCanBeGenerated = true

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


-- FLY ENEMIES _________________________________________________________________
	EnemyTypeBat = {
		enemyType = 'fly',
		image = EnemyBatImg,
		imgturn = -1,
		size = 0.05,
		Restitution = 0,
		Friction = 0.1,
		Damage = 10, -- later
		hp = 100,
		Reload = 0,
		mass = 70,
		manaMax = 100,
		cooldown = 1.2,
		ghost = false,

		behaviour = {
			movement_bd = "fly_stay",
			movement_ad = "fly_aggressive",
			attack = "fly_contact",
			sensor = {vision = true, smell = false, noise = false},
			noise_dist = 0.1,
			playerdist = 0,
		}, -- movement_bd = before detect | ad = after detect

		timer = 5,
		Init = nil,
		name = "EnemyTypeBat"
	}


--GROUND ENEMIES________________________________________________________________
	EnemyTypeRat = {
		enemyType = 'ground',
		image = EnemyRatImg,
		imgturn = -1,
		size = 0.028,
		Restitution = 0,
		Friction = 0.09,
		Damage = 0,
		hp = 1,
		Reload = 0,
		mass = 70,
		ghost = false,

		behaviour = {
			movement_bd = "move",
			movement_ad = "victim",
			sensor = {vision = true, smell = false, noise = false},
			smell_detection_time = 2,
			noise_dist = 0.1,
			playerdist = 0,
			canJump = true
		},

		timer = 5,
		Init = nil,
		name = "EnemyTypeRat"
		--Collis = nil
	}

	EnemyTypeMadwizard = {
		enemyType = 'ground',
		image = EnemyMadwizardImg,
		imgturn = -1,
		size = 0.15,
		Restitution = 0,
		Friction = 0.1,
		Damage = 0, -- later
		hp = 100,
		Reload = 0,
		mass = 70,
		manaMax = 100,
		cooldown = 1.2,
		ghost = false,

		behaviour = {
			movement_bd = "slow_move",
			movement_ad = "aggressive",
			attack = "magic",
			magic_type = {
				q = 3, --quantity
				[1] = MagicTypeFire,
				[2] = MagicTypeGround,
				[3] = MagicTypeIce
			},
			sensor = {vision = true, smell = true, noise = false},
			smell_detection_time = 3,
			noise_dist = 0.1,
			playerdist = 0.35,
			canJump = true
		}, -- movement_bd = before detect | ad = after detect

		timer = 5,
		Init = nil,
		name = "EnemyTypeMadwizard"
	}

--NPC___________________________________________________________________________
	NpcTypeMerchant = {
		enemyType = 'npc',
		image = NpcMerchantImg,
		imgturn = 1,
		size = 0.2,
		Restitution = 0,
		Friction = 0.09,
		Damage = 0,
		hp = 1000,
		Reload = 0,
		mass = 70,
		ghost = false,

		behaviour = {
			movement_bd = "slow_move",
			movement_ad = "follow",
			sensor = {vision = true, smell = false, noise = true},
			playerdist = 0.1
		},

		timer = 5,
		Init = nil,
		name = "NpcTypeMerchant"
		--Collis = nil
	}

	NpcTypeChallenge = {
		enemyType = 'npc',
	    image = NpcChallengeImg,
	    imgturn = 1,
	    size = 0.2,
	    Restitution = 0,
	    Friction = 0.09,
	    Damage = 0,
	    hp = 1000,
	    Reload = 0,
	    mass = 70,
		question = true,
		ghost = true,

	    behaviour = {
	        movement_bd = "slow_move",
	        movement_ad = "neutral",
	        sensor = {vision = true, smell = false, noise = true},
	        playerdist = 0.14
	    },

	    timer = 5,
	    Init = nil,
		name = "NpcTypeChallenge"
	    --Collis = nil
	}

	EnemyTypes = {}  --needed for level editor
	EnemyTypes[1] = EnemyTypeBat
	EnemyTypes[2] = EnemyTypeRat
	EnemyTypes[3] = EnemyTypeMadwizard
	EnemyTypes[4] = NpcTypeMerchant
	EnemyTypes[5] = NpcTypeChallenge

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
	--self.fixture:setRestitution(0.1)
	--self.fixture:setFriction(5)
	self.canAttack = false
	self.readytojump = 0
	self.ax = 0
	self.ay = 0

	self.body:setMass(self.type.mass)

	self.hp, self.maxHP = self.type.hp, self.type.hp

	self.behaviour = self.type.behaviour
	self.timer = 0
	self.mana = 1000
	self.canDelete = false
	self.cooldown = self.type.cooldown or 0
	self.canJump= self.behaviour.canJump or false
	self.nearObstacle = false
	self.smell_detection_time = 0
	self.noise_time = 0
	self.question = self.type.question or false
	self.searching = {time = 0, state = false}

	if self.type.enemyType == "fly" then
		self.movDirectionY = 1
		self.attackTimer = 0
	end

	self.target = player1

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
	--if self.type.ghost then self.fixture:setGroupIndex(-1) end
	--if self.type.ghost then self.fixture.setMask(2,3) end--else
	if not self.type.ghost then self.fixture:setCategory(3)
	else self.fixture:setCategory(7) end
	self.fixture:setMask(3)

	--------------------------------methods-------------------------------------

	self.vision_ray = function(fixture, x1, y2, x2, y2, fraction)
		local hit = {}
		hit.fixture = fixture
		hit.x, hit.y = x1, y1
		hit.xn, hit.yn = x2, y2
		hit.fraction = fraction

		table.insert(Ray.hitList, hit)

		return 1 -- Continues with ray cast through all shapes.
	end

	self.smell_ray = function(fixture, x1, y2, x2, y2, fraction)
		obj = fixture:getUserData()
		if obj.name == "player" then
			self.smell = {}
			self.smell.fixture = fixture
			self.smell.obj = obj
			self.smell.fraction = fraction
			return 0
		end
		return 1
	end

	self.noise_ray = function(fixture, x1, y2, x2, y2, fraction)
		obj = fixture:getUserData()
		if obj.name == "player" then
			self.noise = {}
			self.noise.fixture = fixture
			self.noise.obj = obj
			self.noise.fraction = fraction
			return 0
		end
		return 1
	end

	self.getObstacle = function(fixture)
		obj = fixture:getUserData()
		if (fixture:getCategory() == 16 and obj.obstacle == true) or (fixture:getCategory() == 4 ) then
			self.nearObstacle = true
			return false
		end
		self.nearObstacle = false
		return true
	end

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

function Enemy:checkForObstacle()
	--local x1, y1 = self:getUpCoords() -- najti nizhniju position
	--x2, y2 = x1 + 0.2, y1 + 0.2
	local x1, y1, x2, y2
	x1, y1= self.body:getWorldPoints(self.shape:getPoints())
	x1, y1= fcoords(x1, y1)
	if self.movDirection == -1 then
		x1, y1, x2, y2 = plen( x1 - 0.11 ), plen(y1), plen(x1 - 0.01), plen(y1 + self.height - 0.01)
	else
		x1, y1, x2, y2 = plen( x1 + 0.01 + self.width ), plen(y1), plen(x1 + 0.11 + self.width), plen(y1 + self.height - 0.01)
	end
	world:queryBoundingBox(x1, y1, x2, y2, self.getObstacle)
end

function Enemy:jump(strength)
	str = strength or 1
	local vx, vy = self.body:getLinearVelocity()
	self.body:applyLinearImpulse(10000 * -self.movDirection,0)
	if vy ~= 0 then self.body:setLinearVelocity(vx, 0) end
	self.body:applyLinearImpulse(0, -30000 * str)
end

function Enemy:attack()
	local x, y = self:getMagicCoords()
	local curx, cury = pcoords(self:getMagicCoords())
	local xx, yy = self.target.body:getPosition()
	local dist = getDist(curx, cury, xx, yy)
	local vx, vy = (xx - curx)/dist, (yy - cury)/dist
	if self.behaviour.attack == "magic" then
		local typeMagic = math.random(self.behaviour.magic_type.q)
		--love.event.quit(typeMagic)
		typeMagic = self.behaviour.magic_type[typeMagic]
		if (Magic:canShoot(self, typeMagic)) and (self.cooldown < 0) then
			bullets:add(Magic:new(x, y, vx, vy, typeMagic, self.name))
			self.cooldown = self.type.cooldown or 0
		end
	end

end

function Enemy:move(dt, speed, direction)
	local xveloc, yveloc = self.body:getLinearVelocity()
	if self.movDirection == 1 then
		self.ax = self.ax + 5 * dt
	else
		self.ax = -self.ax + 5 *dt
	end
	if (math.abs(xveloc) < plen(speed)) then
		self.body:setLinearVelocity(xveloc + self.movDirection * direction * math.min(math.max(plen(0.03),math.abs(self.ax)),plen(0.03)),yveloc)
	end
end

function Enemy:fly(dt, speed, dx, dy, cx, cy)
	local xveloc, yveloc = self.body:getLinearVelocity()
	if (dx == 0) then
		self.body:setLinearVelocity(0,plen(-0.0256))
	elseif (cx == nil) and (cy == nil) then
		if self.movDirection == 1 then
			self.ax = self.ax + 5 * dt
		else
			self.ax = -self.ax + 5 *dt
		end

		if self.movDirectionY == 1 then
			self.ay = self.ay + 5 * dt
		else
			self.ay = -self.ay + 5 *dt
		end

		if (math.abs(xveloc) < plen(speed)) then
			xveloc = xveloc + self.movDirection * dx * plen(0.03)--math.min(math.max(plen(0.03),math.abs(self.ay)),plen(0.03))
		end

		if (math.abs(yveloc) < plen(speed)) then
			yveloc = yveloc + self.movDirectionY * dy * plen(0.05)--math.min(math.max(plen(0.03),math.abs(self.ay)),plen(0.03))
		end

		if xveloc > 0 then xveloc = xveloc - plen(0.01) else xveloc = xveloc + plen(0.01) end
		if yveloc > 0 then yveloc = yveloc - plen(0.01) else yveloc = yveloc + plen(0.005) end

		self.body:setLinearVelocity(xveloc,yveloc)

	else
		self.body:setLinearVelocity((self.cx - self.x1) * plen(10),  (self.cy - self.y1) * plen(10))
		local x, y = self.body:getPosition()
		if ((math.abs(x - self.x1) > plen(0.5)) or (math.abs(y - self.y1) > plen(0.5))) then
			self:fly(0,0,0)
			self.attackTimer = 0
		end
	end
end

function Enemy:nearG(g)
	local x1, y1 = self.body:getPosition()
	x1, y1 = fcoords(x1, y1)
	if math.abs(x1 - g.x) + math.abs(y1 - g.y) <= 0.05 then return true else return false end
end

function Enemy:standartMovement(dt, g)
	--check for the floor (in future)
	if g == nil then
		--FLY--
		if self.behaviour.movement_bd == "fly_stay" then
			local speed, direction = 0.35, 0
			self:fly(dt,speed,direction)
		--MOVE--
		elseif self.behaviour.movement_bd == "move" then
			local speed, direction = 0.35, 1
			self:move(dt,speed,direction)
		elseif self.behaviour.movement_bd == "slow_move" then
			local speed, direction = 0.15, 1
			self:move(dt,speed,direction)
		end
	else
		local x1, y1 = self.body:getPosition()
		x1, y1 = fcoords(x1, y1)
		if g.x <= x1 then
			self.movDirection = -1
			self.side = self.movDirection * self.type.imgturn
		else
			self.movDirection = 1
			self.side = self.movDirection * self.type.imgturn
		end

		if math.abs(x1 - g.x) <= 0.1 and y1 - 0.1 > g.y then
			self:jump(1.5)
			--self:jump()
			--self:jump()
		else
			if self.behaviour.movement_bd == "move" or self.behaviour.movement_bd == "slow_move" then
				local speed, direction = 0.35, 1
				self:move(dt,speed,direction)
			end
		end

		if self:nearG(g) then
			self.MovementGraph.i = self.MovementGraph.i + 1
			player1.bestVertex1 = self.MovementGraph[self.MovementGraph.i]
		end

	end

end

function Enemy:trigerredMovement(dt)
	local xveloc, yveloc = self.body:getLinearVelocity()
	local x1, y1 = self.body:getPosition()
	local x2, y2 = player1.body:getPosition()


	--FLY--

	if self.behaviour.movement_ad == "fly_aggressive" then
		if (self.attackTimer <= 0) then
			self.fixture:setFriction(0)
			local radius = math.abs(x1 - x2) + math.abs(y1 - y2)
			if (self.cooldown > 0 or flen(radius) >= 0.3 ) or (flen(radius) >= 0.3) then
				if (x1 < x2) then
					self.movDirection = 1
					self.side = 1 * self.type.imgturn
					local speed, directionX, directionY = 0.35, 1, 1
					self:fly(dt,speed,directionX, directionY)
				else
					self.movDirection = -1
					self.side = -1 * self.type.imgturn
					local speed, directionX, directionY = 0.35, 1, 1
					self:fly(dt,speed,directionX, directionY)
				end
			elseif self.behaviour.attack == "fly_contact" then
				self.attackTimer = 2
				self.cooldown = 5
				self.cx, self.cy = x2, y2
				self.x1, self.y1 = self.body:getPosition()

				--self.body:setFixedRotation(false)
				--if (x1 > x2) then self.cx = 1 else self.cx = -1 end
				--if (y1 > y2) then self.cy = -1 else self.cy = 1 end
				--world:rayCast(x1, y1, x2, y2, self.chooseDirection)
			end
		elseif (self.attackTimer <= 0.5) then
			--self.body:setAngularVelocity(0)
			--self.body:setAngle(0)
			--self.body:setFixedRotation(true)
			self.fixture:setFriction(100)
			self.attackTimer = self.attackTimer - dt
			local speed, directionX, directionY = 0.55, 1, 1
			self:fly(dt,speed,directionX, directionY, self.cx, self.cy)
		elseif (self.attackTimer <= 2) then
			self.attackTimer = self.attackTimer - dt
			self:fly(dt,0,0)
			--self.body:setAngularVelocity(self.body:getAngularVelocity() + 0.09)
		end
	elseif
	--MOVE--

	--[[elseif]] self.behaviour.movement_ad == "neutral" then
		if (x1 < x2) then
			self.movDirection = 1
			self.side = 1 * self.type.imgturn
		else
			self.movDirection = -1
			self.side = -1 * self.type.imgturn
		end
		if (flen(math.abs(x2 - x1)) < self.behaviour.playerdist) then
			local speed, direction = 0.05, -1
			self:move(dt,speed,direction)
		else
			self.body:setLinearVelocity(0, yveloc)
		end


	elseif self.behaviour.movement_ad == "follow" then
		if (x1 < x2) then
			self.movDirection = 1
			self.side = 1 * self.type.imgturn
		else
			self.movDirection = -1
			self.side = -1 * self.type.imgturn
		end
		if ((flen(math.abs(x2 - x1)) < self.behaviour.playerdist + 0.02) and (flen(math.abs(x2 - x1)) > self.behaviour.playerdist - 0.02) ) then
			self.body:setLinearVelocity(0, yveloc)
		elseif (flen(math.abs(x2 - x1)) > self.behaviour.playerdist) then
			local speed, direction = 0.15, 1
			self:move(dt,speed,direction)
		elseif (flen(math.abs(x2 - x1)) < self.behaviour.playerdist) then
			local speed, direction = 0.05, -1
			self:move(dt,speed,direction)
		end


	elseif self.behaviour.movement_ad == "victim" then
		if (x1 > x2) then
			self.movDirection = 1
			self.side = 1 * self.type.imgturn
		else
			self.movDirection = -1
			self.side = -1 * self.type.imgturn
		end
		local speed, direction  = 0.55, 1
		self:move(dt,speed,direction)
		--[[
		if (xveloc < plen(0.55)) and (self.movDirection == 1) then self.body:applyForce(100000, 0)
		elseif (xveloc > -plen(055)) and (self.movDirection == -1) then self.body:applyForce(-100000, 0)
		end
		]]--
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
			local speed, direction = 0.5, 1
			self:move(dt,speed,direction)
			--[[
			if (xveloc < plen(0.3)) and (self.movDirection == 1) then self.body:applyForce(100000, 0)
			elseif (xveloc > -plen(0.3)) and (self.movDirection == -1) then self.body:applyForce(-100000, 0) end
			]]--
			self.canAttack = false
		elseif (flen(math.abs(x2 - x1)) < self.behaviour.playerdist) then
			local speed, direction = 0.15, -1
			self:move(dt,speed,direction)
			--[[
			if (xveloc < plen(0.15)) and (self.movDirection == -1) then self.body:applyForce(100000, 0)
			elseif (xveloc > -plen(0.15)) and (self.movDirection == 1) then self.body:applyForce(-100000, 0) end
			]]--
			self.canAttack = true
		end
	end
	xveloc, yveloc = self.body:getLinearVelocity()
	self:checkForObstacle()
	if (self.nearObstacle) then --(self.readytojump > 0.1) and (self.behaviour.canJump == true) and (xveloc ~= 0) then
		--self.body:applyForce(-self.movDirection * 100000 / 2, 0)
		self:jump()
		self.readytojump = 0
		self.nearObstacle = false
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
	self.noise = nil
	self.smell = nil
	local x1, y1 = self.body:getPosition()
	local x2, y2 = player1.body:getPosition()
	if self.behaviour.sensor.vision then
		local canBeSeen = false
		world:rayCast(x1, y1, x2, y2, self.vision_ray)
		--if ((self.movDirection == 1) and (x2 > x1)) or ((self.movDirection == -1) and (x1 < x2))then local canBeSeen = true end
		if ((self.movDirection == 1) and (x2 > x1)) or ((self.movDirection == -1) and (x2 < x1)) then canBeSeen = true end
		for i, hit in ipairs(Ray.hitList) do
			local obj = hit.fixture:getUserData()
			if (obj.name == "player") then
				if hit.fraction > 0.92 then canBeSeen = false end
				local player_fraction = hit.fraction
				--player1.hp = hit.fraction
				--break
			elseif (obj.name ~= "enemy") and (obj.name ~= "item") then
				--love.event.quit()
				if player_fraction ~= nil then
					if player_fraction > hit.fraction then canBeSeen = false end
				else canBeSeen = false end
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
		world:rayCast(x1, y1, x2, y2, self.smell_ray)
		if self.smell ~= nil then
			if self.smell.fraction <= 0.8 then return true end
			self.smell = nil
		end
		return false
	end
	if self.behaviour.sensor.noise then
		--check for distance and if it then detect
		world:rayCast(x1, y1, x2, y2, self.noise_ray)
		if self.noise ~= nil then
			if self.noise.fraction <= 0.85 then return true end
			self.noise = nil
		end
		return false
	end
end

function Enemy:update(dt)
	-- every tic function
	if self.body:isDestroyed() then return end

	local xveloc, yveloc = self.body:getLinearVelocity()
	local xv, yv = player1.body:getLinearVelocity()
	local x1, y1 = self.body:getPosition()
	local x2, y2 = player1.body:getPosition()
	if ((math.abs(x1-x2)<plen(0.8)) and (math.abs(y1-y2)<plen(0.4)) and (self.type.enemyType ~= "npc") ) then
		player1.nearEnemies = true
	end
	--[[
	if (xveloc <= 0.008) and (xveloc >= -0.008) then
		self.readytojump = self.readytojump + dt
	else self.readytojump = 0 end
	--]]

	-- DETECTION PHASE _________________________________________________________
	self.player_detect = self:detect()
	if self.player_detect then
		if self.smell ~= nil then
			self.smell_detection_time = self.smell_detection_time + dt * 2
			--self.body:setLinearVelocity(0, yveloc)
		elseif self.noise ~= nil then
			--self.body:setLinearVelocity(0, yveloc)
		else
			self.timer = self.type.timer
			self.detection_time = 0
		end
	else
		self.smell_detection_time = 0
	end

	-- Cooldown , Mana , Attack checks__________________________________________

	if (self.type.manaMax ~= nil) and (self.mana < self.type.manaMax) then self.mana = self.mana + dt*7 end
	if (self.cooldown >= 0) then self.cooldown = self.cooldown - dt end
	if self.canAttack == true then self:attack() self.canAttack = false end

	-- SMELL____________________________________________________________________

	if (self.smell ~= nil) and (self.smell_detection_time >= self.behaviour.smell_detection_time) then
		self.timer = self.type.timer
	end

	-- NOISE____________________________________________________________________
	if self.noise ~= nil then
		if math.abs(xv) >= plen(0.45) and (self.noise_time >= 1) then
			self.timer = self.type.timer
			self.noise_time = 0
		elseif math.abs(xv) >= plen(0.1) then
			self.noise_time = self.noise_time + dt *2
			self.body:setLinearVelocity(0, yveloc)
		end
	end

	-- MOVEMENT_________________________________________________________________

	if self.type.enemyType == 'fly' then
		if (y2 >= y1 + plen(0.2)) then
			self.movDirectionY = 1
		else
			self.movDirectionY = -1
		end
	end

	if self.timer > 0 then
		self.timer = self.timer - dt
		self:trigerredMovement(dt)
		if self.timer <= 0 then self.searching.time = 3 self.searching.state = true end
	elseif self.noise_time > 0 or self.smell_detection_time > 0 then
		if self.noise_time > 0 then
			self.noise_time = self.noise_time - dt
		end
		if self.smell_detection_time > 0 then
			self.smell_detection_time = self.smell_detection_time - dt
		end
	else
		if self.searching.state then
			if self.searching.time > 0 then
				--if self.searching.time == 3 then self.MovementGraph = graph1:whereToGo(self) end
				self.body:setLinearVelocity(0, yveloc)
				self.searching.time = self.searching.time - dt
			else
				self.searching.state = false
				self.MovementGraph = graph1:whereToGo(self)
				player1.bestVertex1, player1.bestVertex2 = self.MovementGraph[self.MovementGraph.i],self.MovementGraph[self.MovementGraph.q]
			end
		elseif self.MovementGraph ~= nil and self.MovementGraph.q  + 1> self.MovementGraph.i then
			--love.event.quit(0)
			self:standartMovement(dt,graph1[self.MovementGraph[self.MovementGraph.i]])
		else
			self.MovementGraph = nil
			self.step = self.step - 1
			if self.step == 0 then
				self.side = self.side * -1
				self.movDirection = self.side * self.imgturn
				self.step = love.math.random(1000,1000)
			end
			self:standartMovement(dt)
		end
	end
	graph1:enemyVertSeen(self)
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

function Enemy:work()
	if --[[self.question == true and]] (not self.body:isDestroyed()) then
		local x1, y1 = self.body:getPosition()
		local x2, y2 = player1.body:getPosition()
		x1, y1 = fcoords(x1, y1)
		x2, y2 = fcoords(x2, y2)
		if ((math.abs(x1-x2)<0.15) and (math.abs(y1-y2)<0.15) and (player1.nearEnemies == false)) then
		--[[ love.graphics.setColor(1, 1, 1, 1)
			love.graphics.draw(MessageImg, 0, 400)
			love.graphics.printf(Dialogs:readStr(5,"DialogsTxt1.txt"), 200, 530 ,700,left,0,1.5) ]]--
			if phraseCanBeGenerated == true then
				randForPhrase = love.math.random(1,10)
				phraseCanBeGenerated = false
			end
			Dialogs:startConversation(self)
		else
			phraseCanBeGenerated = true
		end
	end
end

function Enemy:draw()
	-- there should be more enemies sprites
	-- self:choose_sprite(red)
	-- find max red[] and choose a sprite
	--love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
	if self.body:isDestroyed() then return end

	local x, y = self.body:getWorldPoints(self.shape:getPoints())
	if self.side == 1 then
		love.graphics.draw(self.image, x, y, self.body:getAngle(), self.scale, self.scale)
	elseif self.side == -1 then
		love.graphics.draw(self.image, x+plen(self.width), y, self.body:getAngle(), self.scale*self.side, self.scale)
	end
	--love.graphics.rectangle("fill", self.x2, self.y1, self.movDirection * math.abs(self.x2 - self.x1), self.movDirection  * math.abs(self.y2 - self.y1) )
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
