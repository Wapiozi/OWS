spawnPoints = {
    [1] = {x = 1, y = 2.9},
    [2] = {x = 2, y = 2.9}
}

function loadMap(transitionInd)
    player1:setPosition(spawnPoints[transitionInd].x, spawnPoints[transitionInd].y)

	camera:setBounds(0, 0, screenWidth * 4  , screenHeight*3)
	camera:setPosition(0,screenWidth/2)

	lights:add(1, 1, 0.2, true, nil, 1, 0, 0)
	lights:add(2, 1, 0.2, true, nil, 0, 1, 0)
	lights:add(3, 1, 0.2, true, nil, 0, 0, 1)
    lights:add(1, 2, 0.2, true, nil, 1, 1, 0)
	lights:add(2, 2, 0.2, true, nil, 1, 0, 1)
	lights:add(3, 2, 0.2, true, nil, 0, 1, 1)
    lights:add(1.8, 2.8, 0.2, true, nil, 0, 1, 0)

	walls:add(Brick:new(16/9*2, 0-0.05, 16/9*4, 0.1, "floor", 0, LaserImg))
	walls:add(Brick:new(16/9*4+0.05, 1.5, 0.1, 3, "wall"))
	walls:add(Brick:new(16/9*2, 3+0.05, 16/9*4, 0.1, "floor", 0, LaserImg))
	walls:add(Brick:new(0-0.05, 1.5, 0.1, 3, "wall"))
    walls:add(Brick:new(2, 2.6-0.005, 2, 0.01, "floor", 0, LaserImg))
    walls:add(Brick:new(3, 2.8-0.005, 2, 0.01, "floor", 0, LaserImg))

    --enemies:add(Enemy:new(NpcTypeChallenge, 0.9, 0.8))
	enemies:add(Enemy:new(EnemyTypeBat, 1, 2))
	--enemies:add(Enemy:new(EnemyTypeMadwizard, 1, 0.8))

    envirsh:add(Transition:new(1, 2.9, "maps/start", 1))
    envirsh:add(Transition:new(2, 2.9, "maps/outMap", 2))

    backgr = love.graphics.newQuad(0, 0, plen(16/9*4), plen(3), BrickImg:getDimensions())
end
