local bullet = require 'factories.bullet'
local sharedstates = require 'sharedstates'
local vodka_collision_handler = require 'vodka_collision_handler'
local cart_sprite = {
    love.graphics.newImage("/assets/cart.png"),
    love.graphics.newImage("/assets/cart2.png"),  
}

local vodka = require 'factories/vodka'

local crosshair_sprite = love.graphics.newImage("/assets/crosshair.png")
local pvp_collide = require 'pvp_collision_handler'
local obstacle_collision_handler = require 'obstacle_collision_handler'
local cpml = require('cpml')

function lineStipple( x1, y1, x2, y2, dash, gap )
    local dash = dash or 10
    local gap  = dash + (gap or 10)

    local steep = math.abs(y2-y1) > math.abs(x2-x1)
    if steep then
        x1, y1 = y1, x1
        x2, y2 = y2, x2
    end
    if x1 > x2 then
        x1, x2 = x2, x1
        y1, y2 = y2, y1
    end

    local dx = x2 - x1
    local dy = math.abs( y2 - y1 )
    local err = dx / 2
    local ystep = (y1 < y2) and 1 or -1
    local y = y1
    local maxX = x2
    local pixelCount = 0
    local isDash = true
    local lastA, lastB, a, b

    for x = x1, maxX do
        pixelCount = pixelCount + 1
        if (isDash and pixelCount == dash) or (not isDash and pixelCount == gap) then
            pixelCount = 0
            isDash = not isDash
            a = steep and y or x
            b = steep and x or y
            if lastA then
                love.graphics.line( lastA, lastB, a, b )
                lastA = nil
                lastB = nil
            else
                lastA = a
                lastB = b
            end
        end

        err = err - dy
        if err < 0 then
            y = y + ystep
            err = err + dx
        end
    end
