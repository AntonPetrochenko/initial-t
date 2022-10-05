return function (msg)
  world:add({
    y = 99999,
    timer = 400,
    update = function (self, dt)
      self.timer = self.timer - dt*200
    end,
    draw = function (self, dt)
      love.graphics.setColor(0,0,0,1)
      for xi=-1,1 do
          for yi=-1,1 do
              love.graphics.print(msg,math.floor(self.timer)+xi,80+yi)
          end
      end
      love.graphics.setColor(1,1,1,1)
      love.graphics.print(msg,math.floor(self.timer),80)
    end
  })
end