local cpml = require 'cpml'
return function (obstacle, player)
  if player.is_player and player.iframes < 0 then
    if player.hurttimer < 0.9 and player.state_name ~= 'legacy_knockover' then
      player.audio_hit:stop()
      player.audio_hit:play()
    end
    player.motion_vector = cpml.vec2.new(-20, 0)
    player.hurttimer = 1
  end
end