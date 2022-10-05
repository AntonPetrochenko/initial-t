local enemy_factory = require 'factories.obstacleobject'
local vodka = require 'factories.vodka'

local function spawn_obstacle(y)
  local obstacle = math.random(1, 4)
  print('spawned')
  if obstacle == 1 then
    world:add(enemy_factory(329,y,"/assets/obstacle1.png", 200))
  elseif obstacle == 2 then
    world:add(enemy_factory(329,y,"/assets/obstacle2.png", 200))
  elseif obstacle == 3 then
    world:add(enemy_factory(329,y,"/assets/obstacle3.png", 200))
  elseif obstacle == 4 then
    world:add(vodka(329,y,1,2))
  end
end

return {
  spawn = function (y)
    spawn_obstacle(y)
  end
}