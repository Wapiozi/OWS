local Player, Field, Background, Enemy, Mana, AKM -- smth like place 4 drawing

--[[
	Player - is a magician
	Field - is a background and all obstacles mot AI
	Enemy - is an obstacle with special power and defense agil.
	Mana - is a value of different kinds magic elements for ex Earth, Water...
	AKM - all kind of magic, all possible magic shit	
]]--

-- Player implementation --------------------------------------------------------

Player = {}
Player.__index = Player
Player.type = 'player'

function Player:new(field, mana, x, y, vx, vy)
	self = setmetatable({}, self)
	self.field = field
	self.x = x or 100
	self.y = y or 100
	self.angle = 0
	self.vx = vx or 5
	self.vy = vy or 5
	
	self.magic_delay = md or 1
	self.magic_fire  = mana[fire] or 0
	self.magic_water = mana[water] or 0
	self.magic_air   = mana[air] or 0
	self.magic_earth = mana[earth] or 0

	return self;
end

function Player:update(dt)
	self.magic_delay = self.magic_delay - dt

	-- in making phase, mouse is used

	if love.mouse.isDown(1) and self.magic_delay < 0 then
		-- drawing process
	end

	self.x = self.x + self.vx * dt
	self.y = self.y + self.vy * dt

end

function Player:draw()
	love.graphics.draw(PlayerImg, 100, 100)
	-- by now, it is only like that :P
end

-- Enemy Implementation --------------------------------------------
Enemy = {}
Enemy.__index = Enemy
Enemy.type = 'enemy'

function Enemy:new(field, hp, x, y, vx, vy, red) -- + class of enemy, warior, magician..
	self = setmetatable({}, self)
	self.x = x 
	self.y = y
	self.vx = vx
	self.vy = vy
	self.radius = CollisionMask or 15; 
	self.hp = hp

	 -- also, there should be some agilities of different classes
	 -- for ex. immortal, reduce fire dmg or smth like that
	self.fire_r  = red[f] -- if red[f] = 0 then fire cant affect
	self.earth_r = red[e]
	self.water_r = red[w]
	self.air_r   = red[a]
	return self
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
		self.field:destroy(self)
	end
end

local function Enemy:collision(x1, y1, r1, x2, y2, r2)
	local distance = (x2 - x1) ^ 2 + (y2 - y1) ^ 2
	local rdist = (r1 + r2) ^ 2
	return distance < rdist
end

function Enemy:update(dt)
	self.x = self.x = self.vx * dt
	self.y = self.y = self.vy * dt

	for object in pairs(self.field:getObjects()) do
		if object.type == 'player' then
			if collide(self.x, self.y, self.radius, object.x, object.y, object.radius) then
				-- end of game
			end	
		end -- or elseif if more options
	end
end

function Enemy:draw()
	love.graphics.draw(PlayerImg, 100, 100)
end	

-- Field Implementation --------------------------------------------------

Field = {}
Field.type = 'Field'

function Field:init()
	-- self.score, when score will bw availiable
	self.objects = {}

	local player = Player:new(self, 100, 200)
	print(player)
	self:spawn(player)
end

function Field:spawn(objects)
	self.objects[object] = object
end

function Field:destroy(object)
	self.objects[object] = nil
end

function Field:update(dt)
	-- :P
end

function Field:draw()
	for object in pairs(self.objects) do
		if object.draw then
			object:draw()
		end
	end
	-- print score
end
-- Standart ------------------------------------------------------------

function love.load(arg)
	-- Sprites
	PlayerImg = love.graphics.newImage("Wizard.jpg")
	EnemyImg  = love.graphics.newImage("Enemy.jpg")
	-- by now there will be only one kind of enemies
end

function love.update(dt)

end

function love.draw()
	--so this is game
	--this game is shit
end
