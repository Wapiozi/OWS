mgest = require("lua_gesture/mgesture")
libmagic = require("lua_Magic/magic")
libitems = require("lua_objects/items")
libinven = require("inventory")
libenemy = require("lua_AI/enemy")
libgraph = require("lua_AI/graph")
libplayer = require("player")
libcamera = require("camera")
libbrick = require("lua_objects/brick")
libcont = require("container")
libparticles = require("lua_graphic/particles")
liblighting = require("lua_graphic/lighting")
libenv = require("lua_objects/envobjects")
libtraps = require("lua_objects/traps")
suit = require ("SUIT")
libbuttons = require ("Buttons")
--libnpc = require("npc")
utf8 = require("utf8")

world = nil
inventoryOpen = false
questMenuOpen = false

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

function getDist(x1, y1, x2, y2)
    local dist = math.sqrt((x2-x1) ^ 2 + (y2 - y1) ^ 2)
    return dist
end

destroyer = {}
destroyer.__index = destroyer

function destroyer:destroy()
	self.canDelete = true
	if self.fixture ~= nil then self.fixture:destroy() end
	if self.shape ~= nil then self.shape:release() end
	if self.body ~= nil then self.body:destroy() end
end

--------------WORLD CALLBACK--------------------------------------

--[[
function internalContactFilter(fixtureA, fixtureB)
	obj1 = fixtureA:getUserData()
	obj2 = fixtureB:getUserData()

	if obj1.notCollide == obj2.index then


	end
end
]]--
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

			if obj1.name == 'EnvObject' then
				obj1.canInteract = true
			elseif obj2.name == 'EnvObject' then
				obj2.canInteract = true
			end

			if (obj1.name == "magic") and (obj1.owner ~= "player") then
				obj2:getDamage(obj1.damage)
			elseif (obj2.name == "magic") and (obj2.owner ~= "player") then
				obj1:getDamage(obj2.damage)
			end

			if (obj1.name == "brick") and (obj1.mean == "floor") then
				obj2:collidedWithFloor()
			elseif (obj2.name == "brick") and (obj2.mean == "floor") then
				obj1:collidedWithFloor()
			end

			if (obj1.name == "trap") then
				obj2:getDamage(obj1:attack(obj2))
			elseif (obj2.name == "trap") then
				obj1:getDamage(obj2:attack(obj1))
			end

		end

		if obj1.name == "enemy" or obj2.name == "enemy" then

			if (obj1.name == "magic") and (obj1.owner ~= "enemy") then
				obj2:getDamage(obj1.damage)
			elseif (obj2.name == "magic") and (obj2.owner ~= "enemy") then
				obj1:getDamage(obj2.damage)
			end

			if (obj1.name == "trap") then
				obj2:getDamage(obj1:attack(obj2))
			elseif (obj2.name == "trap") then
				obj1:getDamage(obj2:attack(obj1))
			end
		end
		end

	if (obj1 ~= nil) and (not obj2.fixture:isSensor()) and (obj1.name == "magic") then
		obj1:collision()
	end
	if (obj2 ~= nil) and (not obj1.fixture:isSensor()) and (obj2.name == "magic") then
		obj2:collision()
	end

	if (obj1 ~= nil) and (obj1.name == "enemy") and (obj1.behaviour.movement ~= "stop") and (obj1.player_detect == false) and (obj2 ~= nil) and ((obj2.name ~= "brick") or (obj2.mean ~= "floor")) and (obj2.name ~= "magic") then
		obj1.side = obj1.side * -1
		obj1.movDirection = obj1.side * obj1.imgturn
		obj1.step = love.math.random(1000,1000)
		--if obj2.type.enemyType == 'fly' then
		--	obj1.movDirectionY = obj1.movDirectionY * -1
		--end
	end
	if (obj2 ~= nil) and (obj2.name == "enemy") and (obj2.behaviour.movement ~= "stop") and (obj2.player_detect == false) and (obj1 ~= nil) and ((obj1.name ~= "brick") or (obj1.mean ~= "floor")) and (obj2.name ~= "magic") then
		obj2.side = obj2.side * -1
		obj2.movDirection = obj2.side * obj2.imgturn
		obj2.step = love.math.random(1000,1000)
		--if obj2.type.enemyType == 'fly' then
		--	obj2.movDirectionY = obj2.movDirectionY * -1
		--end
	end

	if (obj1 ~= nil) and (obj2 ~= nil) and (obj1.name == "enemy") and (obj1.behaviour.attack == "fly_contact") and (obj2.name == 'player') then
		local x1, y1 = obj1.body:getPosition()
		local x2, y2 = obj2.body:getPosition()

		local movDirection, movDirectionY
		if (x1 < x2) then
			movDirection = 1
		else
			movDirection = -1
		end
		if (y1 < y2) then
			movDirectionY = 1
		else
			movDirectionY = -1
		end

		obj2:getDamage(obj1.type.Damage)
		obj2.body:applyLinearImpulse(50000 * - movDirection, 50000 * -movDirectionY)
	end

	if (obj1 ~= nil) and (obj2 ~= nil) and (obj2.name == "enemy") and (obj2.behaviour.attack == "fly_contact") and (obj1.name == 'player') then
		local x1, y1 = obj1.body:getPosition()
		local x2, y2 = obj2.body:getPosition()

		local movDirection, movDirectionY

		if (x1 < x2) then
			movDirection = 1
		else
			movDirection = -1
		end
		if (y1 < y2) then
			movDirectionY = 1
		else
			movDirectionY = -1
		end
		obj1:getDamage(obj2.type.Damage)
		obj1.body:applyLinearImpulse(50000 * - movDirection, 50000 * -movDirectionY)
	end

