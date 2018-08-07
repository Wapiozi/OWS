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
            [1].vertex = self[j]
            [1].distance = getDist(self[i].x, self[i].y, self[j].x, self[j].y)
            [2]
            ...
            [q]
        }

    ]]
    self[i].nb = nb
    for j = 1, nb.q do
        self[j].nb.q = self[j].nb.q + 1
        self[j].nb[self[j].nb.q].vertex = self[i]
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

function Graph:BFS(ind)
    av[1] = plen(100)
	setmetatable(av[1], vertexSorter)
    table.sort(av)
    if (self[ind].visited == false) then
        self[ind].visited = true
        for i = 1,self[ind].nb.q do
            if self[ind].nb[i].visited == false then
                self[ind].nb[i].dist = math.min(self[ind].nb[i].dist, self[ind].nb[i].length)
                av.q = av.q + 1
                av[av.q] = self[ind].nb[i]
				setmetatable(av[av.q], vertexSorter)
            end
        end
        table.sort(av)
        self:BFS(av[1])
    end
end

function Graph:getPath(start,finish)
    av = { q = 0 } -- avaliable vertexes
    for i = 1, self.vertexQuantity do
        self[i].dist = plen(100)
        self[i].visited = false
    end
    self[start].dist = 0
    self[start].visitedVertexes{q = 1, [1] = start}
    self:BFS(start)
    return self[finish].visitedVertexes
end
