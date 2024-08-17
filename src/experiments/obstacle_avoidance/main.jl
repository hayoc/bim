using Random
using Plots

function create_agent(run_for::Int64, obstacles::Matrix{Int64})
    velocity = 2
    theta = 0.0
    path = Array{Float64}(undef, run_for, 2)
    
    for i = 2:run_for
        path[i, :] = path[i-1, :] + ([cos(theta), sin(theta)] * velocity)
        theta = rotate(theta, rand(VonMises(0.0, 100.0)))
    end

    return path
end

function create_obstacles(map_size::Int64, number_obstacles::Int64)
    obstacles = rand(1:map_size, (number_obstacles, 2))
    return obstacles
end

function rotate(theta, r)
    return (theta + r + π) % (2.0 * π) - π
end

function run()
    obstacles = create_obstacles(500, 50)
    agent = create_agent(1000, obstacles)
    
    plot(obstacles[:, 1], obstacles[:, 2], seriestype=:scatter, legend=false)
    plot!(agent[:, 1], agent[:, 2])
end

run()