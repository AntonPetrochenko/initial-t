local bullet = require 'factories.bullet'
local function pvp_collide (self, other, ex_mutual)
  if not (self.is_player and other.is_player) then return end
  if self.state_name == 'charge' then

      local collision_angle = self.motion_vector:angle_between(other.motion_vector)

      print(self.my_index,  collision_angle)

      local winner, loser

      if self.motion_vector:len() > other.motion_vector:len() then
          winner, loser = self, other
      else
          winner, loser = other, self
      end

      loser.motion_vector = loser.motion_vector:add(winner.motion_vector)
      winner.motion_vector = winner.motion_vector:flip_x():flip_y():trim(0.5)

      winner:setstate('normal')
      loser:setstate('stun')
      

      for i=0,50 do
          local radius, theta = other.motion_vector:to_polar()
          world:add(bullet(
              other.x+math.random(0,30), other.y+math.random(0,40), radius*math.random()*3+1, 0.93, theta+(math.random()*0.3), 0.5, 1, false, true)
          )
      end
  end
end

return pvp_collide