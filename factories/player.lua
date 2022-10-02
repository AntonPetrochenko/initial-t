local bullet = require 'factories.bullet'
local sharedstates = require 'sharedstates'
local cart_sprite = love.graphics.newImage("/assets/cart.png")
local pvp_collide = require 'pvp_collision_handler'
local obstacle_collision_handler = require 'obstacle_collision_handler'
local cpml = require('cpml')

local _____abs = math.abs

math.abs = function (n)
    return _____abs(n or 0)
end

return function (joyrecord,x,y)
    local player = {}

    player.team = 0
    --- @type love.Joystick
    player.joy = joyrecord.instance
    player.inputbuffer = {}
    player.x = x
    player.y = y
    player.z = 0

    player.state_name = 'normal'

    player.y_depth_correction = 32

    player.motion_vector = cpml.vec2.new(0,0)
    
    player.shoot_x = 24/2
    player.shoot_y = 32/2

    player.collides = true
    player.pw = 24
    player.ph = 12
    player.poy = 28
    player.pox = 4

    player.againstme = 'slide'

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


    local function merg(to, from) 
        for k,v in pairs(from) do to[k] = v end
    end

    local lds = sharedstates.legacy_create_draw_states()
    local lus = sharedstates.legacy_create_update_states()
    merg(player.draw_states, lds)
    merg(player.update_states, lus)

    player.wpnbonustimer = 0

    player.on_collision = function (self, other)
        if other.is_player then pvp_collide(self, other) end
        if other.is_obstacle then obstacle_collision_handler(other, self) end
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

    function player.tick_motion_vector(self, dt, friction_multiplier)
        self.motion_vector = self.motion_vector:scale(1-dt*(2*(friction_multiplier or 1)))
        self.motion_vector = self.motion_vector:trim(5)
        self.x = self.x + 100 * (self.motion_vector.x*dt)
        self.y = self.y + 50 * (self.motion_vector.y*dt)
    end

    function player.walk_movement(self, dt)
        local ax1, ax2, ax3, ax4, ax5, ax6 = self.joy:getAxes()
        if math.abs(ax1) < 0.2 then ax1 = 0 end
        if math.abs(ax2) < 0.2 then ax2 = 0 end

        if ax1 >  0.1 then player.left = false end


        local delta_vec2 = cpml.vec2.new(ax1, ax2) -- -0.4

        delta_vec2 = delta_vec2:scale(0.1)
        self.motion_vector = self.motion_vector:add(delta_vec2)
        self:tick_motion_vector(dt)
        

        if math.abs(ax1) > 0.2 then
            self.inactivity = 0
        end

        player.finalize_motion()
    end

    -- state normal
    function player.update_states.normal(self, dt)
        self.inactivity = self.inactivity + dt
        if (joyAnyDown(player.joy) and player.statetimer > 3) then
            player:setstate('charge')
            
            --player:setstate('legacy_knockover')
        end

        if player.statetimer < 3 and player.statetimer % 0.15 < 0.05 then
            local radius, theta = player.motion_vector:to_polar()
            world:add(bullet(
                player.x-5, player.y+32, math.random()*3, 0.93, (math.pi+0.2)+(math.random()*0.5), 0.5, 4, true)
            )
        end

        player.walk_movement(self, dt)
    end
    
    function player.draw_states.normal(self,dx,dy,dz,f,ox)
        -- local ax1, ax2, ax3, ax4 = self.joy:getAxes()
        -- if math.abs(ax1) > 0.2 or math.abs(ax2) > 0.2 then
        --     if self.statetimer % 0.4 < 0.2 then love.graphics.draw(self.frames.walk1,dx,dy - dz,nil,f,1,ox)
        --     else love.graphics.draw(self.frames.walk2,dx,dy - dz,nil,f,1,ox) end
        -- else
        --     love.graphics.draw(self.frames.idle,dx,dy - dz,nil,f,1,ox)
        -- end
        

        local frame_offset = math.floor((self.animation_timer*50)%2)
        love.graphics.draw(self.frames.cart.neutral,dx+8,dy - 4 - dz,nil,1,1)
        love.graphics.draw(cart_sprite,dx,dy+14 - dz,nil,1,1)
        
    end

    function player.update_states.charge(self, dt)
        player:tick_motion_vector(dt, -1.2)
        local radius, theta = player.motion_vector:to_polar()
        world:add(bullet(
            player.x-5, player.y+32, radius*math.random()+4, 0.93, (math.pi+0.2)+(math.random()*0.3), 0.5)
        )
        player.joy:setVibration(player.motion_vector:len())
        if player.statetimer > 0.7 and not joyAnyDown(player.joy) then
            player:setstate('normal')
        end
        self.finalize_motion()
    end
    player.draw_states.charge = player.draw_states.normal


    function player.setstate(self, newstate)
        self.statetimer = 0
        self.inactivity = 0
        if self.update_states[newstate] then 
            player.state_name = newstate
            print("Changing state for " .. (player.my_index or 'not known yet'), newstate)
            self.current_update_state = self.update_states[newstate]
            self.current_draw_state = self.draw_states[newstate]
        else 
            print("BAD STATAE " .. newstate)
        end
    end

    player:setstate("normal")

    function player.update(self,dt)
        local top_cutoff = 90
        local bottom_cutoff = 220
        if self.y < top_cutoff then
            self.y = top_cutoff
            self.motion_vector = self.motion_vector:flip_y()
            self.motion_vector.x = -3
        end
        if self.y > bottom_cutoff then
            self.y = bottom_cutoff
            self.motion_vector = self.motion_vector:flip_y()
            self.motion_vector.x = -3
        end

        if self.x > 330 then
            self.x = 330
            self.motion_vector.x = 0
        end

        if self.x < -50 then
            if self.state_name == 'legacy_down' then
                if self.health < 1 then
                    self.iwannadie = true
                else
                    self.x = 10
                    self.y = top_cutoff + self.my_index * 40
                    self.motion_vector = cpml.vec2(5, 0)
                    self:setstate('normal')
                    self.againstme = 'slide'
                    self.health = self.health - 1
                    print(self.health)
                end
            else
                
                self.againstme = 'cross'
                self.knockvx = 30
                self.knockvz = 10
                self:setstate('legacy_knockover')
                for i=0,50 do
                    world:add(bullet(
                        self.x, self.y+20, 10*math.random(),
                        0.99,
                        (-math.random()*0.5),
                        2,
                        16
                    ))
                end
            end
            

            
            
        end
        self:current_update_state(dt)
        self.statetimer = self.statetimer + dt

        self.animation_timer = self.animation_timer + dt/2

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

