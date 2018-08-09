libitems = require("OWS/lua_objects/items")
libenemy = require("OWS/lua_AI/enemy")
libplayer = require("OWS/player")
libcamera = require("OWS/camera")
libbrick = require("OWS/lua_objects/brick")
libcont = require("OWS/container")
libenv = require("OWS/lua_objects/envobjects")
libtraps = require("OWS/lua_objects/traps")
suit = require ("OWS/SUIT")

world = nil

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

lightCont = Container:new()

lights = {}
lights.__index = lights

function lights:add(x, y, bright, isFired, fbody, r, g, b)
	self = setmetatable({}, self)

	x, y = pcoords(x, y)

	self.name = "light"
    self.body = love.physics.newBody(world, x, y, "static")
	self.shape = love.physics.newRectangleShape(20, 20)
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setUserData(self)

	self.bright = bright
	self.r, self.g, self.b = r, g, b

	lightCont:add(self)
end

function lights:draw()
	local rr, gg, bb, aa = love.graphics.getColor()
	love.graphics.setColor(self.r, self.g, self.b, 1)
	love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
	love.graphics.setColor(rr, gg, bb, aa)
end

joint = nil
deltPos = {x = 0, y = 0}
obj = nil
showAll = false

function catch(fixt)
	obj = fixt:getUserData()

	local x, y = love.mouse.getPosition()

	x = camera._x + x
	y = camera._y + y

	deltPos.x = obj.body:getX() - x
	deltPos.y = obj.body:getY() - y

	if obj.name == "brick" then
		sizexInp = {text = tostring(obj.sizex)}
		sizeyInp = {text = tostring(obj.sizey)}
		angleInp = {text = tostring(obj.body:getAngle())}
		meanInp = {text = obj.mean}
	elseif obj.name == "enemy" then
		typeInp = {text = obj.type.name}
	elseif obj.name == "EnvObject" then
		if obj.nextLocation ~= nil then
			nextLocInp = {text = obj.nextLocation}
			spawnIndInp = {text = tostring(obj.spawnInd)}
		end
	elseif obj.name == "light" then
		rval = {value = obj.r, max = 1}
		gval = {value = obj.g, max = 1}
		bval = {value = obj.b, max = 1}
		brightInp = {text = tostring(obj.bright)}
	end

	return false
end

function ts(num)
	return tostring(num)
end
c = ","

function writeBricks(obj)
	local xx, yy = fcoords(obj.body:getPosition())
	io.write("walls:add(Brick:new(" .. ts(xx) .. c .. ts(yy) .. c .. ts(obj.sizex) .. c .. ts(obj.sizey) .. c .. "\"" .. obj.mean .. "\"" .. c .. ts(obj.body:getAngle()) .. c .. "LaserImg))\n")
end

function writeEnemies(obj)
	local xx, yy = fcoords(obj.body:getPosition())
	io.write("enemies:add(Enemy:new(".. obj.type.name .. c .. ts(xx) .. c .. ts(yy).."))\n")
end

function writeLights(obj)
	local xx, yy = fcoords(obj.body:getPosition())
	io.write("lights:add(" .. ts(xx) .. c .. ts(yy) .. c .. ts(obj.bright) .. ",false,nil," .. ts(obj.r) .. c .. ts(obj.g) .. c .. ts(obj.b) .. ")\n")
end

function writeTransitions(obj)
	if obj.nextLocation == nil then return end
	local xx, yy = fcoords(obj.body:getPosition())
	io.write("envirsh:add(Transition:new(" .. ts(xx) .. c .. ts(yy) .. c .. "\"" .. obj.nextLocation .. "\"" .. c .. ts(obj.spawinInd) .. "))\n")
end

function writeSpawns(obj)
	if obj.nextLocation == nil then return end
	local xx, yy = fcoords(obj.body:getPosition())
	io.write("{x = " .. ts(xx) .. c .. "y = " .. ts(yy) .. "},\n")
end
------------------------KEYBOARD---------------------------------------

function love.keypressed(key)
	suit.keypressed(key)
end

function love.mousepressed(x, y, button, istouch, presses)
	if x < 340 and y < 200 then return end
	x = camera._x + x
	y = camera._y + y
	world:queryBoundingBox(x - 10, y - 10, x + 10, y + 10, catch)
end

disableMovement = false

function love.mousemoved( x, y, dx, dy, istouch )
	if x < 340 and y < 200 then return end
	x = camera._x + x
	y = camera._y + y
	if obj ~= nil and love.mouse.isDown(1) then
		obj.body:setPosition(x + deltPos.x, y + deltPos.y)
	end
end

function love.textinput(t)
    suit.textinput(t)
end

