spawnPoints = { 
 {x = 0.103055551317,y = 1.901111178928},

} 
 
function loadMap(transitionInd)
player1:setPosition(spawnPoints[transitionInd].x,spawnPoints[transitionInd].y)
camera:setBounds(0,0,screenWidth*4,screenHeight*3)
camera:setPosition(0,screenWidth/2)
walls:add(Brick:new(1.4155556572808,1.7900000678168,0.5,0.03,"floor",0,LaserImg))
walls:add(Brick:new(2.9266662597656,0.99972229003906,2,0.05,"floor",1.5700000524521,LaserImg))
walls:add(Brick:new(1.4530554877387,2.024722120497,3,0.05,"floor",0,LaserImg))
walls:add(Brick:new(1.4502777099609,-0.023888905843099,3,0.05,"floor",0,LaserImg))
walls:add(Brick:new(-0.023333337571886,1.0011110941569,2,0.05,"floor",1.5700000524521,LaserImg))
enemies:add(Enemy:new(EnemyTypeMadwizard,2.7058330959744,1.8830556233724))
lights:add(2.8669443766276,0.038611115349664,3,false,nil,1,1,0.78)
lights:add(0.029444440205892,0.031666660308838,3,false,nil,1,1,0.78)
envirsh:add(Transition:new(0.103055551317,1.901111178928,"maps/outMap",nil))
backgr = love.graphics.newQuad(plen(-100), plen(-100), plen(200), plen(200), BrickImg:getDimensions())end