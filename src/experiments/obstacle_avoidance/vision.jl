module Vision


export get_sectors, clear_obstacles

function clear_obstacles(x, y, obstacles)
    collision_radius = 2

    function is_collision(x, y, a, b, radius)
        return sqrt((x - a)^2 + (y - b)^2) <= radius
    end

    filtered_obstacles = filter(o -> !is_collision(o[1], o[2], x, y, collision_radius), obstacles)

    return filtered_obstacles
end

function end_line(x, y, v, θ)
    x_ = x + v * cos(θ)
    y_ = y + v * sin(θ)
    return [x_, y_]
end

function point_in_triangle(px, py, x1, y1, x2, y2, x3, y3)
    denominator = (y2 - y3) * (x1 - x3) + (x3 - x2) * (y1 - y3)

    λ1 = ((y2 - y3)*(px - x3) + (x3 - x2)*(py - y3)) / denominator
    λ2 = ((y3 - y1)*(px - x3) + (x1 - x3)*(py - y3)) / denominator
    λ3 = 1 - λ1 - λ2

    return (0 <= λ1 <= 1) && (0 <= λ2 <= 1) && (0 <= λ3 <= 1)
end

function collision(p, t1, t2, t3)
    px, py = p
    x1, y1 = t1
    x2, y2 = t2
    x3, y3 = t3
    return point_in_triangle(px, py, x1, y1, x2, y2, x3, y3)
end

function get_sectors(obstacles, center, v, θ)
    sectors = fill(false, 6)

    min_distance = 10000000000
    closest_distance = 10000000000
    closest_obstacle = nothing
    
    lines = Array{Float64}(undef, 7, 2)
    for i = 1:size(lines, 1)
        lines[i, :] = end_line(center[1], center[2], v * 5, θ + (1.2 - (i-1) * 0.4))
        # plot!([center[1], lines[i, 1]], [center[2], lines[i, 2]], legend=false)
    end

    for o in obstacles
        if collision(o, center, lines[1, :], lines[4, :]) || collision(o, center, lines[4, :], lines[7, :])
            println("DEF A COLLISION")
            d = hypot(o[1] - center[1], o[2] - center[2])
            if d <= min_distance && d < closest_distance
                closest_distance = d
                closest_obstacle = o
            end
        end
    end

    if !isnothing(closest_obstacle)
        for i in 1:size(lines, 1) - 1
            sectors[i] = collision(closest_obstacle, center, lines[i, :], lines[i + 1, :])
        end
    end

    active_sector = findfirst(==(1), sectors)
    if isnothing(active_sector)
        return Dict(:ext_left=>[0.5, 0.5], :ext_right=>[0.5, 0.5])
    elseif active_sector <= 3
        println("collision left")
        return Dict(:ext_left=>[0.9, 0.1], :ext_right=>[0.1, 0.9])
    else
        println("collision right")
        return Dict(:ext_left=>[0.1, 0.9], :ext_right=>[0.9, 0.1])
    end
end

end