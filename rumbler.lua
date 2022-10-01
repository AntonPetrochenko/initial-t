local rumble = {}

rumble.rumbles = {}

function rumble.run(joystick, intensity, duration)
  local rumble_data = {
    j = joystick,
    current_intensity = intensity,
    step = intensity/duration
  }

  rumble.rumbles[#rumble.rumbles+1] = rumble_data
end

function rumble.update(dt)
  local total_rumble = {}

  for i,v in pairs(rumble.rumbles) do

    if v.current_intensity < 0 then
      table.remove(rumble.rumbles, i)
    end

    total_rumble[v.j] = total_rumble[v.j] or 0
    total_rumble[v.j] = total_rumble[v.j] + v.current_intensity
    v.current_intensity = v.current_intensity - v.step*dt

    
  end

  for i,v in pairs(total_rumble) do
    joysticks[i].instance:setVibration(total_rumble[i])
  end
end

return rumble