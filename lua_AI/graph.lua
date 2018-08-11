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

	self.nearestP = function(fixture, x1, y1, x2, y2, fraction)
		obj = fixture:getUserData()
		if obj.name == 'brick' then
			self.fraq = fraction
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
		av.q = av.q - 1
		setmetatable(av[1], vertexSorter)
    	--table.sort(av)
	end

	local ind = av[1].vertex --current vertex

    --self[ind].visited = true
	--self.visitCount = self.visitCount + 1

	if (self.prev ~= nil) then  --save path
		self[ind].visitedVertexes = self[self.prev].visitedVertexes
		self[ind].visitedVertexes.q = self[ind].visitedVertexes.q + 1
		self[ind].visitedVertexes[self[ind].visitedVertexes.q] = self.prev
	end
	self.prev = ind

    for i = 1,self[ind].nb.q do
		local tmplen = self[ind].dist + self[ind].nb[i].length
        --if self[self[ind].nb[i].vertex].visited == false then
		if ind ~= i and tmplen < self[self[ind].nb[i].vertex].dist then  --if new dist is less than previous
            self[self[ind].nb[i].vertex].dist = tmplen

            av.q = av.q + 1 --add to queue
			av[av.q] = {}
            av[av.q].vertex = self[ind].nb[i].vertex
			av[av.q].dist = self[self[ind].nb[i].vertex].dist
			setmetatable(av[av.q], vertexSorter)
        end

    end

    table.sort(av)
	--self[av[1].vertex].visitedVertexes = self[ind].visitedVertexes
	--self[av[1].vertex].visitedVertexes.q = self[av[1].vertex].visitedVertexes.q + 1
	--self[av[1].vertex].visitedVertexes[self[av[1].vertex].visitedVertexes.q] = ind

	--if self.visitCount == self.vertexQuantity then return 0 end
	if av.q == 0 then return 0 end
	self:dijkstra()
end

function Graph:getPath(start,finish)
	self.visitCount = 0
    av = { q = 1 } -- avaliable vertexes
    for i = 1, self.vertexQuantity do
        self[i].dist = plen(100)
        --self[i].visited = false
    end
    self[start].dist = 0
    self[start].visitedVertexes = {i = 1, q = 1, [1] = start}
	av[1] = {}
	av[1].vertex = start
	av[1].dist = 0
    self:dijkstra()
    return self[finish].visitedVertexes
end

function Graph:whereToGo(enemy1)
	local x1, y1 = fcoords(enemy1.body:getPosition())
	local x2, y2 = fcoords(player1.body:getPosition())
	local start, finish = 1, 1
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
		self.fraq = -1
		world:rayCast(x1, y1, self[i].x, self[i].y, self.nearestP)
		if self.fraq == -1 then
			if self.minStart.ind == nil or self.minStart.dist > getDist(x1, y1, self[i].x, self[i].y) then
				self.minStart.dist = getDist(x1, y1, self[i].x, self[i].y)
				self.minStart.ind = i
			end
		end

		self.fraq = -1
		world:rayCast(x2, y2, self[i].x, self[i].y, self.nearestP)
		if self.fraq == -1 then
			if self.minFinish.ind == nil or self.minFinish.dist > getDist(x2, y2, self[i].x, self[i].y) then
				self.minFinish.dist = getDist(x2, y2, self[i].x, self[i].y)
				self.minFinish.ind = i
			end
		end

	end

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
