spawnPoints = {
    [1] = {x = 0.2, y = 0.8},
    [2] = {x = 1, y = 0.9}

}

function loadMap(transitionInd)
    player1:setPosition(spawnPoints[transitionInd].x, spawnPoints[transitionInd].y)

	camera:setBounds(0, 0, screenWidth * 2  , screenHeight)
	camera:setPosition(0,screenWidth/2)

	lights:add(0.6, 0.6, 0.06, true, nil, 1, 0.6, 0.6)
	lights:add(1, 0.4, 0.1, true, nil, 0.6, 1, 0.6)
	lights:add(1.4, 0.6, 0.06, true, nil, 0.6, 0.6, 1)

	walls:add(Brick:new(16/9, 0-0.05, 16/9*2, 0.1, "floor"))
	walls:add(Brick:new(16/9*2+0.05, 0.5, 0.1, 1, "wall"))
	walls:add(Brick:new(16/9, 1+0.05, 16/9*2, 0.1, "floor"))
	walls:add(Brick:new(0-0.05, 0.5, 0.1, 1, "wall"))

	traps:add(Traps:new(1.4, 0.995, TrapTypeSpikes))

	envir:add(EnvObject:new(1, 0.5, ChestImg, true, 1000, 0.3))
	envir:add(EnvObject:new(2, 0.5, ChestImg, true, 1000, 0.3))

	envirsh:add(Torch:new(0.5, 0.1))
	envirsh:add(Transition:new(1, 0.9, "maps/BigRoom", 1))

	enemies:add(Enemy:new(NpcTypeChallenge, 0.9, 0.8))
	enemies:add(Enemy:new(EnemyTypeRat, 1.5, 0.8))
	enemies:add(Enemy:new(EnemyTypeMadwizard, 1, 0.8))

	items:add(Item:new(0.5,0.8,WandObj))
	items:add(Item:new(0.6,0.8,WandObj))
	items:add(Item:new(0.7,0.8,WandObj))
	items:add(Item:new(0.8,0.8,ClothObj))
	items:add(Item:new(0.9,0.8,ClothObj))
	items:add(Item:new(0.2,0.8,ClothObj))

    --graph1:addVertex(0.5, 0.1, {q = 0})
    --graph1:addVertex(0.7, 0.5, {q = 1,[1] = {vertex = 1}})
    --graph1:addVertex(1.8, 0.5, {q = 1,[1] = {vertex = 2}})
    --graph1:addVertex(2, 0.1, {q = 1,[1] = {vertex = 3}})
    --graph1:addVertex(1.25, 0.3, {q = 4,[1] = {vertex = 1},[2] = {vertex = 2},[3] = {vertex = 3},[4] = {vertex = 4}})
    --graph1:addVertex(1.25, 0.2, {q = 1,[1] = {vertex = 5}})

    backgr = love.graphics.newQuad(0, 0, plen(16/9*2), plen(1), BrickImg:getDimensions())
end
