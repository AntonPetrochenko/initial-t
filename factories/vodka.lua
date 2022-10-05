vodka_sprite = love.graphics.newImage('/assets/vodka.png')
local vodka_collision_handler = require 'vodka_collision_handler'

return function (x, y, delta_x_mul, delta_y_mul)
  local vodka = {}

  vodka.z = 40
  vodka.x = x
  vodka.y = y+30
  vodka.delta_x = (math.random()+1)*60 * (delta_x_mul or 1)
  vodka.delta_z = 10

  vodka.delta_y = (math.random()*60-30) * (delta_y_mul or 0)

  vodka.timer = 0+math.random()*2

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
    self.y = self.y + self.delta_y*dt

    self.delta_z = self.delta_z + 300*dt
    self.z = self.z - self.delta_z*dt

    
    local top_cutoff = 120
    local bottom_cutoff = 250

    if self.y < top_cutoff then
      self.y = top_cutoff
      self.delta_y = -self.delta_y
    end

    if self.y > bottom_cutoff then
      self.y = bottom_cutoff
      self.delta_y = -self.delta_y
    end

    if self.z < 0 then
      self.z = 0
      self.delta_z = -self.delta_z
    end

    
    


    


    self.finalize_motion()

    if self.x < -50 or self.x > 500 then
      world:del(self)
    end
    
  end

  vodka.draw = function (self)
    
    love.graphics.setColor(0,0,0,0.5)
    love.graphics.ellipse("fill",self.x,self.y,8,4)
    love.graphics.setColor(1,1,1,1)

    love.graphics.draw(vodka_sprite, self.x, self.y - self.z, self.timer*20, 1, 1, 3, 11)

  end

  return vodka
end