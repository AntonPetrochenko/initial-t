sounds = require 'sounds'

worldMaker = require 'oo'

world = worldMaker()

--world:add(upgrade(0,130,'shotgun'))

--world:add(upgrade(30,130,'minigun'))

hitbox = require 'hitbox.hitbox'
local player_factory = require 'factories.player'
local picture_factory = require 'factories.pictureobject'
local parallax_factory = require 'factories.parallax'
local gameTimer = 0
local needRestart = false

function point_direction(x1,y1,x2,y2)
    return math.atan2(y2-y1,x2-x1)
end

function dump(o) 
    for i,v in pairs(o) do
        print(i,v)
    end
end


font = love.graphics.newFont("/assets/uni0553-webfont.ttf")
love.graphics.setFont(font)

spawnpos = 0
camgoal = 0
camx = 0

screenCanvas = love.graphics.newCanvas(160*2,90*2)
love.graphics.setDefaultFilter("nearest", "nearest")
screenCanvas:setFilter("nearest","nearest")

local bum_frames = {}
bum_frames[1] = {
    drive = {
        love.graphics.newImage("/assets/blue-drive.png"),
        love.graphics.newImage("/assets/blue-drive-2.png")
    } 
}
bum_frames[2] = {
    idle = love.graphics.newImage("/assets/green_idle_00.png"),
    punch1 = love.graphics.newImage("/assets/green_ready_00.png"),
    punch2 = love.graphics.newImage("/assets/green_punch_04.png"),
    block = love.graphics.newImage("/assets/green_block_00.png"),
    hit = love.graphics.newImage("/assets/green_hit_00.png"),
    knockover = love.graphics.newImage("/assets/green_knockover_00.png"),
    down = love.graphics.newImage("/assets/green_down_00.png"),
    
    uppercut1 = love.graphics.newImage("/assets/green_uppercut_00.png"),
    uppercut2 = love.graphics.newImage("/assets/green_uppercut_02.png"),
    kick2 = love.graphics.newImage("/assets/green_kick_02.png"),
    elbow2 = love.graphics.newImage("/assets/green_elbowpunch_02.png"),
    drive = {
        love.graphics.newImage("/assets/green_idlewalk_2.png"),
        love.graphics.newImage("/assets/green_idlewalk_6.png")
    }
    
}
bum_frames[3] = {
    idle = love.graphics.newImage("/assets/gray_idle_00.png"),
    punch1 = love.graphics.newImage("/assets/gray_ready_00.png"),
    punch2 = love.graphics.newImage("/assets/gray_punch_02.png"),
    block = love.graphics.newImage("/assets/gray_block_00.png"),
    hit = love.graphics.newImage("/assets/gray_hit_00.png"),
    knockover = love.graphics.newImage("/assets/gray_kockover_00.png"),
    down = love.graphics.newImage("/assets/gray_down_00.png"),
    
    uppercut1 = love.graphics.newImage("/assets/gray_uppercut_00.png"),
    uppercut2 = love.graphics.newImage("/assets/gray_uppercut_02.png"),
    kick2 = love.graphics.newImage("/assets/gray_kick_02.png"),
    elbow2 = love.graphics.newImage("/assets/gray_elbowpunch_02.png"),

    drive = {
        love.graphics.newImage("/assets/gray_idlewalk_0.png"),
        love.graphics.newImage("/assets/gray_idlewalk_1.png")
    }
}
bum_frames[4] = {
    idle = love.graphics.newImage("/assets/red_idle_00.png"),
    punch1 = love.graphics.newImage("/assets/red_ready_00.png"),
    punch2 = love.graphics.newImage("/assets/red_punch_02.png"),
    block = love.graphics.newImage("/assets/red_block_00.png"),
    hit = love.graphics.newImage("/assets/red_hit_00.png"),
    knockover = love.graphics.newImage("/assets/red_knockover_00.png"),
    down = love.graphics.newImage("/assets/red_down_00.png"),
    
    uppercut1 = love.graphics.newImage("/assets/red_uppercut_00.png"),
    uppercut2 = love.graphics.newImage("/assets/red_uppercut_02.png"),
    kick2 = love.graphics.newImage("/assets/red_kick_02.png"),
    elbow2 = love.graphics.newImage("/assets/red_elbowpunch_02.png"),

    walk1 = love.graphics.newImage("/assets/red_idlewalk_0.png"),
    walk2 = love.graphics.newImage("/assets/red_idlewalk_1.png")
}
bum_frames[5] = {
    idle = love.graphics.newImage("/assets/idle_placeholder.png"),
    punch1 = love.graphics.newImage("/assets/readytopunch_placeholder.png"),
    punch2 = love.graphics.newImage("/assets/punch_placeholder.png"),
    block = love.graphics.newImage("/assets/block_placeholder.png"),
    hit = love.graphics.newImage("/assets/hit_placeholder.png"),
    knockover = love.graphics.newImage("/assets/knockover_placeholder.png"),
    down = love.graphics.newImage("/assets/down_placeholder.png"),
    
    uppercut1 = love.graphics.newImage("/assets/sit_placeholder.png"),
    uppercut2 = love.graphics.newImage("/assets/uppercut_placeholder.png"),
    kick2 = love.graphics.newImage("/assets/kick_placeholder.png"),
    elbow2 = love.graphics.newImage("/assets/elbowpunch_placeholder.png"),

    drive = {
        love.graphics.newImage("/assets/idle_walk1.png"),
        love.graphics.newImage("/assets/idle_walk2.png")
    }
    
    
}