function CreateButtons()
	local mx, my = love.mouse.getPosition()
	if suit.Button("Create Brick", 10,50, 100,30).hit then
		walls:add(Brick:new(flen(mx+curPos.x), flen(my+curPos.y), 0.5, 0.1, "floor", 0, LaserImg))
		showAll = false
    end
	if suit.Button("Create Enemy", 10,90, 100,30).hit then
		enemies:add(Enemy:new(EnemyTypeBat, flen(mx+curPos.x), flen(my+curPos.y)))
		showAll = false
    end
	if suit.Button("Create Transition", 10,130, 100,30).hit then
		envirsh:add(Transition:new(flen(mx+curPos.x), flen(my+curPos.y), "maps/start", 1))
		showAll = false
    end
	if suit.Button("Create Light", 10, 180, 100,30).hit then
		lights:add(flen(mx+curPos.x), flen(my+curPos.y), 0.2, false, nil, 1, 1, 1)
		showAll = false
    end
end

sizexInp = {text = ""}
sizeyInp = {text = ""}
angleInp = {text = ""}
meanInp = {text = ""}
typeInp = {text = ""}
nextLocInp = {text = ""}
spawnIndInp = {text = ""}
brightInp = {text = ""}
rval = {value = 0, max = 1}
gval = {value = 0, max = 1}
bval = {value = 0, max = 1}

function ShowProperties()
	if obj.name == "brick" then
		suit.Input(sizexInp, 120, 10, 200, 30)
		suit.Input(sizeyInp, 120, 50, 200, 30)
		suit.Input(angleInp, 120, 90, 200, 30)
		suit.Input(meanInp, 120, 130, 200, 30)

		local newx, newy = tonumber(sizexInp.text), tonumber(sizeyInp.text)
		local newAngle = tonumber(angleInp.text)

		if newx ~= nil and newy ~= nil and newx > 0 and newy > 0 and (newx ~= obj.sizex or newy ~= obj.sizey) then
			obj:resize(newx, newy)
	 	end
		if newAngle ~= nil and newAngle ~= obj.body:getAngle() then obj.body:setAngle(newAngle) end
		if meanInp ~= nil and meanInp ~= obj.mean and (meanInp == "floor" or meanInp == "wall") then obj.mean = meanInp end
	elseif obj.name == "enemy" then
		suit.Label(typeInp.text, {align="left"}, 120, 10, 200, 30)
		for i = 1, 5 do
			if suit.Button(EnemyTypes[i].name, 120, 10 + i*40, 200, 30).hit then
				local x, y = obj.body:getPosition()
				obj:destroy()
				obj = Enemy:new(EnemyTypes[i], flen(x), flen(y))
				enemies:add(obj)
		    end
		end
	elseif obj.name == "EnvObject" then
		if obj.nextLocation ~= nil then --if Transition
			suit.Input(nextLocInp, 120, 10, 200, 30)
			suit.Input(spawnIndInp, 120, 50, 200, 30)

			local newLoc = nextLocInp.text
			local newSpawn = tonumber(spawnIndInp.text)

			if newLoc ~= nil and newLoc ~= obj.nextLocation then obj.nextLocation = newLoc end
			if newSpawn ~= nil and newSpawn ~= obj.spawnInd then obj.spawnInd = newSpawn end
		end
	elseif obj.name == "light" then
		suit.Slider(rval, 120, 10, 200, 30)
		suit.Slider(gval, 120, 50, 200, 30)
		suit.Slider(bval, 120, 90, 200, 30)
		suit.Input(brightInp, 120, 130, 200, 30)

		local newBright = tonumber(brightInp.text)
		local newr = rval.value
		local newg = gval.value
		local newb = bval.value

		if obj.r ~= newr then obj.r = rval.value end
		if obj.g ~= newg then obj.g = gval.value end
		if obj.b ~= newb then obj.b = bval.value end

		if newBright ~= nil and newBright ~= obj.bright then obj.bright = newBright end
	end
	if suit.Button("delete", 340, 10, 100, 30).hit then
		destroyer.destroy(obj)
		obj = nil
	end
end

-- Standart ------------------------------------------------------------

