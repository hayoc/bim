using Revise

using Random
using Plots
using Printf

includet("exteroception.jl")
using .Exteroception
includet("proprioception.jl")
using .Proprioception
includet("model.jl")
using .PPModel


Random.seed!(420)
plotlyjs()


function run_experiment()
    map_size = 60
    steps = 500
    num_obstacles = 400
    start_pos = [map_size / 2, map_size / 2]
    v = 0.5 # velocity
    θ = 0 # rotation
    a = Dict(:pro_left=>[0.5, 0.5], :pro_right=>[0.5, 0.5]) # proprioception
    h = [[0.5, 0.5], [0.5, 0.5]] # hypotheses
    o = create_obstacles(map_size, num_obstacles)

    original_o = o
    path = Array{Float64}(undef, steps, 2)
    path[1, :] = start_pos
    thetas = Array{Float64}(undef, steps, 1)
    thetas[1] = θ
    
    for i = 2:steps
        @printf("------------------------%d------------------------\n", i)
        x, y = path[i-1, :]
        x, y, θ, a, h = step(x, y, θ, v, a, h, o, map_size)
        path[i, :] = [x, y]  
        thetas[i] = θ    
    end

    plot_results(path, original_o, thetas)
end

function step(x, y, θ, v, proprioception, hypotheses, obstacles, map_size)
    x_ = x + v * cos(θ)
    y_ = y + v * sin(θ)

    exteroception = get_sectors(obstacles, [x_, y_], v, θ, (map_size, map_size))

    hypotheses, action = predictive_processing(hypotheses, exteroception, proprioception)

    θ_ , proprioception = act(θ, action, proprioception)

    return x_, y_, θ_, proprioception, hypotheses
end

function create_obstacles(map_size::Int64, number_obstacles::Int64)
    obstacles = [rand(1:map_size, 2) for _ in 1:number_obstacles]
    return obstacles
end

function plot_results(path, obstacles, thetas)
    obstacles = reduce(hcat, obstacles)'
    plt = plot(obstacles[:, 1], obstacles[:, 2], seriestype=:scatter, markersize=2, legend=false)
    plt = plot(plt, path[:, 1], path[:, 2], linestyle=:solid, label=false)

    #plt = plot(plt, path[:, 1], path[:, 2], linestyle=:solid, markershape=:circle, markersize=2, label=false)

    # Plot edge lines
    # for i in eachindex(thetas)
    #     l_left = end_line(path[i, 1], path[i, 2], 2.0, thetas[i]-1.2)
    #     l_right = end_line(path[i, 1], path[i, 2], 2.0, thetas[i]+1.2)
    #     plot!(plt, [path[i, 1], l_left[1]], [path[i, 2], l_left[2]], color=:red)
    #     plot!(plt, [path[i, 1], l_right[1]], [path[i, 2], l_right[2]], color=:green)
    # end
    
    # Plot numbers onn path
    # for i in 1:1:size(path, 1)
    #     annotate!(path[i, 1], path[i, 2], text("$i", :left, 5))
    # end

    # Plot numbers on obstacles
    # for i in 1:1:size(obstacles, 1)
    #     annotate!(obstacles[i, 1], obstacles[i, 2], text("$i", :left, 5))
    # end

    display(plt)
end
