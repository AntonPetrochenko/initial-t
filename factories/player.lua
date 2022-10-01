local bullet = require 'factories.bullet'

local cpml = require('cpml')

return function (joyrecord,x,y)
    local player = {}

    print(love.filesystem.getWorkingDirectory())

    player.team = 0
    player.joy = joyrecord.instance
    player.inputbuffer = {}
    player.x = x
    player.y = y
    player.z = 0

    player.motion_vector = cpml.vec2.new(0,0)
    
    player.shoot_x = 24/2
    player.shoot_y = 32/2

    player.collides = true
    player.pw = 24
    player.ph = 32

    player.speed_rampup = 0


    player.update_states = {}
    player.draw_states = {}

    player.fire_timer = -0.1

    player.health = 3
    player.stamina = 10
    player.inactivity = 0
    player.score = 0

    player.animation_timer = 0

    player.weapon = {
        impulse = 7,
        damping = 1,
        cut = 0.2,

        spread = 1,
        spray = 0.1,

        number = 1,
        damage = 1,

        rate = 0.3,

        spread_amount = 1.2
    }


    player.wpnbonustimer = 0

    player.on_collision = function (self, other)
    end

    player.isplayer = true
    player.is_player = true

    

    player.hitbox = hitbox.new(0, 0, 0, 24, 32, 5, function (attacker,hitv)
        player.knockvx = hitv[1]
        player.knockvz = hitv[3]
        player.stamina = player.stamina - 1
        
        if hitv[3] > 10 then
            player.stamina = -1
            
        end
        player.hitbox.enabled = false
        if player.stamina > 0 then
            player:setstate("hit1")
        else
            attacker.score = attacker.score + 1
            player:setstate("knockover")
        end
    
    end)
    

    player.statetimer = 0

    player.left = false

    local function walk_movement(self, dt)
        local ax1, ax2, ax3, ax4, ax5, ax6 = self.joy:getAxes()
        if math.abs(ax1) < 0.2 then ax1 = 0 end
        if math.abs(ax2) < 0.2 then ax2 = 0 end

        if ax1 >  0.1 then player.left = false end


        local delta_vec2 = cpml.vec2.new(ax1, ax2)

        delta_vec2 = delta_vec2:scale(0.1)

        self.motion_vector = self.motion_vector:add(delta_vec2)
        self.motion_vector:trim(1)

        self.motion_vector = self.motion_vector:scale(1-dt*2)


        print(self.motion_vector.x, self.motion_vector.y)
        print(delta_vec2.x, delta_vec2.y)
        self.x = self.x + 100 * (self.motion_vector.x*dt)
        self.y = self.y + 50 * (self.motion_vector.y*dt)

        if math.abs(ax1) > 0.2 then
            self.inactivity = 0
        end

        self.finalize_motion()
    end

    -- state normal
    function player.update_states.normal(self, dt)
        self.inactivity = self.inactivity + dt
        walk_movement(self, dt)
    end
    
    function player.draw_states.normal(self,dx,dy,dz,f,ox)
        -- local ax1, ax2, ax3, ax4 = self.joy:getAxes()
        -- if math.abs(ax1) > 0.2 or math.abs(ax2) > 0.2 then
        --     if self.statetimer % 0.4 < 0.2 then love.graphics.draw(self.frames.walk1,dx,dy - dz,nil,f,1,ox)
        --     else love.graphics.draw(self.frames.walk2,dx,dy - dz,nil,f,1,ox) end
        -- else
        --     love.graphics.draw(self.frames.idle,dx,dy - dz,nil,f,1,ox)
        -- end
        love.graphics.rectangle("fill",dx, dy, 2, 2)

        local frame_offset = math.floor((self.animation_timer*50)%2) 
        print(frame_offset)
        love.graphics.draw(self.frames.drive[1+frame_offset],dx,dy - dz,nil,1,1)
        
    end


    function player.setstate(self, newstate)
        self.statetimer = 0
        self.inactivity = 0
        if self.update_states[newstate] then 
            print("CHANGIN STATE!!11 " .. newstate)
            self.current_update_state = self.update_states[newstate]
            self.current_draw_state = self.draw_states[newstate]
        else 
            print("BAD STATAE " .. newstate)
        end
    end

    player:setstate("normal")

    function player.update(self,dt)

        

        if self.x < -140 then
            self.x = -140
        end
        if self.x > 600 then
            self.x = 600
        end
        if self.y < 110 then
            self.y = 110 
        end
        if self.y > 160 then
            self.y = 160
        end
        self:current_update_state(dt)
        self.statetimer = self.statetimer + dt

        self.animation_timer = self.animation_timer + dt

        self.z = self.z - dt * 10
        if self.z < 0 then self.z = 0 end
    end

    function player.draw(self)
        local dx, dy, dz = math.floor(self.x), math.floor(self.y), math.floor(self.z)
        local f = self.left and -1 or 1
        local ox = self.left and 24 or 0
        if self.z > 3 then
            love.graphics.setColor(0,0,0,0.5)
            love.graphics.ellipse("fill",self.x+12,self.y+32,8,4)
            love.graphics.setColor(1,1,1,1)
        end 
        self:current_draw_state(dx,dy,dz,f,ox)
    end
    return player
end