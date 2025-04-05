module Exteroception

using Random
using Plots
using Printf

export get_sectors, end_line

function get_sectors(obstacles, center, v, θ, boundaries)
    sectors = fill(false, 6)

    min_distance = 10000000000
    closest_distance = 10000000000
    closest_obstacle = nothing

    lines = Array{Float64}(undef, 7, 2)
    for i = 1:size(lines, 1)
        lines[i, :] = end_line(center[1], center[2], v * 5, θ + (1.2 - (i-1) * 0.4))
    end

    for o in obstacles
        col_left = collision(o, center, lines[1, :], lines[4, :])
        col_right = collision(o, center, lines[4, :], lines[7, :])
        if col_left || col_right
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
    bnd = find_boundaries(lines, boundaries)

    # to handle boundaries properly:
    # right now when outside boundary it will always only see one side
    # e.g. bound left bc that's the first one handled
    # instead should do something like whichever side is closest to the boundary
    # that side should move
    if bnd[1] == 1
        if bnd[2] == 0
            return Dict(:ext_left=>[0.1, 0.9], :ext_right=>[0.9, 0.1])
        else
            return Dict(:ext_left=>[0.9, 0.1], :ext_right=>[0.1, 0.9])
        end
    else
        if isnothing(active_sector)
            return Dict(:ext_left=>[0.9, 0.1], :ext_right=>[0.9, 0.1])
        elseif active_sector < 4
            return Dict(:ext_left=>[0.1, 0.9], :ext_right=>[0.9, 0.1])
        elseif active_sector >= 4
            return Dict(:ext_left=>[0.9, 0.1], :ext_right=>[0.1, 0.9])
        end
    end
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

function find_boundaries(lines, boundaries)
    if crossed(lines[1, :], boundaries) || crossed(lines[2, :], boundaries) || crossed(lines[3,  :], boundaries)
        return (1, 0)
    elseif crossed(lines[5, :], boundaries) || crossed(lines[6, :], boundaries) || crossed(lines[7,  :], boundaries)
        return (1, 1)
    elseif crossed(lines[4, :], boundaries)
        return (1, rand(0:1))
    else
        return (0, 0)
    end
end

function crossed(line, boundaries)
    if line[1] < 0 || line[1] > boundaries[1] || line[2] < 0 || line[2] > boundaries[2]
        return true
    end
    return false
end

end # module Exteroception