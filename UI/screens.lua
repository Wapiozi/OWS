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
    love.graphics.draw(elem.arrow, elem.x + plen(0.04), elem.y+plen(0.03), 0, elem.forescale)
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
    love.graphics.draw(elem.arrow, elem.x + plen(0.04) + plen(elem.wid), elem.y+plen(0.03), 0, -elem.forescale, elem.forescale)
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
    love.graphics.draw(elem.arrow, elem.x + plen(0.03), elem.y+plen(elem.fwid) + plen(0.04), math.pi*1.5, elem.forescale)
    love.graphics.setShader()

end

screens.mainRightUpdate = function(elem)

end

function screens:init()
    self.movBackgr = love.graphics.newImage("UI/textures/movBut.png")
    self.arrow = love.graphics.newImage("UI/textures/arrow.png")

    self.holoshader = love.graphics.newShader("shaders/UIholo.frag")
    self.neonShader = love.graphics.newShader("shaders/neon.frag")
end

function screens:mainScreenSet()
    self.rightButton = UI:newCustomElement(0.25, 0.85, 0.20, 0.14, screens.mainRightClick, screens.mainRightLeftRelease, screens.mainRightDraw)

    self.rightButton.backgr = self.movBackgr
    self.rightButton.arrow = self.arrow
    self.rightButton.backscale = imageProps(0.14, self.rightButton.backgr)
    self.rightButton.forescale = imageProps(0.08, self.rightButton.arrow)

    self.leftButton = UI:newCustomElement(0.05, 0.85, 0.2, 0.14, screens.mainLeftClick, screens.mainRightLeftRelease, screens.mainLeftDraw)
    self.leftButton.backgr = self.movBackgr
    self.leftButton.arrow = self.arrow
    self.leftButton.backscale = imageProps(0.14, self.leftButton.backgr)
    local fors, wid = imageProps(0.08, self.leftButton.arrow)
    self.leftButton.wid, self.leftButton.forescale = wid, fors

    self.upButton = UI:newCustomElement(0.05, 0.65, 0.14, 0.2, screens.mainUpClick, nil, screens.mainUpDraw)
    self.upButton.backgr = self.movBackgr
    self.upButton.arrow = self.arrow
    self.upButton.backscale, self.upButton.bwid, self.upButton.bhig = imageProps(0.14, self.upButton.backgr)
    self.upButton.forescale, self.upButton.fwid, self.upButton.fhig = imageProps(0.08, self.upButton.arrow)

    UI:newGestureElement()

	--test button
	local onClick = function(element)
		local x, y = player1:getMagicCoords()
		bullets:add(Magic:new(x, y, 1*player1.side, 0, MagicTypeGround, "player"))
	end

	UI:newTextButton(0.3, 0.3, 0.2, 0.05, "fuck the system", onClick)
end

function screens:update(dt)
    self.holoshader:send("time", love.timer.getTime())
    self.holoshader:send("tarColor", {0, 0.1, math.random(0.8,1), 0.4})  --color of hologram

    self.neonShader:send("tarColor", {1, 0.2, 0, 1})
end