end

function endContact(f1, f2, cont)
 	obj1 = f1:getUserData()
	obj2 = f2:getUserData()


	if (obj1 ~= nil) and (obj2 ~= nil) then
		if obj1.name == 'player' or obj2.name == 'player' then
--Haha, classic
			if obj1.name == 'item' then
				obj1.ItemCanBeTaken = false
			elseif obj2.name == 'item' then
				obj2.ItemCanBeTaken = false
			end

			if obj1.name == 'player' then
				obj1.speed = 0.45
			elseif obj2.name == 'player' then
				obj2.speed = 0.45
			end
			if obj1.name == 'EnvObject' then
				obj1.canInteract = false
			elseif obj2.name == 'EnvObject' then
				obj2.canInteract = false
			end
		end
	end
end

function preSolve(body_a, body_b, collision)

end

function postSolve(body_a, body_b, collision, normalimpulse, tangentimpulse)

end

------------------------KEYBOARD---------------------------------------
function utf8.sub(str,x,y) -- russian letters
  local x2,y2
  x2=utf8.offset(str,x)
  if y then
    y2=utf8.offset(str,y+1)
    if y2 then
      y2=y2-1
    end
  end
  print(x,y,"|",x2,y2)
  return string.sub(str,x2,y2)
end

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
		bullets:add(Magic:new(x, y, 1*player1.side, 0, MagicTypeWater, "player"))
	end

	if (key == "i") then
		if inventoryOpen then
			inventoryOpen = false
		elseif not inventoryOpen then
			inventoryOpen = true
		end
	end

	if (key == "j") then
		if questMenuOpen then
			questMenuOpen = false
		elseif not questMenuOpen then
			questMenuOpen = true
		end
	end

	if (key == 'c') then
		local tmfunc = function(obj)
			obj:interact(player1)
		end
		envir:exec(tmfunc)
		envirsh:exec(tmfunc)
	end

	if (key == 'e') then
		items:exec(inventory1.containerFunc)
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

function eraseMap()
	enemies:exec(destroyer.destroy)
	items:exec(destroyer.destroy)
	walls:exec(destroyer.destroy)
	traps:exec(destroyer.destroy)
	bullets:exec(destroyer.destroy)
	envir:exec(destroyer.destroy)
	envirsh:exec(destroyer.destroy)

	enemies = Container:new() -- Category 3
	items = Container:new() --Category 4
	walls = Container:new()  -- Category 5
	traps = Container:new()
	bullets = Container:new()  -- Category 6
	particles = Container:new() -- (Category 7) by now no category
	envir = Container:new()	--shadowed EnvObjects
	envirsh = Container:new() --non shadowed EnvObjects

	lights = nil
	lights = Lights:create()
