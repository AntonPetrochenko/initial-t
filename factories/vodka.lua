local vodka_sprite = love.graphics.newImage('/assets/vodka.png')
local vodka_collision_handler = require 'vodka_collision_handler'

return function (x, y)
  local vodka = {}

  vodka.z = 40
  vodka.x = x
  vodka.y = y+30
  vodka.delta_x = (math.random()+1)*60
  vodka.delta_z = 10

  vodka.timer = 0

  vodka.againstme = 'cross'

  vodka.is_vodka = true
  vodka.on_collision = function (self, other)
    vodka_collision_handler(self, other)
  end

  vodka.collides = true
  vodka.pox = -4
  vodka.poy = -4
  vodka.pw = 6
  vodka.ph = 4

  vodka.update = function (self, dt)
    self.timer = self.timer + dt
    self.x = self.x - self.delta_x*dt

    self.delta_z = self.delta_z + 300*dt
    self.z = self.z - self.delta_z*dt

    if self.z < 0 then
      self.z = 0
      self.delta_z = -self.delta_z
    end

    self.finalize_motion()
  end

  vodka.draw = function (self)
    
    love.graphics.setColor(0,0,0,0.5)
    love.graphics.ellipse("fill",self.x,self.y,8,4)
    love.graphics.setColor(1,1,1,1)

    love.graphics.draw(vodka_sprite, self.x, self.y - self.z, self.timer*20, 1, 1, 3, 11)

  end

  return vodka
end