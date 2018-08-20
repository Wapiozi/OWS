screens = {}
screens.__index = screens

screens.mainRightClick = function(elem)
    player1:moveRight()
end

screens.mainLeftClick = function(elem)
    player1:moveLeft()
end

screens.mainUpClick = function(elem)
    player1:jump()
end

screens.mainRightLeftRelease = function(elem)
    player1:stop()
end

screens.mainRightDraw = function(elem)
    if elem.state then
        screens.holoshader:send("tarColor", {0, 0.1, math.random(0.8,1), math.min(0.4 + elem.time*4, 1)})
    else
        screens.holoshader:send("tarColor", {0, 0.1, math.random(0.8,1), math.max(0.9 - elem.time*4, 0.4)})
    end

    love.graphics.setShader(screens.holoshader)
    love.graphics.draw(elem.backgr, elem.x, elem.y, 0, elem.backscale)
    --love.graphics.setShader()

    love.graphics.setShader(screens.neonShader)
    love.graphics.draw(elem.foregr, elem.x + plen(0.03), elem.y+plen(0.02), 0, elem.forescale)
    love.graphics.setShader()


end

screens.mainLeftDraw = function(elem)
    if elem.state then
        screens.holoshader:send("tarColor", {0, 0.1, math.random(0.8,1), math.min(0.4 + elem.time*4, 1)})
    else
        screens.holoshader:send("tarColor", {0, 0.1, math.random(0.8,1), math.max(0.9 - elem.time*4, 0.4)})
    end
    love.graphics.setShader(screens.holoshader)
    love.graphics.draw(elem.backgr, elem.x, elem.y, 0, elem.backscale)
    --love.graphics.setShader()

    love.graphics.setShader(screens.neonShader)
    love.graphics.draw(elem.foregr, elem.x + plen(0.03) + plen(elem.fwid), elem.y+plen(0.02), 0, -elem.forescale, elem.forescale)
    love.graphics.setShader()


end

screens.mainUpDraw = function(elem)
    if elem.state then
        screens.holoshader:send("tarColor", {0, 0.1, math.random(0.8,1), math.min(0.4 + elem.time*4, 1)})
    else
        screens.holoshader:send("tarColor", {0, 0.1, math.random(0.8,1), math.max(0.9 - elem.time*4, 0.4)})
    end
    love.graphics.setShader(screens.holoshader)
    love.graphics.draw(elem.backgr, elem.x, elem.y + plen(elem.bwid), math.pi*1.5, elem.backscale)
    --love.graphics.setShader()

    love.graphics.setShader(screens.neonShader)
    love.graphics.draw(elem.foregr, elem.x + plen(0.02), elem.y+plen(elem.fwid) + plen(0.03), math.pi*1.5, elem.forescale)
    love.graphics.setShader()

end

screens.hpDraw = function(elem)
    screens.holoshader:send("tarColor", {0, 0.1, math.random(0.8,1), 0.6})
    love.graphics.setShader(screens.holoshader)
    love.graphics.draw(elem.backgr, elem.x, elem.y, 0, elem.backscale)
    love.graphics.setShader()

    screens.neonShader:send("fill", player1.hp/player1.maxHP)
    screens.neonShader:send("tarColor", {1, 0.1, 0, 1})
    love.graphics.setShader(screens.neonShader)
    love.graphics.draw(elem.foregr, elem.x+plen(0.04), elem.y + plen(0.022), 0, elem.forescale)
    love.graphics.setShader()

    screens.neonShader:send("fill", player1.mana/player1.maxMana)
    screens.neonShader:send("tarColor", {0, 1, 0, 1})
    love.graphics.setShader(screens.neonShader)
    love.graphics.draw(elem.foregr, elem.x+plen(0.04), elem.y+plen(0.07), 0, elem.forescale)
    love.graphics.setShader()

    screens.neonShader:send("tarColor", {1, 0.2, 0, 1})
    screens.neonShader:send("fill", 1)
end

function screens:init()
    self.movBackgr = love.graphics.newImage("UI/textures/movBut.png")
    self.arrow = love.graphics.newImage("UI/textures/arrow.png")
    self.hpBackgr = love.graphics.newImage("UI/textures/hologram.png")
    self.hpLine = love.graphics.newImage("UI/textures/hpLine.png")

    self.holoshader = love.graphics.newShader("shaders/UIholo.frag")
    self.neonShader = love.graphics.newShader("shaders/neon.frag")
end

function screens:addPicsToElem(elem, image1, h1, image2, h2)
    elem.backgr = image1
    elem.foregr = image2
    elem.backscale, elem.bwid, elem.bhig = imageProps(h1, image1)
    elem.forescale, elem.fwid, elem.fhig = imageProps(h2, image2)
end

function screens:mainScreenSet()
    self.rightButton = UI:newCustomElement(0.25, 0.85, 0.20, 0.14, screens.mainRightClick, screens.mainRightLeftRelease, screens.mainRightDraw)
    self:addPicsToElem(self.rightButton, self.movBackgr, 0.14, self.arrow, 0.1)

    self.leftButton = UI:newCustomElement(0.05, 0.85, 0.2, 0.14, screens.mainLeftClick, screens.mainRightLeftRelease, screens.mainLeftDraw)
    self:addPicsToElem(self.leftButton, self.movBackgr, 0.14, self.arrow, 0.1)

    self.upButton = UI:newCustomElement(0.05, 0.65, 0.14, 0.2, screens.mainUpClick, nil, screens.mainUpDraw)
    self:addPicsToElem(self.upButton, self.movBackgr, 0.14, self.arrow, 0.1)

    self.upButton = UI:newCustomElement(flen(screenWidth) - 0.19, 0.65, 0.14, 0.2, screens.mainUpClick, nil, screens.mainUpDraw)
    self:addPicsToElem(self.upButton, self.movBackgr, 0.14, self.arrow, 0.1)

    UI:newGestureElement()

	--test button
	local onClick = function(element)
		local x, y = player1:getMagicCoords()
		bullets:add(Magic:new(x, y, 1*player1.side, 0, MagicTypeGround, "player"))
	end

	UI:newTextButton(0.3, 0.3, 0.2, 0.05, "fuck the system", onClick)

    self.playerStats = UI:newCustomElement(0.01, 0.01, 0.2667, 0.10, nil, nil, screens.hpDraw)
    self:addPicsToElem(self.playerStats, self.hpBackgr, 0.14, self.hpLine, 0.04)

    
end

function screens:update(dt)
    self.holoshader:send("time", love.timer.getTime())
    self.holoshader:send("tarColor", {0, 0.1, math.random(0.8,1), 0.4})  --color of hologram

    self.neonShader:send("tarColor", {1, 0.2, 0, 1})
    self.neonShader:send("fill", 1)
end
