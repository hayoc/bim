module Plane

    export rect_collision

    function rect_collision(o, x, y)
        x_min, y_min = o .- 1
        x_max, y_max = o .+ 1
        return x_min <= x <= x_max && y_min <= y <= y_max
    end
end