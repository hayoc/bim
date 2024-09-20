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



run()