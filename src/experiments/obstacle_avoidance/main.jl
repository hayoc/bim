using Random
using Plots
using Distributions

include("vision.jl")
include("model.jl")
using .Vision
using .PPModel


RADIUS = 3
VELOCITY = 2

Random.seed!(420)


function step(x, y, θ, obstacles)
    x_ = VELOCITY * cos(θ)
    y_ = VELOCITY * sin(θ)

    exteroception = get_sectors(obstacles, [x, y], VELOCITY, θ)
    proprioception = [0, 0]

    action = predictive_processing(exteroception, proprioception)

end

function motor(θ, m)
    if m == "LEFT"
        return rotate(θ, rand(VonMises(-0.5, 100.0))), [1, 0]
    else
        return rotate(θ, rand(VonMises(0.5, 100.0))), [0, 1]
    end
end

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
    
    sectors = get_sectors([obstacle], center, v, θ)

    print(sectors)
    display(plt)
end



run1()