joysticks = {}
for i,v in ipairs(love.joystick.getJoysticks()) do

    if (v:getName() ~= 'Bluetooth LE XINPUT compatible input device') then
        joysticks[#joysticks+1] = {
            available = true,
            instance = v,
            playerobj = false
        }
        print(v:getName())
    end
    

    print()
end

function love.load()
    world:add(picture_factory(0,0,"/assets/backdrop-src.png"))
    world:add(parallax_factory(0,103,"/assets/doroga-asset.png", 452, 90))
    world:add(parallax_factory(452,103,"/assets/doroga-asset.png", 452, 90))
end

function love.update(dt)
    if love.keyboard.isDown('q') then
        debug.debug()
    end
    gameTimer = gameTimer + dt
    for i,v in pairs(joysticks) do
        if v.available and v.instance:isGamepadDown("start") and gameTimer < 10 then
            v.available = false
            local np = player_factory(v,spawnpos,100)
            v.player = np
            world:add(np)
            print('foo)')
            sound_player_join:play()
            v.playerobj = np
            np.team = i
            np.frames = bum_frames[i]
            needRestart = true
        end

        if v.playerobj and v.playerobj.health < 1 then
            world:add(picture_factory(v.playerobj.x,v.playerobj.y,"/assets/tombstone.png",true))
        end

        if not v.available and (v.instance:isGamepadDown("back") or v.playerobj.health < 1 or v.playerobj.inactivity > 30)  then
            v.available = true
            world:del(v.player)
            v.playerobj = false
            sound_player_disconnect:play()
        end
    end
    world:update(dt)

    check_players_alive()
    if love.keyboard.isDown('5') then
        restartGame()
    end
end

function check_players_alive()
    local alivePlayers = 0
    for i,v in pairs(joysticks) do
        if not v.available then
            alivePlayers = alivePlayers + 1
        end
    end
    if alivePlayers == 0 then
        restartGame()
    end
end
function restartGame()
    for i,v in pairs(world.objects) do
        if v.is_enemy == true then
            world:del(v)
        end
    end
    gameTimer = 0
    if needRestart then
        for i,v in pairs(joysticks) do
            v.available = true
            if v.player then
                world:del(v.player)
            end
            v.playerobj = false
        end
        needRestart = true
    end
end

function love.draw()
    
    love.graphics.setCanvas(screenCanvas)
    local camsum = 0
    local camcount = 0
    
    -- for i,object in pairs(world.objects) do
    --     if object.isplayer then
    --         camcount = camcount + 1
    --         camsum = camsum + object.x
    --     else
    --     end
    -- end
    
    -- if camcount > 0 then
    --     camgoal = camsum / camcount - 160
    -- end
    -- if camgoal < -160 then
    --     camgoal = -160
    -- end
    -- if camgoal > 320 then
    --     camgoal = 320
    -- end

    spawnpos = camgoal + 160+love.math.random(100)-50
    -- camx = camx + (camgoal - camx) * 0.1
    love.graphics.clear()
    love.graphics.translate(math.floor(-camx),0)
    love.graphics.line(0,0,0,200)
    
    world:draw()
    
    love.graphics.setCanvas()
    love.graphics.translate(camx,0)
    love.graphics.draw(screenCanvas,0,0,0,4,4)
    for i, joystick in ipairs(joysticks) do
        local offset = (160*i)-80
        if not joystick.available then
            local str = string.format(
[[PLAYER %d
HEALTH: %d
SELECT TO LEAVE
]],i,joystick.playerobj.health)
            love.graphics.setColor(0,0,0,1)
            for xi=-5,5 do
                for yi=-5,5 do
                    love.graphics.print(str,offset+xi,50+yi)
                end
            end
            love.graphics.setColor(1,1,1,1)
            love.graphics.print(str,offset,50,0)
        else
            love.graphics.setColor(0,0,0,1)
            for xi=-5,5 do
                for yi=-5,5 do
                    love.graphics.print("PRESS START\nPLAYER " .. i,offset+xi,50+yi)
                end
            end
            love.graphics.setColor(1,1,1,1)
            love.graphics.print("PRESS START\nPLAYER " .. i,offset,50,0)
        end
    end
end