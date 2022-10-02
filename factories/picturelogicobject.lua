local spawn_obstacle = require 'spawner'

return function (x,y,path,speed)
  local new_picture = {}
  new_picture.drawable = love.graphics.newImage(path)
  new_picture.x = x
  new_picture.y = y

  new_picture.timer = 0

  new_picture.next_spawn = 3

  new_picture.spawn_timer = 0

  function new_picture.draw(self)
    love.graphics.draw(self.drawable,self.x,self.y-50)
  end

  function new_picture.update(self,dt)
    self.spawn_timer = self.spawn_timer + (dt)
    self.timer = self.timer + (dt*speed)
    self.y = 170.5 + math.sin(self.timer)* 50.5
    

    if (self.spawn_timer > self.next_spawn) then
      self.spawn_timer = 0
      self.next_spawn = math.random(2,5)
      spawn_obstacle.spawn(self.y-30)
    end
  end

  return new_picture
end