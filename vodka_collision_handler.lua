return function (vodka, player)
  if player.is_player and not vodka.is_player and player.state_name ~= 'legacy_knockover' and player.state_name ~= 'legacy_down' then
    world:del(vodka)
    player.vodka_count = player.vodka_count + 1
    player.audio_vodka:stop()
    player.audio_vodka:play()
  end
end