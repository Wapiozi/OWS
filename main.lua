mgest = require("mgesture")
libmagic = require("magic")
libitems = require("items")
libinven = require("inventory")
libenemy = require("enemy")
libplayer = require("player")

world = nil

--[[
	Player - is a magician
	Field - is a background and all obstacles mot AI      --and is useless
	Enemy - is an obstacle with special power and defense agil.
	Mana - is a value of different kinds magic elements for ex Earth, Water...
	AKM - all kind of magic, all possible magic shit	
	
	world - is main world
]]--

function pcoords(fx, fy)    --real coordinates to pixel coordinates
	local px, py = fx*screenHeight, fy*screenHeight
	return px, py
end

function fcoords(px, py)    --pixel coordinates to real coordinates
	local fx, fy = px/screenHeight, py/screenHeight
	return fx, fy
end

Mana = {fire = 1, water = 2, air = 3, earth = 4}




--------------WORLD CALLBACK--------------------------------------

function beginContact(f1, f2, cont) -- fixture1 fixture2 contact
	obj1 = f1:getUserData()
	obj2 = f2:getUserData()
	
	if (obj1 ~= nil) and (obj2 ~= nil) then 
		if obj1.name == "player" or obj2.name == "player" then
			
			if obj1.name == 'item' then
				obj1.ItemCanBeTaken = true
			elseif obj2.name == 'item' then
				obj2.ItemCanBeTaken = true
			end	

			if (obj1.name == "magic") and (obj1.owner ~= "player") then 
				obj2.hp = obj2.hp - obj1.damage
			elseif (obj2.name == "magic") and (obj2.owner ~= "player") then 
				obj1.hp = obj1.hp - obj2.damage
			end

		end
		
		if obj1.name == "enemy" or obj2.name == "enemy" then
			
			if (obj1.name == "magic") and (obj1.owner ~= "enemy") then 
				obj2.hp = obj2.hp - obj1.damage
			elseif (obj2.name == "magic") and (obj2.owner ~= "enemy") then 
				obj1.hp = obj1.hp - obj2.damage
			end

		end
	end

end
 
function endContact(f1, f2, cont)
 	obj1 = f1:getUserData()
	obj2 = f2:getUserData()

	

	if (obj1 ~= nil) and (obj2 ~= nil) then 
		if obj1.name == 'player' or obj2.name == 'player' then
			
			if obj1.name == 'item' then
				obj1.ItemCanBeTaken = false
			elseif obj2.name == 'item' then
				obj2.ItemCanBeTaken = false
			end	
		end
	end
end
 
function preSolve(body_a, body_b, collision)
 
end
 
function postSolve(body_a, body_b, collision, normalimpulse, tangentimpulse)
 
end


-- Standart ------------------------------------------------------------

function love.load(arg)
	-----------RESOURCES LOAD----------------------------------
	
	FireShader = love.graphics.newShader[[
		extern number time;
	
		vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
			
			vec4 col = Texel(texture, texture_coords);
			
			float coef = cos((texture_coords.x - texture_coords.y + sin(time))*8);
			
			col = vec4( abs(sin(time))*col.rg*coef, col.ba);
			
			return col;
		}
	]]
	
	screenWidth, screenHeight = love.graphics.getDimensions()
	
	-- Sprites
	PlayerImg = love.graphics.newImage("Wizard.jpg")
	EnemyImg  = love.graphics.newImage("Enemy.png")
	FireballImg = love.graphics.newImage("Fireball.png")
	WaterballImg = love.graphics.newImage("Fireball.png")
	AirballImg = love.graphics.newImage("Fireball.png")
	IceballImg = love.graphics.newImage("Fireball.png")
	GroundballImg = love.graphics.newImage("Fireball.png")
	WandSdImg = love.graphics.newImage("palka.png")
	ClothSdImg = love.graphics.newImage("palka.png")
	-- by now there will be only one kind of enemies
	
	--------------------------------------------------------------
	
	world = love.physics.newWorld(0, 9.81*100) --we need the whole world
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)
	
	ground = {}
	ground.shape = love.physics.newRectangleShape(10000, 10)
	ground.body = love.physics.newBody(world, 0, 720, "static")
	ground.body:setUserData("ground")
	ground.fixture = love.physics.newFixture(ground.body, ground.shape)
	
	wall = {}
	wall.shape = love.physics.newRectangleShape(10, 10000)
	wall.body = love.physics.newBody(world, 1280, 0, "static")
	wall.fixture = love.physics.newFixture(wall.body, wall.shape)
	
	bullets = MagicCont:new()
	
	Magic:init()
	
	player1 = Player:new(100, 100, 500)
	enem = Enemy:new(500, 1000, 500)
	
	
	love.window.setMode(1280, 720)
	
	
end



function love.update(dt)
	
	
	----------------PROCESSING GESTURE----------------------
	gesture = getLastMovement()
	local i = 1
	if gesture ~= nil then 
		while gesture[i] ~= 10 do   --check for end code
			if gesture[i] == 1 then 
				player1:moveRight()
			elseif gesture[i] == 5 then 
				player1.moveLeft()
			elseif gesture[i] == 7 then 
				player1:jump()
			elseif gesture[i] == 2 then 
				bullets:add(Magic:new(player1.body:getX()+30, player1.body:getY()-40, 50, 1, MagicTypeFire, "player"))
			end
			i = i+1
		end
	end
	-------------------------------------------------------
	
	
	player1:updateSpeed()
			
	
	world:update(dt) --update the whole world
end

function love.draw()
	loadMovement()
	--so this is game
	--this game is not shit
	
	love.graphics.setColor(0.5, 0.9, 0.1)
	love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))
	love.graphics.polygon("fill", wall.body:getWorldPoints(wall.shape:getPoints()))
	
	love.graphics.setColor(0.1, 0.2, 0.9)
	player1:draw()
	
	love.graphics.setColor(1, 1, 1)
	enem:draw()
	
	FireShader:send("time", love.timer.getTime()*20)
	bullets:CheckDraw()
end
