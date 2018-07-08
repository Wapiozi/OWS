mgest = require("mgesture")
local Player, Field, Enemy, Mana, AKM -- smth like place 4 drawing
world = null

--[[
	Player - is a magician
	Field - is a background and all obstacles mot AI      --and is useless
	Enemy - is an obstacle with special power and defense agil.
	Mana - is a value of different kinds magic elements for ex Earth, Water...
	AKM - all kind of magic, all possible magic shit	
	
	world - is main world
]]--

-- Player implementation --------------------------------------------------------

Mana = {fire = 1, water = 2, air = 3, earth = 4}

Player = {}
Player.__index = Player
Player.type = 'player'

function Player:new(mana, x, y)
	self = setmetatable({}, self)
	
	self.magic_delay = md or 1
	self.magic_fire  = Mana[fire] or 0
	self.magic_water = Mana[water] or 0
	self.magic_air   = Mana[air] or 0
	self.magic_earth = Mana[earth] or 0
	
	self.movDirection = 0    --   1 right      -1 left      0 no
	
	self.body = love.physics.newBody(world, x, y, "dynamic")  --create new dynamic body in world
	self.body:setMass(70) -- 70kg wizard
	self.body:setAngle(0)
	self.body:setFixedRotation(true)
	
	self.shape = love.physics.newRectangleShape(80, 120)      --wizard figure
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setRestitution(0.1)
	self.fixture:setFriction(5)
	
	return self;
end

function Player:draw()
	--love.graphics.draw(PlayerImg, 100, 100)
	-- by now, it is only like that :P
	love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end

-- Enemy Implementation --------------------------------------------
Enemy = {}
Enemy.__index = Enemy
Enemy.type = 'enemy'

function Enemy:new(hp, x, y) -- + class of enemy, warior, magician..
	self = setmetatable({}, self)
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
	
	return self
end

function Enemy:randomGen(red)
	red[f] = math.random(0,3)
	red[e] = math.random(0,3)
	red[w] = math.random(0,3)
	red[a] = math.random(0,3)

	if red[f] + red[e] + red[w] + red[a] < 3 then
		self:randomGen(red)
	end 
end

function Enemy:applyMagic(Dmg_fire, Dmg_water, Dmg_earth, Dmg_air)
	-- check for special agil. of enemy , if no, then --> 
	f = Dmg_fire  * self.fire_r
	f = Dmg_water * self.water_r
	f = Dmg_earth * self.earth_r
	f = Dmg_air   * self.air_r
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

-- Standart ------------------------------------------------------------

function love.load(arg)
	world = love.physics.newWorld(0, 9.81*100) --we need the whole world
	
	ground = {}
	ground.shape = love.physics.newRectangleShape(10000, 10)
	ground.body = love.physics.newBody(world, 0, 500, "static")
	ground.fixture = love.physics.newFixture(ground.body, ground.shape)
	
	-- Sprites
	PlayerImg = love.graphics.newImage("Wizard.jpg")
	EnemyImg  = love.graphics.newImage("Enemy.png")
	-- by now there will be only one kind of enemies
	
	player1 = Player:new(100, 100, 500)
	enem = Enemy:new(500, 100, 500)
	
	
	love.window.setMode(1600, 500)
end

function love.update(dt)
	
	
	----------------PROCESSING GESTURE----------------------
	gesture = getLastMovement()
	local i = 1
	if gesture ~= nil then 
		while gesture[i] ~= 10 do   --check for end code
			if gesture[i] == 1 then 
				if player1.movDirection >= 0 then 
					player1.movDirection = 1
				else
					player1.movDirection = 0
				end
			elseif gesture[i] == 5 then 
				if player1.movDirection <= 0 then 
					player1.movDirection = -1
				else
					player1.movDirection = 0
				end
			elseif gesture[i] == 7 then 
				player1.body:applyLinearImpulse(0, -6000)
			end
			i = i+1
		end
	end
	-------------------------------------------------------
	
	
	-----------set speed-----------------------------------
	local xveloc, yveloc = player1.body:getLinearVelocity()
	
	if (xveloc < 180) and (player1.movDirection == 1) then player1.body:applyForce(100000, 0) 
	elseif (xveloc > -180) and (player1.movDirection == -1) then player1.body:applyForce(-100000, 0) 
	elseif (player1.movDirection == 0) then
		if (xveloc > 3) then 
			player1.body:applyForce(-10000, 0)
		elseif (xveloc < -3) then 
			player1.body:applyForce(10000, 0)
		end
	end
	------------------------------------------------------
			
	
	world:update(dt) --update the whole world
end

function love.draw()
	loadMovement()
	--so this is game
	--this game is not shit
	
	love.graphics.setColor(0.5, 0.9, 0.1)
	love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))
	
	love.graphics.setColor(0.1, 0.2, 0.9)
	player1:draw()
	
	love.graphics.setColor(1, 1, 1)
	enem:draw()
	
end
