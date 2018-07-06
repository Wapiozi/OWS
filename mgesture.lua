prevx, prevy = love.mouse.getPosition()
prevMov = false
prevDirect = null

local function getDirection(px, py, nx, ny)
	local xx = nx - px
	local yy = ny - py
	
	if yy == 0 then yy = 1 end
	
	return xx/yy
end

function loadMovement()
	local x, y = love.mouse.getPosition()

	if not love.mouse.isDown(1) then 
		love.graphics.print(tostring(prevDirect), 100, 100)
		prevMov = false 
		return 
	end

	if not prevMov then
		prevMov = true
		prevx, prevy = love.mouse.getPosition()
	else 
		local direct = getDirection(prevx, prevy, x, y)
		
		
		prevx, prevy = love.mouse.getPosition()
		prevDirect = direct
	end
end
