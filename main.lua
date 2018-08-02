mgest = require("mgesture")
libmagic = require("magic")
libitems = require("items")
libinven = require("inventory")
libenemy = require("enemy")
libplayer = require("player")
libcamera = require("camera")
libbrick = require("brick")
libcont = require("container")
libparticles = require("particles")
liblighting = require("lighting")
libenv = require("envobjects")
libnpc = require("npc")

world = nil
inventoryOpen = false
--[[
	Player - is a magician
	Field - is a background and all obstacles mot AI      --and is useless
	Enemy - is an obstacle with special power and defense agil.
	Mana - is a value of different kinds magic elements for ex Earth, Water...
	AKM - all kind of magic, all possible magic shit

	world - is main world
]]--

function pcoords(fx, fy)    --real coordinates to pixel coordinates
	local px = fx*screenHeight
	local py = fy*screenHeight
	return px, py
end

function fcoords(px, py)    --pixel coordinates to real coordinates
	local fx = px/screenHeight
	local fy = py/screenHeight
	return fx, fy
end

function plen(fval)
	local pval = fval*screenHeight
	return pval
end

function flen(pval)
	local fval = pval/screenHeight
	return fval
end

function imageProps(height, img)
	local wid, hig = img:getDimensions()
	local scal = plen(height)/hig
	local fwid, fhig = flen(wid*scal), flen(hig*scal)

	return scal, fwid, fhig
end

--------------WORLD CALLBACK--------------------------------------

function rayCast_vision(fixture, x1, y2, x2, y2, fraction)
	local hit = {}
	hit.fixture = fixture
	hit.x, hit.y = x1, y1
	hit.xn, hit.yn = x2, y2
	hit.fraction = fraction

	table.insert(Ray.hitList, hit)

	return 1 -- Continues with ray cast through all shapes.
end

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
				obj2:getDamage(obj1.damage)
			elseif (obj2.name == "magic") and (obj2.owner ~= "player") then
				obj1:getDamage(obj2.damage)
			end

			if (obj1.name == "brick") and (obj1.mean == "floor") then
				obj2:collidedWithFloor()
			elseif (obj2.name == "brick") and (obj2.mean == "floor") then
				obj1.collidedWithFloor()
			end

		end

		if obj1.name == "enemy" or obj2.name == "enemy" then
--[[
			if (obj1.name =="enemy") and (obj2.name == "enemy") then
				cont:setEnabled(false)
				cont:resetFriction()
				cont:resetRestitution()

			end

]]--
			if (obj1.name == "magic") and (obj1.owner ~= "enemy") then
				obj2:getDamage(obj1.damage)

			elseif (obj2.name == "magic") and (obj2.owner ~= "enemy") then
				obj1:getDamage(obj2.damage)

			end

		end
	end

	if (obj1 ~= nil) and (obj1.name == "magic") then
		obj1:collision()
	end
	if (obj2 ~= nil) and (obj2.name == "magic") then
		obj2:collision()
	end

	if (obj1 ~= nil) and (obj1.name == "enemy") and (obj1.behaviour.movement ~= "stop") and (obj1.player_detect == false) and (obj2 ~= nil) and ((obj2.name ~= "brick") or (obj2.mean ~= "floor")) and (obj2.name ~= "magic") then
		obj1.side = obj1.side * -1
		obj1.movDirection = obj1.side * obj1.imgturn
		obj1.step = love.math.random(1000,1000)
	end
	if (obj2 ~= nil) and (obj2.name == "enemy") and (obj2.behaviour.movement ~= "stop") and (obj2.player_detect == false) and (obj1 ~= nil) and ((obj1.name ~= "brick") or (obj1.mean ~= "floor")) and (obj2.name ~= "magic") then
		obj2.side = obj2.side * -1
		obj2.movDirection = obj2.side * obj2.imgturn
		obj2.step = love.math.random(1000,1000)
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

------------------------KEYBOARD---------------------------------------

function love.keypressed(key)
	if (key == "d") and (player1.movDirection == 0) then
		player1:moveRight()
	elseif (key == "a") and (player1.movDirection == 0) then
		player1:moveLeft()
	end

	if (key == "w") then
		player1:jump()
	end
	if (key == "f") then  --FOR TESTING ONLY
		local x, y = player1:getMagicCoords()
		bullets:add(Magic:new(x, y, 50*player1.side, 1, MagicTypeWater, "player"))
	end

	if (key == "i") then
		if inventoryOpen then
			inventoryOpen = false
		elseif not inventoryOpen then
			inventoryOpen = true
		end
	end
end

function love.keyreleased(key)
	if (key == "d") or (key == "a") then
		player1.movDirection = 0
	end
end

