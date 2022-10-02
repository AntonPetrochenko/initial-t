local gradient = require 'gradient_mesh'

local bullet_gradient = gradient('horizontal', {0.5,0,0,0},{1,0,0,1}, {1,1,0,1}, {1,1,1,1}, {1,1,1,1})

return function (x,y,vel, damping, angle, cut, width)
  local new_bullet = {}

  new_bullet.x = x
  new_bullet.y = y

  new_bullet.damping = damping

  new_bullet.width = width

  new_bullet.angle = angle


  new_bullet.vel = vel

  new_bullet.is_bullet = true

  -- new_bullet.collides = true
  -- new_bullet.pw = 8
  -- new_bullet.ph = 8
  new_bullet.on_collision = function (self, other)

  end

  new_bullet.life = cut

  function new_bullet.update(self, dt)

    self.vel = self.vel * self.damping

    self.life = self.life - dt

    

    self.x = self.x + math.cos(angle)*self.vel
    self.y = self.y + math.sin(angle)*self.vel

    -- self:finalize_motion()

    if self.life < 0 then
      self.damping = 0.9
    end
    
    if self.vel < 0.1 then world:del(self) end
  end

  function new_bullet.draw(self)

    local length = 8 * (  math.log( math.pow(self.vel, 0.6)  ) + 1.5 )
    
    love.graphics.draw(bullet_gradient, self.x+4, self.y+4, self.angle, length, self.width or 1, 0.5, 0.5 )
    -- love.graphics.rectangle("fill",self.x, self.y,2,2)
  end
  return new_bullet
end