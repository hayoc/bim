using Random
using Plots
using Distributions

RADIUS = 3
Random.seed!(420)

function create_agent(run_for::Int64, obstacles::Matrix{Int64})
    v = 2 # velocity
    θ = 0.0 # rotation
    path = Array{Float64}(undef, run_for, 2)
    e_lines = Array{Float64}(undef, run_for, 2)
    
    for i = 2:run_for
        path[i, :] = path[i-1, :] + ([cos(θ), sin(θ)] * v)
        e_lines[i, :] = end_line(path[i-1, 1], path[i-1, 2], v*3, θ)
        θ = rotate(θ, rand(VonMises(0.0, 100.0)))
    end

    return path, e_lines
end

function create_obstacles(map_size::Int64, number_obstacles::Int64)
    obstacles = rand(1:map_size, (number_obstacles, 2))
    return obstacles
end

function rotate(θ, r)
    return (θ + r + π) % (2.0 * π) - π
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

function vision(obstacles, center, v, θ)
    sectors = fill(false, 6)

    min_distance = 10000000000
    closest_distance = 10000000000
    closest_obstacle = nothing
    
    lines = Array{Float64}(undef, 7, 2)
    for i = 1:size(lines, 1)
        lines[i, :] = end_line(center[1], center[2], v, θ + (1.2 - (i-1) * 0.4))
        plot!([center[1], lines[i, 1]], [center[2], lines[i, 2]], legend=false)
    end

    for o in obstacles
        if collision(o, center, lines[1, :], lines[4, :]) || collision(o, center, lines[4, :], lines[7, :])
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

    return sectors
end

function run()
    obstacles = create_obstacles(500, 50)
    a_path, a_lines = create_agent(100, obstacles)
    
    #plot(obstacles[:, 1], obstacles[:, 2], seriestype=:scatter, legend=false)
    plt = plot(a_path[:, 1], a_path[:, 2], label=false)
    for (p, l) in zip(eachrow(a_path), eachrow(a_lines))
        x1, y1 = p
        x2, y2 = l
        plot!([x1, x2], [y1, y2], label=false)
    end
    display(plt)
end

function run1()
    obstacle = [6.6, 5.4]
    center = [5, 5]
    v = 2 # velocity
    θ = 0.0 # rotation

    plt = plot([center[1]], [center[2]], seriestype=:scatter, legend=false, xlims=(0,10), ylims=(0,10))
    plot!([obstacle[1]], [obstacle[2]], seriestype=:scatter, legend=false)
    
    sectors = vision([obstacle], center, v, θ)

    print(sectors)
    display(plt)
end



run1()