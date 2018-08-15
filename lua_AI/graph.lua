Graph = {}
Graph.__index = Graph

vertexSorter = {}

function vertexSorter:__lt(next)
	if self.dist < next.dist then return true end
	return false
end

function nearestP(y)
	return function()
	seenVertexes[y] = {seen = false} end
end

function Graph:new()
	self = setmetatable({}, self)
    self.vertexQuantity = 0

	self.findNearestP = function(fixture, x1, y1, x2, y2, fraction)
		obj = fixture:getUserData()
		if obj.name == 'brick' then
			seenPath()
			--enemy1.seenVertexes[y] = {seen = false}
		end
		return 1
	end

    return self
end

function Graph:deleteNB(i,j)

end

function Graph:addNB(i, nb, single)
    --[[
        nb = {
            q = quantity of connected vertexes
            [1].vertex = j
            [1].length = getDist(self[i].x, self[i].y, self[j].x, self[j].y)
            [2]
            ...
            [q]
        }

    ]]
	self[i].nb = nb
    for j = 1, nb.q do
		local vec = self[i].nb[j].vertex
		if vec <= self.vertexQuantity then
        	self[vec].nb.q = self[vec].nb.q + 1
			self[vec].nb[self[vec].nb.q] = {}
			self[vec].nb[self[vec].nb.q].vertex = i
			self[i].nb[j].length = getDist(self[i].x, self[i].y, self[vec].x, self[vec].y)
        	self[vec].nb[self[vec].nb.q].length = self[i].nb[j].length
		end
		--[[
		if math.abs(self[i].x - self[vec].x) >= math.abs(self[i].y - self[vec].y) then
			self[i].nb[j].state = 'move'
			self[vec].nb[self[vec].nb.q].state = 'move'
		else
			self[i].nb[j].state = 'jump'
			self[vec].nb[self[vec].nb.q].state = 'jump'
		end
		]]
    end
end

function Graph:addVertex(x1, y1, nb)
    self.vertexQuantity = self.vertexQuantity  + 1
    local i = self.vertexQuantity
    self[i] = {x = x1, y = y1, name = "graph", dist = 0} --name needed for level editor
    if nb ~= nil then self:addNB(i,nb) end
end

function Graph:equalTables(ind1,ind2)
	self[ind2].visitedVertexes = {i = 1, q = self[ind1].visitedVertexes.q }
	for i = 1, self[ind2].visitedVertexes.q do
		self[ind2].visitedVertexes[i] = self[ind1].visitedVertexes[i]
	end
end

function Graph:dijkstra()
	av = self.pq:take()
    if av == nil then return 0 end
	ind = av.index
    for i = 1, self[ind].nb.q do
		local tmplen = self[ind].dist + self[ind].nb[i].length

		if tmplen < self[self[ind].nb[i].vertex].dist then  --if new dist is less than previous
            self[self[ind].nb[i].vertex].dist = tmplen

			local ind2 = self[ind].nb[i].vertex
            self:equalTables(ind,ind2)
            self[ind2].visitedVertexes.q = self[ind2].visitedVertexes.q + 1
            self[ind2].visitedVertexes[self[ind2].visitedVertexes.q] = ind2

			av1 = {}
            av1.index = self[ind].nb[i].vertex
			av1.dist = self[self[ind].nb[i].vertex].dist
			self.pq:add(av1)
        end
    end

	--[[
	for i = 1, av.q do
		print(av[1].vertex, av[1].dist)
	end
	print("---")
	--if av.q == 0 then return 0 end
	]]
	self:dijkstra()
end

function Graph:getPath(start,finish)
	self.visitCount = 0
    --av = { q = 1 } -- avaliable vertexes
    for i = 1, self.vertexQuantity do
        self[i].dist = plen(100)
        --self[i].visited = false
    end
    self[start].dist = 0
    self[start].visitedVertexes = {i = 1, q = 1, [1] = start}
	--[[av[1] = {}
	av[1].vertex = start
	av[1].prevVertex = 0
	av[1].dist = 0
	]]
	av = {dist = 0, index = start}
	self.pq = PriorityQ:new(av)
    self:dijkstra()
    return self[finish].visitedVertexes
end

