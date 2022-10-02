return function (x,y,path,speed)
  local new_picture = {}
  new_picture.drawable = love.graphics.newImage(path)
  new_picture.x = x
  new_picture.y = y

  new_picture.timer = 0

  function new_picture.draw(self)
    love.graphics.draw(self.drawable,self.x,self.y)
  end

  function new_picture.update(self,dt)
    self.timer = self.timer + (dt*speed)
    self.y = 170.5 + math.sin(self.timer)* 50.5
  end

  return new_picture
end