function love.load(arg)
	-----------RESOURCES LOAD----------------------------------

	-- Sprites
	PlayerImg = love.graphics.newImage("OWS/sprites/creatures/Player.png")
	MinecraftInv = love.graphics.newImage("OWS/sprites/inventory/minecraft.png")
	InvborderImg = love.graphics.newImage("OWS/sprites/inventory/inventory_border.png")
	MessageImg = love.graphics.newImage("OWS/sprites/creatures/message.png")
	TransitionImg = love.graphics.newImage("OWS/sprites/WTF_BALLS/Enemy.jpg")
	--creatures
		-- enemies
			EnemyMadwizardImg = love.graphics.newImage("OWS/sprites/creatures/EnemyMadwizard.png")
			EnemyRatImg = love.graphics.newImage("OWS/sprites/creatures/EnemyRat.png")
			EnemyBatImg = love.graphics.newImage("OWS/sprites/creatures/EnemyRat.png")
		--NPC
			NpcMerchantImg = love.graphics.newImage("OWS/sprites/creatures/merchant.png")
			NpcChallengeImg = love.graphics.newImage("OWS/sprites/creatures/challenge.png")
	-- magic
		FireballImg = love.graphics.newImage("OWS/sprites/magic/Fireball.png")
		WaterballImg = love.graphics.newImage("OWS/sprites/magic/Fireball.png")
		AirballImg = love.graphics.newImage("OWS/sprites/magic/Fireball.png")
		IceballImg = love.graphics.newImage("OWS/sprites/magic/Fireball.png")
		GroundballImg = love.graphics.newImage("OWS/sprites/magic/Fireball.png")
		LaserImg = love.graphics.newImage("OWS/sprites/magic/laser.png") LaserImg:setWrap("repeat", "repeat")
	-- objects
		-- items
			WandSdImg = love.graphics.newImage("OWS/sprites/items/palka.png")
			ClothSdImg = love.graphics.newImage("OWS/sprites/items/majka.png")
		-- interior
			ChestImg = love.graphics.newImage("OWS/sprites/env_obj/chest.png")
			TorchImg = love.graphics.newImage("OWS/sprites/env_obj/torch.png")
		-- traps
			SpikeImg = love.graphics.newImage("OWS/sprites/traps/spikes.png")
	-- bg
		BrickImg = love.graphics.newImage("OWS/sprites/bg/brick.png") BrickImg:setWrap("repeat", "repeat")
		BlueBrick = love.graphics.newImage("OWS/sprites/bg/brick2.png") BlueBrick:setWrap("repeat", "repeat")
	-- particles
		FireImg = love.graphics.newImage("OWS/sprites/particles/fire.png")
		FireeImg = love.graphics.newImage("OWS/sprites/particles/firee.png")



	--------------------------------------------------------------

	love.window.setMode(1280,720)
	screenWidth, screenHeight = love.window.getMode()

	world = love.physics.newWorld(0, 0)

	Item:init()
	Enemy:init()
	Traps:init()

	player1 = Player:new(0.2, 0.8)

	curPos = {x = 0.2, y = 0.8}


	camera:setPosition(0,screenWidth/2)

	---------------CREATING ROOM--------------------------
	currentMap = dofile("OWS/maps/BigRoom"..".lua")

	enemies = Container:new() -- Category 3
	items = Container:new() --Category 4
	walls = Container:new()  -- Category 5
	traps = Container:new()
	envir = Container:new()	--shadowed EnvObjects
	envirsh = Container:new() --non shadowed EnvObjects

	--pcall(loadMap, 1)

	backgr = love.graphics.newQuad(plen(-100), plen(-100), plen(200), plen(200), BrickImg:getDimensions())

	----------------END OF CREATING ROOM------------------
	camera:setBounds(plen(-1000), plen(-1000), plen(1000), plen(1000))
end



function love.update(dt)
	if love.keyboard.isDown("a") then curPos.x = curPos.x - 10 end
	if love.keyboard.isDown("d") then curPos.x = curPos.x + 10 end
	if love.keyboard.isDown("w") then curPos.y = curPos.y - 10 end
	if love.keyboard.isDown("s") then curPos.y = curPos.y + 10 end

	local dx = camera._x + screenWidth / 2 - curPos.x
	local dy = camera._y + screenHeight / 2 - curPos.y
	--camera:move(dx*4*dt,dy*10*dt)

	camera:setPosition(curPos.x,curPos.y)

	if suit.Button("Create", 10,10, 50,30).hit then
		showAll = true
    end
	if suit.Button("Export map", 1190, 10, 80, 30).hit then
		file = io.open("outMap.lua", "w")
		io.output(file)

		io.write("spawnPoints = { \n ")
		envirsh:exec(writeSpawns)
		io.write("\n} \n \n")

		io.write("function loadMap(transitionInd)\n")

		io.write("player1:setPosition(spawnPoints[transitionInd].x,spawnPoints[transitionInd].y)\ncamera:setBounds(0,0,screenWidth*4,screenHeight*3)\ncamera:setPosition(0,screenWidth/2)\n")

		walls:exec(writeBricks)
		enemies:exec(writeEnemies)
		lightCont:exec(writeLights)
		envirsh:exec(writeTransitions)

		io.write("backgr = love.graphics.newQuad(plen(-100), plen(-100), plen(200), plen(200), BrickImg:getDimensions())")

		io.write("end")

		io.close(file)
    end
	if showAll then CreateButtons() end
	if obj ~= nil then ShowProperties(obj) end
end

function love.draw()
	-------------------START DRAWING ROOM-------------------
	camera:set()

	love.graphics.draw(BrickImg, backgr)

	love.graphics.setColor(1, 1, 1)

	envirsh:CheckDraw()
	envir:CheckDraw()
	walls:CheckDraw()
	traps:CheckDraw()
	enemies:CheckDraw()
	items:CheckDraw()
	lightCont:CheckDraw()
	player1:draw()

	camera:unset()

	love.graphics.line(340, 0, 340, 200)
	love.graphics.line(0, 200 , 340, 200)

	suit.draw()

end

function math.clamp(x, min, max)
	return x < min and min or (x > max and max or x)
end
