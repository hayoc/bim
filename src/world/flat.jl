module FlatWorld

export create_environment, plot_environment

using Plots

function create_environment(rows::Int, cols::Int, num_obstacles::Int)
    obstacles = Array{Tuple{Float64, Float64}}(undef, num_obstacles)
    for i in 1:num_obstacles
        obs = (rand(-(rows/2):rows/2), rand(-(cols/2):cols/2))
        obstacles[i] = obs
    end
    
    return obstacles
end

function plot_environment(rows::Int, cols::Int, obstacles::Array{Tuple{Float64, Float64}})
    plt = plot(xlim=(-(cols/2), cols/2), ylim=(-(rows/2), rows/2), legend=false, aspect_ratio=:equal, ticks=false)
    scatter!(plt, obstacles, color=:red, marker=:circle, markersize=2)

    return plt
end

end # Module FlatWorld
