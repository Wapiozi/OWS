math = require("math")

prevx, prevy = love.mouse.getPosition()
x, y = love.mouse.getPosition()
prevMov = false
prevDirect = null

gr = love.graphics

local function getDirection(px, py, nx, ny)
	gr.print(tostring(px) .. "  " .. tostring(py) .. "  " .. tostring(nx) .. "  " .. tostring(ny), 100, 200)
	
	gr.line(px, py, nx, ny)
	gr.line(nx, py, nx, ny)
	gr.line(px, py, nx, py)
	
	local xx = nx - px
	local yy = ny - py
	local mv = 0
	local res = 0
	
	if (xx < 0) and (yy >= 0) then 
		xx = -xx
		res = math.atan(xx/yy)*57.2958 + 90 
	elseif (xx < 0) and (yy < 0) then 
		xx = -xx
		yy = -yy
		res = math.atan(yy/xx)*57.2958 + 180
	elseif (xx >= 0) and (yy < 0) then 
		yy = -yy
		res = math.atan(xx/yy)*57.2958 + 270 
	elseif (xx >= 0) and (yy >= 0) then 
		res = math.atan(yy/xx)*57.2958 
	end
	
	gr.line(400, 400, 400+xx, 400)
	gr.line(400+xx, 400, 400+xx, 400+yy)
	
	if xx == 0 then xx = 0.00001 end
	
	return res
end

function loadMovement()
	

	if not love.mouse.isDown(1) then 
		local direct = getDirection(prevx, prevy, x, y)
		love.graphics.print(tostring(direct), 100, 100)
		prevMov = false 
		return 
	end

	if not prevMov then
		prevMov = true
		prevx, prevy = love.mouse.getPosition()
	else 
		
		x, y = love.mouse.getPosition()
		local direct = getDirection(prevx, prevy, x, y)
		love.graphics.print(tostring(direct), 100, 100)
		
	end
end
