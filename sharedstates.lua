local sharedstates = {}

sharedstates.update_states = {}
sharedstates.draw_states = {}

function sharedstates.create_update_states()
    local new_update_states = {}

    function new_update_states.knockover(self,dt)
        self.z = self.z + dt*self.knockvz*30
        self.x = self.x + dt*self.knockvx*10
        self.knockvz = self.knockvz - dt * 10
        if self.z < 0 then
            self.z = 0
            self:setstate("down")
            self.stamina = 3
        end
        self:finalize_motion()
    end

    function new_update_states.down(self,dt)
        if self.statetimer > 0.5 then
            self.hitbox.enabled = true
            self.health = self.health - 1
            self:setstate("normal")
        end
    end

    function new_update_states.hit1(self,dt)
        self.x = self.x + dt*self.knockvx * 6
        if self.statetimer > 0.1 then
            self:setstate("hit2")
        end
    end
    function new_update_states.hit2(self)
        if self.statetimer > 0.1 then
            self.hitbox.enabled = true
            self:setstate("normal")
        end
    end

    function new_update_states.punch1(self)
        if self.statetimer > 0.1 then
            self:setstate("punch2")
        end
    end
    function new_update_states.punch2(self)
        if self.left then
            hitbox.tryhit(self, self.x, self.y+12, self.z, 5, 5, 5, {-10, 0, 3})            
        else
            hitbox.tryhit(self, self.x+19, self.y+12, self.z, 5, 5, 5, {10, 0, 3})
        end
        if self.statetimer > 0.1 then
            self:setstate("normal")
        end
    end

    function new_update_states.uppercut1(self)
        if self.statetimer > 0.33 then
            self:setstate("uppercut2")
        end
    end
    function new_update_states.uppercut2(self)
        if self.left then
            hitbox.tryhit(self, self.x, self.y+12, self.z, 5, 5, 5, {-7, 0, 11})            
        else
            hitbox.tryhit(self, self.x+19, self.y+12, self.z, 5, 5, 5, {7, 0, 11})
        end
        if self.statetimer > 0.1 then
            self:setstate("normal")
        end
    end

    function new_update_states.kick1(self)
        if self.statetimer > 0.2 then
            self:setstate("kick2")
        end
    end
    function new_update_states.kick2(self)
        if self.left then
            hitbox.tryhit(self, self.x - 5, self.y+12, self.z, 5, 5, 5, {-16, 0, 2})            
        else
            hitbox.tryhit(self, self.x+19+5, self.y+12, self.z, 5, 5, 5, {16, 0, 2})
        end
        if self.statetimer > 0.1 then
            self:setstate("normal")
        end
    end

    function new_update_states.elbow1(self)
        if self.statetimer > 0.1 then
            self:setstate("elbow2")
        end
    end
    function new_update_states.elbow2(self)
        if self.left then
            hitbox.tryhit(self, self.x+19, self.y+12, self.z, 5, 5, 5, {15, 0, 2})
        else
            hitbox.tryhit(self, self.x, self.y+12, self.z, 5, 5, 5, {-15, 0, 2})            
        end
        if self.statetimer > 0.1 then
            self:setstate("normal")
        end
    end

    function new_update_states.block(self,dx,dy,dz,f,ox)
        if self.statetimer > 1 then
            self.hitbox.enabled = true
            self:setstate("normal")
        end
    end

    return new_update_states
end


function sharedstates.create_draw_states()
    local new_draw_states = {}
    
    function new_draw_states.knockover(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.knockover,dx, dy - dz,nil,f,1,ox)
    end

    function new_draw_states.down(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.down,dx-8, dy - dz+12,nil,f,1,ox)
    end

    function new_draw_states.hit1(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.hit,dx, dy - dz,nil,f,1,ox)
    end
    function new_draw_states.hit2(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.hit,dx, dy - dz,nil,f,1,ox)
    end
    
    function new_draw_states.punch1(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.punch1, dx, dy - dz,nil,f,1,ox)
    end
    function new_draw_states.punch2(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.punch2, dx, dy - dz,nil,f,1,ox)
    end    

    function new_draw_states.uppercut1(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.uppercut1, dx, dy - dz,nil,f,1,ox)
    end
    function new_draw_states.uppercut2(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.uppercut2, dx, dy - dz,nil,f,1,ox)
    end    

    function new_draw_states.kick1(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.punch1, dx, dy - dz,nil,f,1,ox)
    end
    function new_draw_states.kick2(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.kick2, dx, dy - dz,nil,f,1,ox)
    end
        
    function new_draw_states.elbow1(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.punch1, dx, dy - dz,nil,f,1,ox)
    end
    function new_draw_states.elbow2(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.elbow2, dx, dy - dz,nil,f,1,ox)
    end

    function new_draw_states.block(self,dx,dy,dz,f,ox)
        love.graphics.draw(self.frames.block, dx, dy - dz,nil,f,1,ox)
    end
    
    return new_draw_states
end

return sharedstates