end

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

    player.vodka_count = 0

    player.state_name = 'normal'

    player.y_depth_correction = 32

    player.motion_vector = cpml.vec2.new(0,0)
    player.aim_vector = cpml.vec2.new(0,0)
    
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


    player.audio_charge = love.audio.newSource('/assets/audio/charge.ogg',"static")
    player.audio_cancel = love.audio.newSource('/assets/audio/charge-cancel.ogg',"static")
    player.audio_boom = love.audio.newSource('/assets/audio/boom.ogg',"static")
    player.audio_hit = love.audio.newSource('/assets/audio/cart-hit.wav',"static")
    player.audio_respawn = love.audio.newSource('/assets/audio/respawn.ogg',"static")
    player.audio_vodka = love.audio.newSource('/assets/audio/vodka.ogg',"static")
    player.audio_splat = love.audio.newSource('/assets/audio/splat.ogg',"static")
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
        if other.is_player then vodka_collision_handler(other, self) end
    end

    player.isplayer = true
    player.is_player = true

    player.iframes = 5

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
    player.hurttimer = 0

    player.left = false

    function player.tick_motion_vector(self, dt, friction_multiplier)
        self.motion_vector = self.motion_vector:scale(1-dt*(2*(friction_multiplier or 1)))
        self.motion_vector = self.motion_vector:trim(5)
        self.x = self.x + 100 * (self.motion_vector.x*dt)
        self.y = self.y + 80 * (self.motion_vector.y*dt)
    end

    function player.walk_movement(self, dt)
        local ax1, ax2, ax3, ax4, ax5, ax6 = self.joy:getAxes()
        if math.abs(ax1) < 0.2 then ax1 = 0 end
        if math.abs(ax2) < 0.2 then ax2 = 0 end

        if ax1 >  0.1 then player.left = false end


        local delta_vec2 = cpml.vec2.new(ax1-0.4, ax2) -- -0.4

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
        local ax1, ax2, ax3, ax4 = self.joy:getAxes()
        if (joyAnyDown(player.joy) and player.statetimer > 3) then
            player:setstate('charge')
                self.audio_respawn:play()
                self.audio_charge:play()
                self.motion_vector = cpml.vec2.new(ax3, ax4):scale(1)
            --player:setstate('legacy_knockover')
        end

        self.aim_vector = self.aim_vector:lerp(cpml.vec2.new(ax3, ax4), 1):trim(1)

        if player.statetimer < 3 and player.statetimer % 0.15 < 0.05 then
            local radius, theta = player.motion_vector:to_polar()
            world:add(bullet(
                player.x-5, player.y+32, math.random()*3, 0.93, (math.pi+0.2)+(math.random()*0.5), 0.5, 4, true)
            )
        end

        player.walk_movement(self, dt)
    end
    
    function player.draw_states.normal(self,dx,dy,dz,f,ox)
        local ax1, ax2, ax3, ax4 = self.joy:getAxes()
        -- if math.abs(ax1) > 0.2 or math.abs(ax2) > 0.2 then
        --     if self.statetimer % 0.4 < 0.2 then love.graphics.draw(self.frames.walk1,dx,dy - dz,nil,f,1,ox)
        --     else love.graphics.draw(self.frames.walk2,dx,dy - dz,nil,f,1,ox) end
        -- else
        --     love.graphics.draw(self.frames.idle,dx,dy - dz,nil,f,1,ox)
        -- end

        
        if self.statetimer > 3 then
            local lox = math.floor(dx + 16)
            local loy = math.floor(dy + 40)
            
            local lex, ley = self.aim_vector:unpack()

            local crosshair_x = math.floor(lox+lex*50)
            local crosshair_y = loy+ley*50
            love.graphics.setColor(1,0,0,1)
            for ix=-1,1 do
                for iy=-1,1 do
                    lineStipple(lox, loy, crosshair_x, crosshair_y, 5, 1)
                end
            end
            love.graphics.setColor(1,1,1,1)
            love.graphics.draw(crosshair_sprite, crosshair_x-6, crosshair_y-6)
        end
        
        local vodka_iterator = 0

        local vodka_x = 0
        local vodka_y = 0

        local vodka_origin_x = math.floor(0 + player.x)+8
        local vodka_origin_y = math.floor(0 + player.y)+10

        local row_count = math.floor(self.vodka_count/3)

        local vodka_top_y = vodka_origin_y - row_count * 10


        -- unfilled row
        for i=0,2 do
            if i<self.vodka_count%3 then
                love.graphics.draw(vodka_sprite, vodka_origin_x + i * 6 + (row_count)%2, vodka_top_y)
            end
        end

        --filled row
        for i=1,math.floor(self.vodka_count/3) do
            for j=0,2 do
                love.graphics.draw(vodka_sprite, vodka_origin_x + j * 6 + (i+row_count)%2, vodka_top_y+i*10)
            end
        end

        
        

        local frame_offset = math.floor((self.animation_timer*50)%2)
        local face = 'neutral'
        if (ax1 < -0.1) then face = 'left' end
        if (ax1 > 0.1) then face = 'right' end
        if (self.hurttimer > 0) then face = 'hurt' end
        love.graphics.draw(self.frames.cart[face],dx+8,dy - frame_offset - 4 - dz,nil,1,1)
        love.graphics.draw(cart_sprite[frame_offset+1],dx,dy+14 - dz,nil,1,1)



        
    end

    function player.update_states.charge(self, dt)
        player:tick_motion_vector(dt, -1.2)
        local radius, theta = player.motion_vector:to_polar()
        world:add(bullet(
            player.x-5, player.y+32, radius*math.random()+4, 0.93, (math.pi+0.2)+(math.random()*0.3), 0.5)
        )
        if player.statetimer > 0.4 and not joyAnyDown(player.joy) then
            if player.statetimer < 1 then
                self.audio_charge:stop()
                self.audio_cancel:play()
            end
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

        self.hurttimer = self.hurttimer - dt
        self.iframes = self.iframes - dt


        -- wall collision

        if self.y < top_cutoff then
            self.y = top_cutoff
            self.motion_vector = self.motion_vector:flip_y()
            self.motion_vector.x = -3
            
            self.audio_hit:stop()
            self.audio_hit:play()
        end
        if self.y > bottom_cutoff then
            self.y = bottom_cutoff
            self.motion_vector = self.motion_vector:flip_y()
            self.motion_vector.x = -3
            
            self.audio_hit:stop()
            self.audio_hit:play()
        end

        if self.x > 330 then
            self.x = 330
            self.motion_vector.x = 0
        end

        if self.x < 0 and self.iframes > 0 and self.state_name ~= 'legacy_down' then
            self.x = 0
        end

        if self.x < -50 then
            if self.state_name == 'legacy_down' then
                if self.health < 1 then
                    self.iwannadie = true
                else
                    self.x = 10
                    self.y = top_cutoff + self.my_index * 20
                    self.motion_vector = cpml.vec2(3, 0)
                    self:setstate('normal')
                    self.againstme = 'slide'
                    self.health = self.health - 1
                    self.audio_respawn:play()
                end
            else
                self.againstme = 'cross'
                self.knockvx = 30
                self.knockvz = 10
                self:setstate('legacy_knockover')
                self.audio_boom:play()
                self.audio_charge:stop()

                local third_of_vodka = math.floor(self.vodka_count / 3)
                self.vodka_count = self.vodka_count - third_of_vodka
                for i=0,20 do
                    world:add(bullet(
                        self.x, self.y+20, 10*math.random(),
                        0.99,
                        (-math.random()*0.5),
                        2,
                        16
                    ))
                end

                print(third_of_vodka)
                if third_of_vodka > 0 then
                    for i=0,third_of_vodka do
                        world:add(vodka(self.x+20, self.y, -3*math.random(), 2))
                    end
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
        local ax1, ax2, ax3, ax4, ax5, ax6 = self.joy:getAxes()

        local dx, dy, dz = math.floor(self.x), math.floor(self.y), math.floor(self.z)
        local f = self.left and -1 or 1
        local ox = self.left and 24 or 0
        if self.z > 3 then
            love.graphics.setColor(0,0,0,0.5)
            love.graphics.ellipse("fill",self.x+12,self.y+32,8,4)
            love.graphics.setColor(1,1,1,1)
        elseif self.state_name ~= 'legacy_down' then
            love.graphics.setColor(0,0,0,0.5)
            love.graphics.ellipse("fill",self.x+18,self.y+40,16,4)
            love.graphics.setColor(1,1,1,1)
        end

        if (self.iframes > 0 and self.iframes % 0.25 > 0.125) or self.iframes < 0 then
            self:current_draw_state(dx,dy,dz,f,ox)
        end
    end
    return player
end




