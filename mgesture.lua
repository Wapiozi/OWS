prevx, prevy = love.mouse.getPosition()
x, y = love.mouse.getPosition()
prevMov = false
prevDirect = null


local function getDirection(px, py, nx, ny)
	love.graphics.print(tostring(px) .. "  " .. tostring(py) .. "  " .. tostring(nx) .. "  " .. tostring(ny), 200, 100)
	local xx = nx - px
	local yy = ny - py
	
	if yy == 0 then yy = 1 end
	
	return xx/yy
end

function loadMovement()
	

	if not love.mouse.isDown(1) then 
		local direct = getDirection(prevx, prevy, x, y)
		prevDirect = direct
		love.graphics.print(tostring(prevDirect), 100, 100)
		prevMov = false 
		return 
	end

	if not prevMov then
		prevMov = true
		prevx, prevy = love.mouse.getPosition()
	else 
		
		x, y = love.mouse.getPosition()
		
		
	end
end
