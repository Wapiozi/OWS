UI = {}
UI.__index = UI
UI.elements = {}

--------SORTER-----------------------------
elSorter = {}
function elSorter:__lt(next)
    if self.width ~= next.width then
        if self.width < next.width then return true end
        return false
    end

    if self.height < next.height then return true end
    return false
end

---------STANDART ELEMENT CALLBACKS--------------
function UI.standartTextDraw(button)
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(0.5, 0.5, 0.5, 0.7)
    love.graphics.rectangle("line", button.x, button.y, button.width, button.height)

    love.graphics.setColor(unpack(button.color))
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)

    love.graphics.setColor(unpack(button.textColor))
    love.graphics.printf(button.text, button.x, button.y, button.width, "center")

    love.graphics.setColor(r, g, b, a)
end

function UI.standartTextClick(button)
    if button.adcl ~= nil then button:adcl() end
    button.ftextColor = {0, 0, 0, 0.9}
    button.fcolor = {0.5, 0.5, 0.5, 0.7}
end

function UI.standartTextClickRelease(button)
    button.ftextColor = {1, 1, 1, 0.9}
    button.fcolor = {0.5, 0.5, 0.5, 0}
    button.time = 0
end

function UI.standartTextUpdate(button, dt)
    dt = dt * 10
    if button.textColor[1] < button.ftextColor[1] then
        for i = 1, 3 do button.textColor[i] = button.textColor[i] + math.min(dt, button.ftextColor[i] - button.textColor[i])  end
    elseif button.textColor[1] > button.ftextColor[1] then
        for i = 1, 3 do button.textColor[i] = button.textColor[i] - math.min(dt, button.textColor[i] - button.ftextColor[i]) end
    end

    if button.color[4] < button.fcolor[4] then
        button.color[4] = button.color[4] + math.min(dt, button.fcolor[4] - button.color[4])
    elseif button.color[4] > button.fcolor[4] then
        button.color[4] = button.color[4] - math.min(dt, button.color[4] - button.fcolor[4])
    end
end

function UI.doNothing(element)

end

----------STANDART ELEMENTS----------------------------------------------
--[[creates new text button with onClick callback function
    Example:

    function onClick(element)
        love.graphics.print("Hello!!!", element.x, element.y + element.width + plen(0.1))
    end

    UI:newTextButton(0.1, 0.1, 0.3, 0.05, "Hello!", onClick)
]]
function UI:newTextButton(x, y, width, height, text, onClick)
    x, y = pcoords(x, y)
    width, height = pcoords(width, height)

    local button = {}
    button.x, button.y = x, y
    button.width, button.height = width, height
    button.state = false
    button.text = text or "button"
    button.onClick = self.standartTextClick
    button.onDraw = self.standartTextDraw
    button.onRelease = self.standartTextClickRelease
    button.onUpdate = self.standartTextUpdate
    button.time = 0  --time from last click
    button.image = image
    button.adcl = onClick
    button.textColor = {1, 1, 1, 0.9}
    button.color = {0.5, 0.5, 0.5, 0.7}
    button.ftextColor = {1, 1, 1, 0.9}
    button.fcolor = {0.5, 0.5, 0.5, 0.7}
    setmetatable(button, elSorter)

    table.insert(self.elements, button)
    table.sort(self.elements)

    return button
end

--empty element
function UI:newCustomElement(x, y, width, height, onClick, onRelease, onDraw, onUpdate)
    x, y = pcoords(x, y)
    width, height = pcoords(width, height)

    local elem = {}

    elem.x, elem.y, elem.width, elem.height = x, y, width, height
    elem.state = false
    elem.onClick = onClick or self.doNothing
    elem.onRelease = onRelease or self.doNothing
    elem.onDraw = onDraw or self.doNothing
    elem.onUpdate = onUpdate or self.doNothing

    setmetatable(elem, elSorter)

    table.insert(self.elements, elem)
    table.sort(self.elements)

    return elem
end

--needed to use gestures
function UI:newGestureElement()
    local gest = {}  --gesture UI element

    gest.x, gest.y = 0, 0
    gest.width, gest.height = love.window.getMode()
    gest.state = false
    gest.time = 0
    gest.onClick = function(gest)
        local x, y
        if gest.touchID == "mouse" then
            x, y = love.mouse.getPosition()
        else
            x, y = love.touch.getPosition(gest.touchID)
        end
        setStart(x, y)
    end
    gest.onDraw = function(gest)
        --do nothing
    end
    gest.onUpdate = function(gest)
        if gest.state then
            local x, y
            if gest.touchID == "mouse" then
                x, y = love.mouse.getPosition()
            else
                x, y = love.touch.getPosition(gest.touchID)
            end
            loadMovement(x, y, true)
        end
    end
    gest.onRelease = function(gest)
        local x, y
        if gest.touchID == "mouse" then
            x, y = love.mouse.getPosition()
        else
            x, y = love.touch.getPosition(gest.touchID)
        end
        loadMovement(x, y, false)
    end
    setmetatable(gest, elSorter)

    table.insert(self.elements, gest)
    table.sort(self.elements)
end

------------CORE CODE----------------------------------------------

function UI:init()
    qholo = love.graphics.newImage("UI/textures/hologram.png")
    self.x, self.y = 0, 0
    holoshader = love.graphics.newShader("shaders/UIholo.frag")
end

function UI:pressed(id, x, y)
    for j, el in ipairs(self.elements) do
		if el.touchID == nil and x > el.x and x < el.x + el.width and y > el.y and y < el.y + el.height then
			el.state = true
			el.touchID = id
			el:onClick()
			el.time = 0
			break
		end
	end
end

function UI:released(id)
    for j, el in ipairs(UI.elements) do
		if el.touchID == id then
			el.state = false
			el:onRelease()
			el.touchID = nil
			break
		end
	end
end

function UI:update(dt, px, py)
    local t = love.touch:getTouches()
    local touches = {}

    self.dx = self.x + screenWidth/2 - px
    self.dy = self.y + screenHeight/2 - py

    self.x = self.x - self.dx*7*dt
    self.y = self.y - self.dy*7*dt

    for i, el in pairs(self.elements) do
        if el.time ~= nil then el.time = el.time + dt end
        el:onUpdate(dt)
    end
end

function UI:draw()
    love.graphics.translate(self.dx/8, self.dy/8)
    for i, v in pairs(self.elements) do
        v:onDraw()
    end

    local r, g, b = math.random(0.00,0.00), math.random(0.00,0.00), math.random(0.60,0.80)--ImageData:getPixel( 800, 50 )

    holoshader:send("time", love.timer.getTime())
    holoshader:send("tarColor", {r, g, b, 0.4})  --color of hologram

    love.graphics.setShader(holoshader)
    love.graphics.draw(qholo, 800, 50)
    love.graphics.setShader()
end
