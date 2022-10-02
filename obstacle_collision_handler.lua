local cpml = require 'cpml'
return function (obstacle, player)
  player.motion_vector = cpml.vec2.new(-20, 0)
end