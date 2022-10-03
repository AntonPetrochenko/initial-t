local cpml = require 'cpml'
return function (obstacle, player)
  if player.is_player and player.iframes < 0 then
    player.motion_vector = cpml.vec2.new(-20, 0)
    player.hurttimer = 1
  end
end