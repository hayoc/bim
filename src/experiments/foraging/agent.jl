using Revise

using Random
using Plots
using LinearAlgebra
using Printf

includet("exteroception.jl")
using .Exteroception
includet("proprioception.jl")
using .Proprioception
includet("model.jl")
using .PPModel
includet("../../utils/plane.jl")
using .Plane





function run_experiment()
    Random.seed!(420)
    plotlyjs()

    map_size = 60
    steps = 100
    num_obstacles = 50
    start_pos = [map_size / 2, map_size / 2]
    v = 0.2 # velocity
    θ = 0 # rotation
    a = Dict(:pro_left=>[0.9, 0.1], :pro_right=>[0.9, 0.1]) # proprioception
    h = [[0.9, 0.1], [0.9, 0.1]] # hypotheses
    o = create_obstacles(map_size, num_obstacles)

    # todo julia prefer col vs rows 
    path = Array{Float64}(undef, steps, 2)
    path[1, :] = start_pos
    thetas = Array{Float64}(undef, steps, 1)
    thetas[1] = θ
    # todo: whole obstacles thing should be matrix
    o_history = []
    push!(o_history, o)
    for i = 2:steps
        @debug "------------------------$(i)------------------------"
        x, y = path[i-1, :]
        x, y, θ, a, h = step(x, y, θ, v, a, h, o, map_size)
        o = clear_obstacles(o, x, y)
        path[i, :] = [x, y]  
        thetas[i] = θ
        push!(o_history, o)
    end

    plot_results(path, o_history, thetas)
end

function step(x, y, θ, v, proprioception, hypotheses, obstacles, map_size)
    x_ = x + v * cos(θ)
    y_ = y + v * sin(θ)

    exteroception = get_sectors(obstacles, [x_, y_], v, θ, (map_size, map_size))

    hypotheses, action = predictive_processing(hypotheses, exteroception, proprioception)

    θ_ , proprioception = act(θ, action, proprioception)

    return x_, y_, θ_, proprioception, hypotheses
end

function clear_obstacles(obstacles, x, y)
    indices = [i for i in eachindex(obstacles) if rect_collision(obstacles[i], x, y)]
    return deleteat!(copy(obstacles), indices)
end

function create_obstacles(map_size::Int64, number_obstacles::Int64)
    obstacles = [rand(1:map_size, 2) for _ in 1:number_obstacles]
    return obstacles
end

function plot_debug(plt, path, o_history, thetas; plot_edges=true, plot_path_num=true, plot_obs_num=true)
    if plot_edges
        for i in eachindex(thetas)
            l_left = end_line(path[i, 1], path[i, 2], 2.0, thetas[i]-1.2)
            l_right = end_line(path[i, 1], path[i, 2], 2.0, thetas[i]+1.2)
            plot!(plt, [path[i, 1], l_left[1]], [path[i, 2], l_left[2]], color=:red)
            plot!(plt, [path[i, 1], l_right[1]], [path[i, 2], l_right[2]], color=:green)
        end
    end
    
    if plot_path_num
        for i in 1:1:size(path, 1)
            annotate!(plt, path[i, 1], path[i, 2], text("$i", :left, 5))
        end
    end

    if plot_obs_num
        obstacles = reduce(hcat, o_history[1])'
        for i in 1:1:size(obstacles, 1)
            annotate!(plt, obstacles[i, 1], obstacles[i, 2], text("$i", :left, 5))
        end
    end
end

function plot_gif(path, o_history)
    @time begin
        @gif for i in axes(path, 1)
            p = path[1:i, :]
            o = reduce(hcat, o_history[i])'
            plt = scatter(o[:, 1], o[:, 2], markersize=1, color=:blue, legend=false, axis=([], false))
            plt = scatter(plt, p[1:i, 1], p[1:i, 2], markersize=2, color=:red, legend=false)
        end every 10
    end
end

function plot_results(path, o_history, thetas)
    obstacles = reduce(hcat, o_history[1])'
    plt = plot(obstacles[:, 1], obstacles[:, 2], seriestype=:scatter, markersize=1, legend=false, axis=([], false))
    plt = plot(plt, path[:, 1], path[:, 2], linestyle=:solid, label=false)
    #plot_debug(plt, path, o_history, thetas, plot_edges=true, plot_path_num=true, plot_obs_num=true)
    display(plt)
    #plot_gif(path, o_history)
end
