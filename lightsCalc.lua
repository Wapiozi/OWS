lines, lineCnt, lights = ...

triangles = {}
triangCnt = 0

rays = {}
rayCnt = 0

local function getDirection(p1, p2)

	local xx = p2.x - p1.x
	local yy = p2.y - p1.y
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

function trSort()
	for i = 1, triangCnt do 
		if math.abs(triangles[i].p2deg - triangles[i].p1deg) < 180 then  --when triangle not cross 0 deg
			if triangles[i].p2deg < triangles[i].p1deg then
				triangles[i].p1, triangles[i].p2 = triangles[i].p2, triangles[i].p1  --swap
				triangles[i].p1deg, triangles[i].p2deg = triangles[i].p2deg, triangles[i].p1deg
			end
		else                                                             --when triangle cross 0 deg
			if triangles[i].p2deg > triangles[i].p1deg then
				triangles[i].p1, triangles[i].p2 = triangles[i].p2, triangles[i].p1  --swap
				triangles[i].p1deg, triangles[i].p2deg = triangles[i].p2deg, triangles[i].p1deg
			end
		end
	end
end

--[[
function qsort(l, r)
	local i = l
	local j = r
	local x = rays[math.floor((l + r) / 2)].pdeg
	repeat 
		while rays[i].pdeg < x do i = i + 1 end
		while x < rays[j].pdeg do j = j - 1 end
		if not (i > j) then
			rays[i], rays[j] = rays[j], rays[i]
			i = i + 1
			j = j - 1
		end
		if l < j then qsort(l, j)
		if i < r then qsort(i, r)
	until (i > j) 
end]]--

function isPinTriang(triangInd, point) --is point in triangle
	local p1, p2, p3 = triangles[triangInd].light, triangles[triangInd].p1, triangles[triangInd].p2
	
	if ((p1.x - point.x)*(p2.y-p1.y) - (p2.x-p1.x)*(p1.y-point.y)) >= 0 and
	  ((p2.x-point.x)*(p3.y-p2.y) - (p3.x-p2.x)*(p2.y-point.y)) >= 0 and
	  ((p3.x-point.x)*(p1.y-p3.y) - (p1.x-p3.x)*(p3.y-point.y)) >= 0 then
		return true
	end
	return false
end

function rayIsBetw(triangInd, rayInd)
	local ang1, ang2 = triangles[triangInd].p1deg, triangles[triangInd].p2deg
	
	if ang2 - ang1 > 0 then
		if rays[rayInd].pdeg >= ang1 and rays[rayInd].pdeg <= ang2 then return true end
		return false
	else
		if rays[rayInd].pdeg >= ang1 or rays[rayInd].pdeg <= ang2 then return true end
		return false
	end
end

vector = {}

function vector:__add(next)
	return {x = self.x + next.x, y = self.y + next.y}
end

function vector:__sub(next)
	return {x = self.x - next.x, y = self.y - next.y}
end

function vector:__mul(next)
	return {x = self.x * next.x, y = self.y * next.y}
end

function vector:__eq(next)
	if self.x == next.x and self.y == next.y then return true end
	return false
end

function lineCrossing(p1, p2, p3, p4)  --line, ray
	local ua = ((p4.x-p3.x)*(p1.y-p3.y)-(p4.y-p3.y)*(p1.x-p3.x))/((p4.y-p3.y)*(p2.x-p1.x)-(p4.x-p3.x)*(p2.y-p1.y))
	local ub = ((p2.x-p1.x)*(p1.y-p3.y)-(p2.y-p1.y)*(p1.x-p3.x))/((p4.y-p3.y)*(p2.x-p1.x)-(p4.x-p3.x)*(p2.y-p1.y))
	
	if (ua > 1 or ua < 0) then return nil end
	
	local pua = {x = ua, y = ua}  --kostil
	
	setmetatable(p1, vector)
	setmetatable(p2, vector)
	setmetatable(pua, vector)
	
	local point = p1 + pua * (p2 - p1)
	return point
end

raySorter = {}

function raySorter:__lt(next)
	if self.light.lightInd ~= next.light.lightInd then 
		if self.light.lightInd < next.light.lightInd then return true end
		return false
	end
	
	
	if self.pdeg < next.pdeg then return true end
	return false

end

triangSorter = {}

function triangSorter:__lt(next)
	if self.light.lightInd ~= next.light.lightInd then 
		if self.light.lightInd < next.light.lightInd then return true end
		return false
	end
	
	if self.p1deg < next.p1deg then return true end
	return false
end