end

function endLoadMap()
	func = lights:addBodyFunc()
	envir:exec(func)
	walls:exec(func)
end

-- Standart ------------------------------------------------------------

function love.load(arg)
	-----------RESOURCES LOAD----------------------------------
	-- Sprites
	PlayerImg = love.graphics.newImage("sprites/creatures/Player.png")
	MinecraftInv = love.graphics.newImage("sprites/inventory/minecraft.png")
	InvborderImg = love.graphics.newImage("sprites/inventory/inventory_border.png")
	MessageImg = love.graphics.newImage("sprites/creatures/message.png")
	TransitionImg = love.graphics.newImage("sprites/WTF_BALLS/Enemy.jpg")
	--creatures
		-- enemies
			EnemyMadwizardImg = love.graphics.newImage("sprites/creatures/EnemyMadwizard.png")
			EnemyRatImg = love.graphics.newImage("sprites/creatures/EnemyRat.png")
			EnemyBatImg = love.graphics.newImage("sprites/creatures/EnemyRat.png")
		--NPC
			NpcMerchantImg = love.graphics.newImage("sprites/creatures/merchant.png")
			NpcChallengeImg = love.graphics.newImage("sprites/creatures/challenge.png")
	-- magic
		FireballImg = love.graphics.newImage("sprites/magic/Fireball.png")
		WaterballImg = love.graphics.newImage("sprites/magic/Fireball.png")
		AirballImg = love.graphics.newImage("sprites/magic/Fireball.png")
		IceballImg = love.graphics.newImage("sprites/magic/Fireball.png")
		GroundballImg = love.graphics.newImage("sprites/magic/Fireball.png")
		LaserImg = love.graphics.newImage("sprites/magic/laser.png") LaserImg:setWrap("repeat", "repeat")
	-- objects
		-- items
			WandSdImg = love.graphics.newImage("sprites/items/palka.png")
			ClothSdImg = love.graphics.newImage("sprites/items/majka.png")
		-- interior
			ChestImg = love.graphics.newImage("sprites/env_obj/chest.png")
			TorchImg = love.graphics.newImage("sprites/env_obj/torch.png")
		-- traps
			SpikeImg = love.graphics.newImage("sprites/traps/spikes.png")
			SlowImg = love.graphics.newImage("sprites/traps/slow.png")
	-- bg
		BrickImg = love.graphics.newImage("sprites/bg/brick.png")
		BlueBrick = love.graphics.newImage("sprites/bg/brick2.png") BlueBrick:setWrap("repeat", "repeat")
	-- particles
		FireImg = love.graphics.newImage("sprites/particles/fire.png")
		FireeImg = love.graphics.newImage("sprites/particles/firee.png")

	--SUIT
	--font = love.graphics.newFont("NotoSansHans-Regular.otf", 20)
	--love.graphics.setFont(font)
	--normal, hovered, active, mask = generateImageButton()
	--------------------------------------------------------------

	love.window.setMode(1280,720)
	screenWidth, screenHeight = love.window.getMode()


	world = love.physics.newWorld(0, 9.81*100) --we need the whole world
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	Magic:init()
	Item:init()
	Inventory:init()
	Enemy:init()
	Traps:init()

	Ray = {
		x1 = 0,
		y1 = 0,
		x2 = 0,
		y2 = 0,
		hitList = {}
	}

	graph1 = Graph:new()
	player1 = Player:new(0.2, 0.8)
	inventory1 = Inventory:new()
	inventoryMode = false
	released = true

	camera:setBounds(0, 0, screenWidth * 2  , screenHeight)
	camera:setPosition(0,screenWidth/2)

	---------------CREATING ROOM--------------------------
	currentMap = dofile("maps/start"..".lua")

	enemies = Container:new() -- Category 3
	items = Container:new() --Category 4
	walls = Container:new()  -- Category 5
	traps = Container:new()
	bullets = Container:new()  -- Category 6
	particles = Container:new() -- (Category 7) by now no category
	envir = Container:new()	--shadowed EnvObjects
	envirsh = Container:new() --non shadowed EnvObjects

	lights = nil
	lights = Lights:create()

	loadMap(1)
	endLoadMap()

	----------------END OF CREATING ROOM------------------