function Graph:enemyVertSeen(enemy1)
	local x1, y1 = enemy1.body:getPosition()
	seenVertexes = {}
	for i=1, self.vertexQuantity do
		seenVertexes[i] = {}
		seenPath =nearestP(i)
		local x2, y2 = pcoords(self[i].x, self[i].y)
		world:rayCast(x1, y1, x2, y2, self.findNearestP)
		seenVertexes[i].dist = getDist(x1, y1, x2, y2)
	end
	enemy1.seenVertexes = seenVertexes
end

function Graph:whereToGo(enemy1)
	local x1, y1 = fcoords(enemy1.body:getPosition())
	local x2, y2 = fcoords(player1.body:getPosition())
	--[[
	for i = 1,self.vertexQuantity do
		if ( math.abs(self[i].x - x1) + math.abs(self[i].y - y1) ) < ( math.abs(self[start].x - x1) + math.abs(self[start].y - y1) ) then
			start = i
		end
		if ( math.abs(self[i].x - x2) + math.abs(self[i].y - y2) ) < ( math.abs(self[finish].x - x2) + math.abs(self[finish].y - y2) ) then
			finish = i
		end
	end
	]]
	self.minStart = {}
	self.minFinish = {}
	for i= 1, self.vertexQuantity do
		--self.nearestP = nearestP(i)
		--world:rayCast(x1, y1, self[i].x, self[i].y, self.nearestP)
		if enemy1.seenVertexes[i].seen == nil then
			if self.minStart.ind == nil or self.minStart.dist > enemy1.seenVertexes[i].dist then
				self.minStart.dist = enemy1.seenVertexes[i].dist
				self.minStart.ind = i
			end
		end

		--self.nearestP = nearestP(i)
		--world:rayCast(x2, y2, self[i].x, self[i].y, self.nearestP)
		if player1.seenVertexes[i].seen == nil then
			if self.minFinish.ind == nil or self.minFinish.dist > player1.seenVertexes[i].dist then
				self.minFinish.dist = player1.seenVertexes[i].dist
				self.minFinish.ind = i
			end
		end

	end

	--player1.bestVertex1, player1.bestVertex2 = self.minStart.ind,self.minFinish.ind
	return self:getPath(self.minStart.ind,self.minFinish.ind)
end

function Graph:draw()
	for i = 1, self.vertexQuantity do
		local x, y = pcoords(self[i].x, self[i].y)
		love.graphics.print(tostring(i), x - plen(0.008), y - plen(0.04))
		love.graphics.circle("line", x, y, 10)
		if self[i].nb ~= nil then

			for j = 1, self[i].nb.q do
				local xx, yy = pcoords(self[self[i].nb[j].vertex].x, self[self[i].nb[j].vertex].y)
				love.graphics.line(x, y, xx, yy)
				local Mx,My = (x + xx) /2, (y + yy) /2
				--love.graphics.print(string.format("%.2f",tostring(self[i].nb[j].length)), Mx - plen(0.008), My - plen(0.04))
			end
		end
	end
end

function Graph:destroy()
	self = {}
end

PriorityQ = {}
PriorityQ.__index = PriorityQ

function PriorityQ:new(av)
	self = setmetatable({}, self)
	self.list = {next = nil, value = {dist = av.dist, index = av.index}}
	return self
end

function PriorityQ:add(av)
	local tmp = self.list
	if tmp == nil then
		tmp = {next = nil, value = {dist = av.dist, index = av.index}}
		self.list = tmp
	elseif tmp.next == nil then
		if av.dist < tmp.value.dist then
			self.list = {next = tmp, value = {dist = av.dist, index = av.index}}
		else
			self.list.next = {next = nil, value = {dist = av.dist, index = av.index}}
		end
	else
	    while tmp.value.dist ~= nil and tmp.next ~= nil and tmp.next.value.dist ~= nil and tmp.next.value.dist < av.dist do
	        tmp = tmp.next
	    end
		if tmp.next ~= nil then
			local tmpNext = tmp.next.next
		else
			local tmpNext = nil
		end
		tmp.next = {next = tmpNext, value = {dist = av.dist, index = av.index}}
	end
end

function PriorityQ:take()
	local tmp = self.list
	if tmp == nil then
		return nil
	end
	self.list = self.list.next
	return tmp.value
end
