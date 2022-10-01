return function (x,y,path,maydespawn)
    local new_picture = {}
    new_picture.timer = 0
    new_picture.maydespawn = maydespawn
    new_picture.drawable = love.graphics.newImage(path)
    new_picture.x = x
    new_picture.y = y

    function new_picture.draw(self)
        love.graphics.draw(self.drawable,self.x,self.y)
    end

    function new_picture.update(self,dt)
        self.timer = self.timer + dt
        if self.timer > 20 and self.maydespawn then
            world:del(self)
        end
    end

    return new_picture
end