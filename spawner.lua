local enemy_factory = require 'factories.obstacleobject'

local function spawn_obstacle(y)
  local obstacle = math.random(1, 3)
  print('spawned')
  if obstacle == 1 then
    world:add(enemy_factory(329,y,"/assets/obstacle1.png", 200))
  elseif obstacle == 2 then
    world:add(enemy_factory(329,y,"/assets/obstacle2.png", 200))
  elseif obstacle == 3 then
    world:add(enemy_factory(329,y,"/assets/obstacle3.png", 200))
  end
end

return {
  spawn = function (y)
    local alivePlayers = 0
    for i,v in pairs(joysticks) do
      if not v.available then
        alivePlayers = alivePlayers + 1
      end
    end
    if alivePlayers > -1 then
      spawn_obstacle(y)
    end
  end
}