function love.mousereleased(x, y, button)
	if inventoryOpen then
	   if button == 1 and released == false then
	    	inventory1:draggingEnd(inventory1.x1, inventory1.y1, inventory1.i1, inventory1.j1, inventory1.item1)
			released = true
	   end
	end
end

-- Standart ------------------------------------------------------------

function love.load(arg)
	--love.physics.setMeter(10)
	math.randomseed(0xfacef00d)
	-----------RESOURCES LOAD----------------------------------

	-- Sprites
	PlayerImg = love.graphics.newImage("Player.png")
	MinecraftInv = love.graphics.newImage("minecraft.png")
	InvborderImg = love.graphics.newImage("inventory_border.png")
	-- enemies
		EnemyMadwizardImg = love.graphics.newImage("EnemyMadwizard.png")
		EnemyRatImg = love.graphics.newImage("EnemyRat.png")
	-- magic
	FireballImg = love.graphics.newImage("Fireball.png")
	WaterballImg = love.graphics.newImage("Fireball.png")
	AirballImg = love.graphics.newImage("Fireball.png")
	IceballImg = love.graphics.newImage("Fireball.png")
	GroundballImg = love.graphics.newImage("Fireball.png")
	WandSdImg = love.graphics.newImage("palka.png")
	ClothSdImg = love.graphics.newImage("majka.png")
	BrickImg = love.graphics.newImage("brick.png")
	FireImg = love.graphics.newImage("fire.png")
	BlueBrick = love.graphics.newImage("brick2.png") BlueBrick:setWrap("repeat", "repeat")
	ChestImg = love.graphics.newImage("chest.png")
	TorchImg = love.graphics.newImage("torch.png")
	--NPC
	NpcMerchantImg = love.graphics.newImage("merchant.png")



	--------------------------------------------------------------

	love.window.setMode(1280,720)
	screenWidth, screenHeight = love.window.getMode()


	world = love.physics.newWorld(0, 9.81*100) --we need the whole world
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	Ray = {
		x1 = 0,
		y1 = 0,
		x2 = 0,
		y2 = 0,
		hitList = {}
	}

	enemies = Container:new() -- Category 3
	items = Container:new() --Category 4
	walls = Container:new()  -- Category 5
	bullets = Container:new()  -- Category 6
	particles = Container:new() -- (Category 7) by now no category
	envir = Container:new()	--shadowed EnvObjects
	envirsh = Container:new() --non shadowed EnvObjects
	npcs = Container:new() --Category 7

	lights = Lights:create()
	lights:add(0.6, 0.6, 0.06, true, nil, 1, 0.6, 0.6)
--	lights:add(0.8, 0.5, 0.08, true)
	lights:add(1, 0.4, 0.1, true, nil, 0.6, 1, 0.6)
--	lights:add(1.2, 0.5, 0.08, true)
	lights:add(1.4, 0.6, 0.06, true, nil, 0.6, 0.6, 1)

	Magic:init()
	Item:init()
	Inventory:init()
	Enemy:init()
	npc:init()

	walls:add(Brick:new(16/9, 0-0.05, 16/9*2, 0.1, "floor"))
	walls:add(Brick:new(16/9*2+0.05, 0.5, 0.1, 1, "wall"))
	walls:add(Brick:new(16/9, 1+0.05, 16/9*2, 0.1, "floor"))
	walls:add(Brick:new(0-0.05, 0.5, 0.1, 1, "wall"))

	envir:add(EnvObject:new(1, 0.5, ChestImg, true, 10000, 0.3))
	envirsh:add(Torch:new(0.5, 0.1))

	func = lights:addBodyFunc()
	walls:exec(func)

	inventory1 = Inventory:new()
	inventoryMode = false
	released = true

	player1 = Player:new(100, 0.2, 0.8)
	--lights:addBody(player1)
	--enemies:add(Enemy:new(EnemyTypeRat, 1.5, 0.8))
--	enemies:add(Enemy:new(EnemyTypeMadwizard, 1, 0.8))

	npcs:add(npc:new(NpcTypeMerchant,0.4,0.8))

--	items:add(Item:new(0.5,0.8,WandObj))
	--items:add(Item:new(0.6,0.8,WandObj))
	--items:add(Item:new(0.7,0.8,WandObj))
	--items:add(Item:new(0.8,0.8,ClothObj))
	--items:add(Item:new(0.9,0.8,ClothObj))
	--items:add(Item:new(0.2,0.8,ClothObj))

	--items:exec(func)
	--enemies:exec(func)
	envir:exec(func)


	width = love.graphics.getWidth()
	height = love.graphics.getHeight()
	print(width,camera._x)
	camera:setBounds(0, 0, width * 2  , height)
	camera:setPosition(0,width/2)

	backgr = love.graphics.newQuad(0, 0, plen(16/9*2), plen(1), BrickImg:getDimensions())

