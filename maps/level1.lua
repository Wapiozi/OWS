spawnPoints = {
 {x = 0.15444444020589,y = 1.3580556233724},

}

function loadMap(transitionInd)
player1:setPosition(spawnPoints[transitionInd].x,spawnPoints[transitionInd].y)
camera:setBounds(0,0,screenWidth*4,screenHeight*3)
camera:setPosition(0,screenWidth/2)
walls:add(Brick:new(3.1822221544054,1.1677777608236,9,0.1,"floor",1.5700000524521,LaserImg))
walls:add(Brick:new(0.0044444455040826,1.2983333163791,2,0.1,"floor",1.5700000524521,LaserImg))
walls:add(Brick:new(0.63361112806532,1.7038889567057,5,0.5,"floor",0,LaserImg))
enemies:add(Enemy:new(EnemyTypeMadwizard,2.0822221544054,1.3538889567057))
enemies:add(Enemy:new(NpcTypeChallenge,2.5419443766276,1.3052777608236))
enemies:add(Enemy:new(EnemyTypeBat,0.68083326551649,0.7705556233724))
lights:add(1.1613889058431,0.78722220526801,0.5,false,nil,0.915,0.625,0.785)
envirsh:add(Transition:new(0.15444444020589,1.3580556233724,"maps/BigRoom",nil))
backgr = love.graphics.newQuad(plen(-100), plen(-100), plen(200), plen(200), BrickImg:getDimensions())end
