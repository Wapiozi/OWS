Graph = {}
Graph.__index = Graph

vertexSorter = {}

function vertexSorter:__lt(next)
	if self.dist < next.dist then return true end
	return false
end

function Graph:new()
	self = setmetatable({}, self)
    self.vertexQuantity = 0
    return self
end

function Graph:addNB(i, nb)
    --[[
        nb = {
            q = quantity of connected vertexes
            [1].vertex = j
            [1].distance = getDist(self[i].x, self[i].y, self[j].x, self[j].y)
            [2]
            ...
            [q]
        }

    ]]
    self[i].nb = nb
    for j = 1, nb.q do
		self[j].nb[self[j].nb.q].vertex = i
        self[j].nb.q = self[j].nb.q + 1
        self[j].nb[self[j].nb.q].length = getDist(self[i].x, self[i].y, self[j].x, self[j].y)
    end
end

function Graph:addVertex(x, y, nb)
    self.vertexQuantity = self.vertexQuantity  + 1
    i = self.vertexQuantity
    self[i].x = x
    self[i].y = y
    if nb ~= nil then self:addNB(i,nb) end
end

function Graph:dijikstra(ind)
    if av.q ~= 0 then
		av[1].dist = plen(100)
		setmetatable(av[1], vertexSorter)
    	table.sort(av)
	end

    self[ind].visited = true
	self.visitCount = self.visitCount + 1

	if (self.prev ~= nil) then self[ind].visitedVertexes = self[prev].visitedVertexes end
	self[ind].visitedVertexes.q = self[ind].visitedVertexes.q + 1
	self[ind].visitedVertexes[q] = self.prev
	self.prev = ind

    for i = 1,self[ind].nb.q do
        if self[self[ind].nb[i]].visited == false then
            self[self[ind].nb[i]].dist = self[ind].dist + self[ind].nb[i].length
            av.q = av.q + 1
            av[av.q].vertex = self[ind].nb[i].vertex
			av[av.q].dist = self[self[ind].nb[i]].dist
			setmetatable(av[av.q], vertexSorter)
        end
    end

    table.sort(av)
	--self[av[1].vertex].visitedVertexes = self[ind].visitedVertexes
	--self[av[1].vertex].visitedVertexes.q = self[av[1].vertex].visitedVertexes.q + 1
	--self[av[1].vertex].visitedVertexes[self[av[1].vertex].visitedVertexes.q] = ind

	if self.visitCount == self.vertexQuantity then return 0 end
	self:dijikstra(av[1].vertex)
end

function Graph:getPath(start,finish)
	self.visitCount = 0
    av = { q = 0 } -- avaliable vertexes
    for i = 1, self.vertexQuantity do
        self[i].dist = plen(100)
        self[i].visited = false
    end
    self[start].dist = 0
    self[start].visitedVertexes{q = 1, [1] = start}
    self:dijikstra(start)
    return self[finish].visitedVertexes
end

function Graph:whereToGo(enemy1)
	local x1, y1 = enemy1.body:getPosition()
	local x2, y2 = player1.body:getPosition()
	local start, finish = 1, 1
	for i = 1,self.vertexQuantity do
		if ( math.abs(self[i].x - x1) + math.abs(self[i].y - y1) ) < ( math.abs(self[start].x - x1) + math.abs(self[start].y - y1) ) then
			start = i
		end
		if ( math.abs(self[i].x - x2) + math.abs(self[i].y - y2) ) < ( math.abs(self[finish].x - x2) + math.abs(self[finish].y - y2) ) then
			finish = i
		end
	end
	return self:getPath(start,finish)
end
