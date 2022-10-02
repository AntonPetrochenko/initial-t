local sharedstates = {}

sharedstates.legacy_update_states = {}
sharedstates.legacy_draw_states = {}

function sharedstates.legacy_create_update_states()
    local new_update_states = {}

    function new_update_states.legacy_knockover(self,dt)
        self.z = self.z + dt*self.knockvz*30
        self.x = self.x + dt*self.knockvx*10
        self.knockvz = self.knockvz - dt * 20
        if self.z < 0 then
            self.z = 0
            self:setstate("legacy_down")
            self.stamina = 3
        end
        self:finalize_motion()
    end

    function new_update_states.legacy_down(self,dt)
        self.x = self.x - 200 * dt
        if self.statetimer > 0.5 then
            self.hitbox.enabled = true
            self:setstate("legacy_normal")
            
        end
    end

    function new_update_states.legacy_hit1(self,dt)
        self.x = self.x + dt*self.knockvx * 6
        if self.statetimer > 0.1 then
            self:setstate("legacy_hit2")
        end
    end
    function new_update_states.legacy_hit2(self)
        if self.statetimer > 0.1 then
            self.hitbox.enabled = true
            self:setstate("legacy_normal")
        end
    end

    function new_update_states.legacy_punch1(self)
        if self.statetimer > 0.1 then
            self:setstate("legacy_punch2")
        end
    end
    function new_update_states.legacy_punch2(self)
        if self.left then
            hitbox.tryhit(self, self.x, self.y+12, self.z, 5, 5, 5, {-10, 0, 3})            
        else
            hitbox.tryhit(self, self.x+19, self.y+12, self.z, 5, 5, 5, {10, 0, 3})
        end
        if self.statetimer > 0.1 then
            self:setstate("legacy_normal")
        end
    end

    function new_update_states.legacy_uppercut1(self)
        if self.statetimer > 0.33 then
            self:setstate("legacy_uppercut2")
        end
    end
    function new_update_states.legacy_uppercut2(self)
        if self.left then
            hitbox.tryhit(self, self.x, self.y+12, self.z, 5, 5, 5, {-7, 0, 11})            
        else
            hitbox.tryhit(self, self.x+19, self.y+12, self.z, 5, 5, 5, {7, 0, 11})
        end
        if self.statetimer > 0.1 then
            self:setstate("legacy_normal")
        end
    end

    function new_update_states.legacy_kick1(self)
        if self.statetimer > 0.2 then
            self:setstate("legacy_kick2")
        end
    end
    function new_update_states.legacy_kick2(self)
        if self.left then
            hitbox.tryhit(self, self.x - 5, self.y+12, self.z, 5, 5, 5, {-16, 0, 2})            
        else
            hitbox.tryhit(self, self.x+19+5, self.y+12, self.z, 5, 5, 5, {16, 0, 2})
        end
        if self.statetimer > 0.1 then
            self:setstate("legacy_normal")
        end
    end

    function new_update_states.legacy_elbow1(self)
        if self.statetimer > 0.1 then
            self:setstate("legacy_elbow2")
        end
    end
    function new_update_states.legacy_elbow2(self)
        if self.left then
            hitbox.tryhit(self, self.x+19, self.y+12, self.z, 5, 5, 5, {15, 0, 2})
        else
            hitbox.tryhit(self, self.x, self.y+12, self.z, 5, 5, 5, {-15, 0, 2})            
        end
        if self.statetimer > 0.1 then
            self:setstate("legacy_normal")
        end
    end

    function new_update_states.legacy_block(self,dx,dy,dz,f,ox)
        if self.statetimer > 1 then
            self.hitbox.enabled = true
            self:setstate("legacy_normal")
        end
    end

    return new_update_states
end


function sharedstates.legacy_create_draw_states()
    local new_draw_states = {}
    
    function new_draw_states.legacy_knockover(self,dx,dy,dz,f,ox)
        love.graphics.draw(
            self.frames.knockover,
            dx, 
            dy - dz,
            self.statetimer*20,
            f,
            1,
            16,
            16
        )
    end

    function new_draw_states.legacy_down(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.down,dx-8, dy - dz+12,nil,f,1,ox)
    end

    function new_draw_states.legacy_hit1(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.hit,dx, dy - dz,nil,f,1,ox)
    end
    function new_draw_states.legacy_hit2(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.hit,dx, dy - dz,nil,f,1,ox)
    end
    
    function new_draw_states.legacy_punch1(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.punch1, dx, dy - dz,nil,f,1,ox)
    end
    function new_draw_states.legacy_punch2(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.punch2, dx, dy - dz,nil,f,1,ox)
    end    

    function new_draw_states.legacy_uppercut1(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.uppercut1, dx, dy - dz,nil,f,1,ox)
    end
    function new_draw_states.legacy_uppercut2(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.uppercut2, dx, dy - dz,nil,f,1,ox)
    end    

    function new_draw_states.legacy_kick1(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.punch1, dx, dy - dz,nil,f,1,ox)
    end
    function new_draw_states.legacy_kick2(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.kick2, dx, dy - dz,nil,f,1,ox)
    end
        
    function new_draw_states.legacy_elbow1(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.punch1, dx, dy - dz,nil,f,1,ox)
    end
    function new_draw_states.legacy_elbow2(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.elbow2, dx, dy - dz,nil,f,1,ox)
    end

    function new_draw_states.legacy_block(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.block, dx, dy - dz,nil,f,1,ox)
    end
    
    return new_draw_states
end

return sharedstates