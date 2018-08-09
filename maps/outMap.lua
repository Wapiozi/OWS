spawnPoints = { 
 {x = 2.5419443766276,y = 2.4844445122613},
{x = 1,y = 2.9},

} 
 
function loadMap(transitionInd)
player1:setPosition(spawnPoints[transitionInd].x,spawnPoints[transitionInd].y)
camera:setBounds(0,0,screenWidth*4,screenHeight*3)
camera:setPosition(0,screenWidth/2)
walls:add(Brick:new(4.2697221544054,2.4094445122613,0.5,0.05,"floor",1,LaserImg))
walls:add(Brick:new(4.7419443766276,2.902500406901,0.2,0.05,"floor",1.5700000524521,LaserImg))
walls:add(Brick:new(3,2.7950000339084,2,0.01,"floor",0,LaserImg))
walls:add(Brick:new(2,2.5950000339084,2,0.01,"floor",0,LaserImg))
walls:add(Brick:new(-0.05,1.5,0.1,3,"wall",0,LaserImg))
walls:add(Brick:new(3.5555555555556,3.05,7.1111111111111,0.1,"floor",0,LaserImg))
walls:add(Brick:new(7.1611111111111,1.5,0.1,3,"wall",0,LaserImg))
walls:add(Brick:new(3.5555555555556,-0.05,7.1111111111111,0.1,"floor",0,LaserImg))
enemies:add(Enemy:new(EnemyTypeBat,5.9572224934896,2.3552778455946))
enemies:add(Enemy:new(EnemyTypeBat,6.2336113823785,2.4219445122613))
enemies:add(Enemy:new(EnemyTypeMadwizard,5.6905558268229,2.863611178928))
enemies:add(Enemy:new(EnemyTypeMadwizard,5.9683336046007,2.8497222900391))
enemies:add(Enemy:new(EnemyTypeMadwizard,6.3169440375434,2.8594448513455))
enemies:add(Enemy:new(EnemyTypeMadwizard,6.6597222222222,2.8430553860135))
lights:add(1.6558332655165,2.0608334011502,0.5,false,nil,1,1,0.62)
lights:add(1.4638888888889,2.6472220526801,0.5,false,nil,1,1,0.745)
lights:add(5,2.4486111111111,0.5,false,nil,1,1,0.71)
lights:add(1.0611111111111,2.1444444444444,0.5,false,nil,1,1,0.705)
envirsh:add(Transition:new(2.5419443766276,2.4844445122613,"maps/BigRoom",nil))
envirsh:add(Transition:new(1,2.9,"maps/start",nil))
end
