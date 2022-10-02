return function (x,y,path,size, speed)
    local new_picture = {}
    new_picture.drawable = love.graphics.newImage(path)
    new_picture.x = x
    new_picture.y = y
    new_picture.size = size

    function new_picture.draw(self)
        love.graphics.draw(self.drawable,self.x,self.y)
        love.graphics.draw(self.drawable,self.x+self.size,self.y)
    end

    function new_picture.update(self,dt)
        self.x = self.x - (dt * speed)
        if self.x < (-self.size) then
            self.x = self.x + self.size
        end
    end

    return new_picture
end