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

function isPinTriang(triangInd, point) --is point in triangle
	local p1, p2, p3 = triangles[triangInd].light, triangles[triangInd].p1, triangles[triangInd].p2

	if ((p1.x - point.x)*(p2.y-p1.y) - (p2.x-p1.x)*(p1.y-point.y)) >= 0 and
	  ((p2.x-point.x)*(p3.y-p2.y) - (p3.x-p2.x)*(p2.y-point.y)) >= 0 and
	  ((p3.x-point.x)*(p1.y-p3.y) - (p1.x-p3.x)*(p3.y-point.y)) >= 0 then
		return true
	end
	return false
end

function rayIsBetw(triangInd, raydeg)
	local ang1, ang2 = triangles[triangInd].p1deg, triangles[triangInd].p2deg

	if raydeg == ang1 then return true end
	if raydeg == ang2 then return false end

	if ang2 - ang1 > 0 then
		if raydeg > ang1 and raydeg < ang2 then return true end
		return false
	else
		if (raydeg >= ang1 and raydeg <= 360) or (raydeg <= ang2 and raydeg >= 0) then return true end
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

	--if (ua >= 1 or ua <= 0) then return nil end

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
	if next == nil then
		return true
	end

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

function overlap(tri1, tri2)
	if triangles[tri1] ~= nil and triangles[tri2] ~= nil and triangles[tri1].p1deg > triangles[tri2].p1deg then --tri1 p1deg must be less than tri2 p1deg
		tri1, tri2 = tri2, tri1
	end
	while triangles[tri1] ~= nil and triangles[tri2] ~= nil and rayIsBetw(tri1, triangles[tri2].p1deg) do
		if rayIsBetw(tri1, triangles[tri2].p2deg) then --if tri2 is between tri1 rays
			if isPinTriang(tri1, triangles[tri2].p1) and isPinTriang(tri1, triangles[tri2].p2) then  --if tri2 is in tri1
				local tmp1 = lineCrossing(triangles[tri1].p1, triangles[tri1].p2, triangles[tri2].light, triangles[tri2].p1)
				local tmp2 = lineCrossing(triangles[tri1].p1, triangles[tri1].p2, triangles[tri2].light, triangles[tri2].p2)

				triangCnt = triangCnt + 1  --add new triangle
				triangles[triangCnt] = {
					light = triangles[tri1].light,
					p1 = tmp2,
					p2 = triangles[tri1].p2,
					p1deg = getDirection(triangles[tri1].light, tmp2),
					p2deg = getDirection(triangles[tri1].light, triangles[tri1].p2)
				}
				setmetatable(triangles[triangCnt], triangSorter)

				triangles[tri1].p2 = tmp1
				triangles[tri1].p2deg = getDirection(triangles[tri1].light, tmp1)

				overlap(tri2, tri2+1)
				overlap(triangCnt, tri2+1)
			else --if tri2 is out of tri1
				triangles[tri2].light.bright = 0
				triangles[tri2].light.lightInd = 50
			end
		else
			if isPinTriang(tri1, triangles[tri2].p1) then --if tri2.p1 is in tri1
				local tmp = lineCrossing(triangles[tri1].p1, triangles[tri1].p2, triangles[tri2].light, triangles[tri2].p1)  --tmp point
				triangles[tri1].p2 = tmp
				triangles[tri1].p2deg = getDirection(triangles[tri1].light, tmp)
			else --if tri2.p1 is out of tri1
				local tmp = lineCrossing(triangles[tri2].p1, triangles[tri2].p2, triangles[tri1].light, triangles[tri1].p2)  --tmp point
				triangles[tri2].p1 = tmp
				triangles[tri2].p1deg = getDirection(triangles[tri2].light, tmp)
			end
		end
		tri2 = tri2 + 1
	end
	if triangles[tri2+1] ~= nil and triangles[tri2+2] ~= nil then
		--overlap(tri2+1, tri2+2)
	end
end

function calcTri(stI, stJ, maxI, maxJ)

	table.sort(triangles)

	i, j = stI, stJ+1

	while i < maxI do
		if triangles[j] ~= nil and triangles[i] ~= nil and rayIsBetw(i, triangles[j].p1deg) then  --if triangleJ overlaps triangleI
			if rayIsBetw(i, triangles[j].p2deg) then --if triangleJ is fully between triangleI
				if isPinTriang(i, triangles[j].p1) and isPinTriang(i, triangles[j].p2) then --if triangleJ is in triangleI
					local tmp1 = lineCrossing(triangles[i].p1, triangles[i].p2, triangles[j].light, triangles[j].p1)
					local tmp2 = lineCrossing(triangles[i].p1, triangles[i].p2, triangles[j].light, triangles[j].p2)

					triangCnt = triangCnt + 1  --add new triangle
					triangles[triangCnt] = {
						light = triangles[i].light,
						p1 = tmp2,
						p2 = triangles[i].p2,
						p1deg = getDirection(triangles[i].light, tmp2),
						p2deg = getDirection(triangles[i].light, triangles[i].p2)
					}
					setmetatable(triangles[triangCnt], triangSorter)

					triangles[i].p2 = tmp1
					triangles[i].p2deg = getDirection(triangles[i].light, tmp1)

					i = j

					calcTri(i, i, i, i+5)
				else --if triangleJ is out of triangleI
					triangles[j].light.bright = 0
					triangles[j].light.lightInd = 50
					i = j
					--setmetatable(triangles[triangCnt], triangSorter)
				end
			else  --if not triangleJ is fully between triangleI
				if isPinTriang(i, triangles[j].p1) then --if triangleJ.p1 is in triangleI
					local tmp = lineCrossing(triangles[i].p1, triangles[i].p2, triangles[j].light, triangles[j].p1)  --tmp point
					triangles[i].p2 = tmp
					triangles[i].p2deg = getDirection(triangles[i].light, tmp)
					i = j
				else --if triangleJ.p1 is out of triangleI
					local tmp = lineCrossing(triangles[j].p1, triangles[j].p2, triangles[i].light, triangles[i].p2)  --tmp point
					triangles[j].p1 = tmp
					triangles[j].p1deg = getDirection(triangles[j].light, tmp)
					i = j
				end
			end
		else --if NOT triangleJ overlaps triangleI
			i = j
		end
		j = j + 1
		if j > maxJ then j = 1 end
	end
end

--calcTri(1, 1, triangCnt, triangCnt)
--calcTri(1, 1, triangCnt, triangCnt)

--overlap(1, 2)

table.sort(triangles)

local i, cur = 1, 1

for i = 2, triangCnt do --count triangle lightsources

	while triangles[i].light.lightInd < 400 and triangles[i].light.lightInd ~= cur do
		lights[cur][3] = i-1
		cur = cur + 1
	end
end
lights[cur][3] = triangCnt

triGl = {}

for i = 1, triangCnt do
	triGl[i] = {triangles[i].p1.x, triangles[i].p1.y, triangles[i].p2.x, triangles[i].p2.y}
end
--[[
for i = triangCnt+1, 200 do
	triGl[i] = {0, 0, 0, 0}
end]]--

pdegs = {}

for i = 1, triangCnt do
	pdegs[i] = {triangles[i].p1deg, triangles[i].p2deg}
end

--[[
for i = triangCnt+1, 200 do
	pdegs[i] = {0, 0}
end ]]--

love.thread.getChannel("triangles"):push(triGl)
love.thread.getChannel("triangCnt"):push(triangCnt)
love.thread.getChannel("lights"):push(lights)
love.thread.getChannel("pdegs"):push(pdegs)