end



function love.update(dt)
	----------------PROCESSING GESTURE----------------------
	gesture = getLastMovement()
	local i = 1
	if gesture ~= nil then
		while gesture[i] ~= 10 do   --check for end code
			if gesture[i] == 1 then
			elseif gesture[i] == 2 then
				local x, y = player1:getMagicCoords()
				if Magic:canShoot(player1, MagicTypeGround) then bullets:add(Magic:new(x, y, 50*player1.side, 1, MagicTypeGround, "player")) end
			elseif gesture[i] == 3 then
				local x, y = player1:getMagicCoords()
				if Magic:canShoot(player1, MagicTypeWater) then bullets:add(Magic:new(x, y, 50*player1.side, 1, MagicTypeWater, "player")) end
			elseif gesture[i] == 4 then
				local x, y = player1:getMagicCoords()
				if Magic:canShoot(player1, MagicTypeFire) then bullets:add(Magic:new(x, y, 50*player1.side, 1, MagicTypeFire, "player")) end
			elseif gesture[i] == 5 then

			elseif gesture[i] == 6 then
				local x, y = player1:getMagicCoords()
				if Magic:canShoot(player1, MagicTypeAir) then bullets:add(Magic:new(x, y, 50*player1.side, 1, MagicTypeAir, "player")) end
			elseif gesture[i] == 7 then

			elseif gesture[i] == 8 then
				local x, y = player1:getMagicCoords()
				if Magic:canShoot(player1, MagicTypeIce) then bullets:add(Magic:new(x, y, 50*player1.side, 1, MagicTypeIce, "player")) end
			end
			i = i+1
		end
	end
	-----------------------------------------------------

	local dx = camera._x + width / 2 - player1.body:getX()
	local dy = camera._y + height / 2 - player1.body:getY()

	player1:updateSpeed()
	enemies:update(dt)
	npcs:update(dt) --new FICHA
	camera:move(dx*4*dt,dy*10*dt)  --smooth  movement with bounds

	if love.keyboard.isDown("e") then
		local tmp = items.list

		while tmp ~= nil do
			if tmp.value.ItemCanBeTaken == true and inventory1:getFirstEmpty() ~= -1 then
				inventory1:addItem(tmp.value)
				tmp.value:despawn()
				tmp.value:destroy()
			end

			tmp = tmp.next
		end
	end

	world:update(dt) --update the whole world
	bullets:update(dt)
	particles:update(dt)
	player1:update(dt)
	envir:update(dt)
	envirsh:update(dt)
	if partSys ~= nil then partSys:update(dt) end

	-- Clear fixture hit list.
	Ray.hitList = {}
end

function love.draw()
	if not inventoryOpen then loadMovement() end

	camera:set()

	lights:draw(camera._x, camera._y)

	love.graphics.draw(BrickImg, backgr)
	--so this is game
	--this game is not shit


	love.graphics.setColor(1, 1, 1)

	if not inventoryMode then bullets:CheckDraw() end
	walls:CheckDraw()
	particles:CheckDraw()
	enemies:CheckDraw()
	items:CheckDraw()
	envir:CheckDraw()
	envirsh:CheckDraw()
	npcs:CheckDraw()

	player1:draw()

	lights:endDraw()

	if lights.triGl ~= nil and lights.lightss ~= nil and false then  --lighting debugger
		j = 1
		prev = 1
		for j = 1, 50 do
			if lights.lightss[j][4] > 0 then
				for i = prev, lights.lightss[j][3] do
					love.graphics.polygon("line", lights.triGl[i][1], lights.triGl[i][2], lights.triGl[i][3], lights.triGl[i][4], lights.lightss[j][1], lights.lightss[j][2])
				end
				prev = lights.lightss[j][3]+1
			end
		end
	end

	camera:unset()
	if inventoryOpen then
		inventory1:draw()
		inventory1:checkInventoryMode()
		if cursorItem ~= nil then
			mx, my = love.mouse.getPosition()
			local scl, h, w = imageProps(0.15, cursorItem)
			love.graphics.draw(cursorItem, mx, my, 0, scl)
		end
		--love.graphics.draw(MinecraftInv, 240, 20)
	else
		cursorItem = nil
		love.mouse.setVisible(true)
	end

	love.graphics.print(tostring(love.timer.getFPS( )), 10, 10)
	--love.graphics.print(tostring(player1.hp), 10, 10)
	player1:drawHP()

end

function math.clamp(x, min, max)
	return x < min and min or (x > max and max or x)
end
