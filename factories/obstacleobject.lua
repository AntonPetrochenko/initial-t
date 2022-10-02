return function (x,y,path,speed)
  local new_picture = {}
  new_picture.drawable = love.graphics.newImage(path)
  new_picture.x = x
  new_picture.y = y
  new_picture.ready = 0

  new_picture.timer = 0

  function new_picture.draw(self)
    if (self.timer < 1.5) then
      if self.timer % 0.20 < 0.15 then
        love.graphics.draw(self.drawable,self.x,self.y)
      end
    else
      if self.ready == 0 then self.ready = 1 end
      love.graphics.draw(self.drawable,self.x,self.y)
    end
  end

  function new_picture.update(self,dt)
    self.timer = self.timer + (dt)
    if self.ready == 1 then
      self.x = self.x - (dt * speed)
    end
  end

  return new_picture
end