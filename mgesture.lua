math = require("math")

prevx, prevy = love.mouse.getPosition()
x, y = love.mouse.getPosition()
prevMov = false
prevDirect = null
toler = 20
angToler = 22.5

--[[
Angles:
1 - 0
2 - 45
3 - 90
4 - 135
5 - 180
6 - 225
7 - 270
8 - 315

Can't be more than 2 equal angles in a row

]]--

gr = love.graphics

local function getDirection(px, py, nx, ny)
	
	gr.line(px, py, nx, ny)

	local xx = nx - px
	local yy = ny - py
	local mv = 0
	local res = 0
	
	if (xx == 0) then xx = 0.00000001 end
	if (yy == 0) then yy = 0.00000001 end
	
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
	
	return res
end

function loadMovement()
	gest = {}
	lastIn = 1
	
	if love.mouse.isDown(1) then
		x, y = love.mouse.getPosition()
		if (math.abs(x-prevx) > toler) or (math.abs(y-prevy) > toler) then
			local direct = getDirection(prevx, prevy, x, y)
			prevx = x
			prevy = y
			
			love.graphics.print(tostring(direct), 100, 200)
			
			local dir = 0
			
			if (direct > (360-angToler)) or (direct < angToler) then
				dir = 1
			elseif (direct > (45-angToler)) and (direct < (45+angToler)) then
				dir = 2
			elseif (direct > (90-angToler)) and (direct < (90+angToler)) then
				dir = 3
			elseif (direct > (135-angToler)) and (direct < (135+angToler)) then
				dir = 4
			elseif (direct > (180-angToler)) and (direct < (180+angToler)) then
				dir = 5
			elseif (direct > (225-angToler)) and (direct < (225+angToler)) then
				dir = 6
			elseif (direct > (270-angToler)) and (direct < (270+angToler)) then
				dir = 7
			elseif (direct > (315-angToler)) and (direct < (315+angToler)) then
				dir = 8
			end
			
			if prevDirect == null then
				prevDirect = dir
				gest[1] = dir
			elseif prevDirect == dir then
				--do nothing
			else
				lastIn = lastIn + 1
				gest[lastIn] = dir
			
			end
			love.graphics.print(tostring(dir), 100, 100)
		end
	else 
		prevx, prevy = love.mouse.getPosition()
	end
end
