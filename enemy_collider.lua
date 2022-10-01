return function (self, other)
  if other.is_bullet then
    other.is_bullet = false
    other.damping = 0.3
    self.health = self.health - 1
  end

  if other.is_player then

    local diff = self.x - other.x

    other.knockvx = (math.random()-0.5)*10
    other.knockvz = 5

    
    other.stamina = other.stamina - 1
    print(other.stamina .. '> 0', other.stamina > 0)
    if other.stamina > 0 then
      
        other:setstate("hit1")
    else
        other:setstate("knockover")
    end
    world:del(self)
  end
end