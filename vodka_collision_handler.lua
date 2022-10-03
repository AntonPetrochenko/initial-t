return function (vodka, player)
  if player.is_player then
    world:del(vodka)
    player.vodka_count = player.vodka_count + 1
  end
end