for j = 1, 50 do 
	if lights[j][4] ~= 0 then 
		for i = 1, lineCnt do
		
			--add triangle
			triangCnt = triangCnt + 1
			triangles[triangCnt] = {
				light = {x = lights[j][1], y = lights[j][2], bright = lights[j][4], lightInd = j},
				p1 = {x = lines[i].x, y = lines[i].y},
				p2 = {x = lines[i].xv, y = lines[i].yv},
				p1deg = getDirection({x = lights[j][1], y = lights[j][2]}, {x = lines[i].x, y = lines[i].y}),
				p2deg = getDirection({x = lights[j][1], y = lights[j][2]}, {x = lines[i].xv, y = lines[i].yv})
			}
			setmetatable(triangles[triangCnt], triangSorter)
			
			--add rays of triangle
			rayCnt = rayCnt + 1
			rays[rayCnt] = {
				light = triangles[triangCnt].light,
				point = triangles[triangCnt].p1,
				pdeg = triangles[triangCnt].p1deg,
				trianInd = triangCnt
			}
			setmetatable(rays[rayCnt], raySorter)
			
			rayCnt = rayCnt + 1
			rays[rayCnt] = {
				light = triangles[triangCnt].light,
				point = triangles[triangCnt].p2,
				pdeg = triangles[triangCnt].p2deg,
				trianInd = triangCnt
			}
			setmetatable(rays[rayCnt], raySorter)
		end
	end
end

trSort()
table.sort(rays)

local i, cur = 1, 1

for i = 2, rayCnt do --count where ends rays for lightsources
	if rays[i].light.lightInd ~= cur then
		lights[cur][3] = i-1
		cur = cur + 1
	end
end

local curtri = rays[1].trianInd

for i = 2, cur do
	if rayIsBetw(curtri, i) then 
		if isPinTriang(curtri, rays[i].point) then 
			local tmptri = triangles[cur]
			local point1 = lineCrossing(tmptri.p1, tmptri.p2, triangles[rays[i].trianInd].light, triangles[rays[i].trianInd].p1)
			local point2 = lineCrossing(tmptri.p1, tmptri.p2, triangles[rays[i].trianInd].light, triangles[rays[i].trianInd].p2)
			
			if (not point1) and (not point2) then
				triangles[curtri].light.bright = 0
			elseif point1 and point2 then 
				local tmppoint = triangles[curtri].p2
				triangles[curtri].p2 = point1
				
				triangCnt = triangCnt + 1
				triangles[triangCnt] = {
					light = triangles[curtri].light,
					p1 = point2,
					p2 = tmppoint,
					p1deg = getDirection(triangles[curtri].light, point2),
					p2deg = getDirection(triangles[curtri].light, tmppoint)
				}
				setmetatable(triangles[triangCnt], triangSorter)
			elseif point1 then 
				triangles[curtri].p2 = point1
			elseif point2 then 
				triangles[curtri].p1 = point2
			end
			
			curtri = rays[i].trianInd
		else
			local tmptri = triangles[rays[i].trianInd]
			local point1 = lineCrossing(tmptri.p1, tmptri.p2, triangles[curtri].light, triangles[curtri].p1)
			local point2 = lineCrossing(tmptri.p1, tmptri.p2, triangles[curtri].light, triangles[curtri].p2)
			
			if (not point1) and (not point2) then
				triangles[rays[i].trianInd].light.bright = 0
			elseif point1 and point2 then 
				local tmppoint = triangles[rays[i].trianInd].p2
				triangles[rays[i].trianInd].p2 = point1
				
				triangCnt = triangCnt + 1
				triangles[triangCnt] = {
					light = triangles[rays[i].trianInd].light,
					p1 = point2,
					p2 = tmppoint,
					p1deg = getDirection(triangles[rays[i].trianInd].light, point2),
					p2deg = getDirection(triangles[rays[i].trianInd].light, tmppoint)
				}
				setmetatable(triangles[triangCnt], triangSorter)
			elseif point1 then 
				triangles[rays[i].trianInd].p2 = point1
			elseif point2 then 
				triangles[rays[i].trianInd].p1 = point2
			end
		end
	else
		curtri = rays[i].trianInd
	end
end

table.sort(triangles)

local i, cur = 1, 1

for i = 2, triangCnt do --count triangle lightsources
	
	while triangles[i].light.lightInd ~= cur do
		lights[cur][3] = i-1
		cur = cur + 1
	end
end
lights[cur][3] = triangCnt

triGl = {}

for i = 1, triangCnt do 
	triGl[i] = {triangles[i].p1.x, triangles[i].p1.y, triangles[i].p2.x, triangles[i].p2.y}
end

love.thread.getChannel("triangles"):push(triGl)
love.thread.getChannel("triangCnt"):push(triangCnt)
love.thread.getChannel("lights"):push(lights)


