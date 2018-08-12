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
        self[vec].nb.q = self[vec].nb.q + 1
		self[vec].nb[self[vec].nb.q] = {}
		self[vec].nb[self[vec].nb.q].vertex = i
		self[i].nb[j].length = getDist(self[i].x, self[i].y, self[j].x, self[j].y)
        self[vec].nb[self[vec].nb.q].length = self[i].nb[j].length
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
    self[i] = {x = x1, y = y1, name = "graph"} --name needed for level editor
    if nb ~= nil then self:addNB(i,nb) end
end

function Graph:dijkstra()
    if av.q ~= 0 then  --delete current vertex from av queue

		av[1].dist = plen(100)
		--av.q = av.q - 1
		setmetatable(av[1], vertexSorter)
    	--table.sort(av)
	end

	local ind = av[1].vertex --current vertex

    --self[ind].visited = true
	--self.visitCount = self.visitCount + 1

    for i = 1, self[ind].nb.q do
		local tmplen = self[ind].dist + self[ind].nb[i].length
        --if self[self[ind].nb[i].vertex].visited == false then
		if ind ~= i and tmplen < self[self[ind].nb[i].vertex].dist then  --if new dist is less than previous
            self[self[ind].nb[i].vertex].dist = tmplen

			local ind2 = self[ind].nb[i].vertex
            self[ind2].visitedVertexes = self[ind].visitedVertexes
            self[ind2].visitedVertexes.q = self[ind2].visitedVertexes.q + 1
            self[ind2].visitedVertexes[self[ind2].visitedVertexes.q] = ind2

            av.q = av.q + 1 --add to queue
			av[av.q] = {}
            av[av.q].vertex = self[ind].nb[i].vertex
			av[av.q].dist = self[self[ind].nb[i].vertex].dist
			setmetatable(av[av.q], vertexSorter)
        end
    end

    table.sort(av)
	av.q = av.q - 1
	--self[av[1].vertex].visitedVertexes = self[ind].visitedVertexes
	--self[av[1].vertex].visitedVertexes.q = self[av[1].vertex].visitedVertexes.q + 1
	--self[av[1].vertex].visitedVertexes[self[av[1].vertex].visitedVertexes.q] = ind

	--if self.visitCount == self.vertexQuantity then return 0 end
	for i = 1, av.q do
		print(av[1].vertex, av[1].dist)
	end
	print("---")
	if av.q == 0 then return 0 end
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
	self.pq = PriortyQ:new(av)
    self:dijkstra()
	print(start, finish)
	self[finish].visitedVertexes[self[finish].visitedVertexes.q] = finish

	print("dist = ", self[finish].dist)
	for i = 1, self[finish].visitedVertexes.q do
		print(self[finish].visitedVertexes[i])
	end
	print("--------------------")
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
	for i = 1, self.vertexQuantity do
		io.write(i, " to ")
		for j = 1, self[i].nb.q do
			io.write(self[i].nb[j].vertex, " ")
		end
		io.write("\n")
	end
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
		love.graphics.circle("line", x, y, 10)
		if self[i].nb ~= nil then

			for j = 1, self[i].nb.q do
				local xx, yy = pcoords(self[self[i].nb[j].vertex].x, self[self[i].nb[j].vertex].y)
				love.graphics.line(x, y, xx, yy)
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
	if tmp.value.dist ~= nil and tmp.value.dist > av.dist then
		self.list = {next = tmp, value = {dist = av.dist, index = av.index}}
	else
	    while tmp.value.dist ~= nil and tmp.next.value.dist ~= nil and tmp.next.value.dist < av.dist do
	        tmp = tmp.next
	    end
		local tmpNext = tmp.next
		tmp.next = {next = tmpNext, value = {dist = av.dist, index = av.index}}
	end
end

function PriorityQ:take()
	local tmp = self.list
	self.list = tmp.next
	return tmp.value
end
