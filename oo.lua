local bump = require 'bump'

local physicsWorld = bump.newWorld()

return function ()
    local world = {
        objects = {},
        players = {},
        physicsWorld = physicsWorld,
        update = function(self,dt) 
            for i,v in pairs(self.objects) do
                v:update(dt)
            end
        end,
        draw = function(self,dt)
            table.sort(self.objects, function (left, right)
                return left.y < right.y
            end)
            for i,v in pairs(self.objects) do
                v:draw(dt)
                if v.collides then
                    local x,y,w,h = physicsWorld:getRect(v)

                    -- love.graphics.rectangle("fill",v.x, v.y, 1, 1)
                    -- love.graphics.rectangle('line',x,y,w,h)
                end
            end
        end,
        add = function(self,new)
            local o = self.objects
            local newid = love.math.random(999999999)
    
            if new.collides then
                local x_offset = new.pox or 0
                local y_offset = new.poy or 0
                physicsWorld:add(new, new.x + x_offset, new.y + y_offset, new.pw, new.ph)
    
                new.touching = function (target_type)
                    physicsWorld:queryRect(new.x-1,new.y-1,new.pw+2,new.ph+2, function (item)
                        local notme = item.myid ~= newid
                        local istype = item.collision_type == target_type
                    end)
                end
    
                new.finalize_motion = function ()
                    local actualX, actualY, cols = physicsWorld:move(new, new.x+x_offset, new.y+y_offset, function (item, other)
                        if
                            (item.againstme and item.againstme == 'cross') or
                            (other.againstme and other.againstme == 'cross')
                        then
                            return 'cross'
                        else
                            return other.againstme or 'slide'
                        end
                    end)
                    for i,v in pairs(cols)  do
                        v.item.on_collision(v.item, v.other)
                    end
                    new.x, new.y = actualX - x_offset, actualY - y_offset 
                end
    
            end
            
    
    
            o[#o+1] = new
            new.myid = newid
        end,
        del = function(self,old) 
            local o = self.objects
            local todelete = nil
            for i,v in pairs(o) do
                if v.myid == old.myid then
                    todelete = i
                end
            end
            if o[todelete] then
                if o[todelete].collides then
                    physicsWorld:remove(o[todelete])
                end
                table.remove(o,todelete)
                
            else
                print("Deleting nonexistant object",todelete)
            end
        end
    }
    return world
end