end



function love.update(dt)
	----------------PROCESSING GESTURE----------------------
	gesture = getLastMovement()

	if gesture ~= nil then player1:shoot(gesture) end
	-----------------------------------------------------

	local dx = camera._x + screenWidth / 2 - player1.body:getX()
	local dy = camera._y + screenHeight / 2 - player1.body:getY()
	camera:move(dx*4*dt,dy*10*dt)
	player1.nearEnemies = false
	enemies:update(dt)
	player1:update(dt)
	world:update(dt)
	--npcs:update(dt) --new FICHA
	bullets:update(dt)
	particles:update(dt)
	envir:update(dt)
	envirsh:update(dt)
	traps:update(dt)

	-- Clear fixture hit list.
	Ray.hitList = {}

	--[[
	love.graphics.setColor(255,255,255)
	--but_img = suit.ImageButton(normal,{id=5, mask = mask, hovered = hovered, active = active},plen(0.4),plen(0.4))
	but_a = suit.Button("<-",{id=1, cornerRadius=plen(0.05)} , plen(0.1),plen(0.7), plen(0.15), plen(0.15))
  but_s = suit.Button(" ",{id=2, cornerRadius=plen(0.05)} , plen(0.25),plen(0.7), plen(0.15), plen(0.15))
	but_d = suit.Button("->",{id=3, cornerRadius=plen(0.05)} , plen(0.40),plen(0.7), plen(0.15), plen(0.15))
	but_w = suit.Button("^",{id=4, cornerRadius=plen(0.05)} , plen(0.25),plen(0.55), plen(0.15), plen(0.15))
	]]--
	--[[if (but_d.hit) then
		player1:moveRight()
		player1:moveRight()
	elseif (but_a.hit) then
		player1:moveLeft()
		player1:moveLeft()
	elseif (but_a.left) or (but_d.left) then
		player1.movDirection = 0
	end

	if (but_w.hit) then
		player1:jump()
	end
	]]--
	Buttons:load(1) --W A S D buttons
	Buttons:update(1) --W A S D buttons
	if questMenuOpen then
		Buttons:load(2) --W A S D buttons
  	Buttons:update(2) --W A S D buttons
  end
end

function love.draw()
	if not inventoryOpen then loadMovement() end

	-------------------START DRAWING ROOM-------------------
	camera:set()

	lights:draw(camera._x, camera._y)

	love.graphics.draw(BrickImg, backgr)

	love.graphics.setColor(1, 1, 1)


	envirsh:CheckDraw()
	envir:CheckDraw()
	walls:CheckDraw()
	traps:CheckDraw()
	particles:CheckDraw()
	enemies:CheckDraw()
	items:CheckDraw()
	player1:draw()
	if not inventoryMode then bullets:CheckDraw() end

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
	Buttons:draw(1) --W A S D buttons
	enemies:exec(Enemy.work)

	if inventoryOpen then
		inventory1:draw()
		inventory1:checkInventoryMode()
		if cursorItem ~= nil then
			mx, my = love.mouse.getPosition()
			local scl, h, w = imageProps(0.15, cursorItem)
			love.graphics.draw(cursorItem, mx, my, 0, scl)
		end
	else
		cursorItem = nil
		love.mouse.setVisible(true)
	end

	love.graphics.print(tostring(love.timer.getFPS( )), 10, 10)
	player1:drawHP()

end

function math.clamp(x, min, max)
	return x < min and min or (x > max and max or x)
end

--[[function generateImageButton()

		local stripey = function( x, y, r, g, b, a )
				return function(x,y)
   				local r = math.min(r * math.sin(x*100)*2, 1)
	   			local g = math.min(g * math.cos(x*150)*2, 1)
   				local b = math.min(b * math.sin(x*50)*2, 1)
   				return r,g,b,a
				end
		end
    local normal, hovered, active = love.image.newImageData(200,100), love.image.newImageData(200,100), love.image.newImageData(200,100)
    normal:mapPixel(stripey(.48, .74,.74,.74,.74,.48))
    return BrickImg, FireImg, FireballImg, normal
end]]--
