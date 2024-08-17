module PathIntegration

export path_integration

using Revise
using RxInfer
using Plots
using Random

include("agent.jl")
using .Agent



Random.seed!(42069999)


function path_integration() 
    # rows, cols = 1000, 1000
    # num_obstacles = 50

    # obstacles = create_environment(rows, cols, num_obstacles)
    # plt = plot_environment(rows, cols, obstacles)

    steps = 5000

    #path = generate_outbound_path(steps)
    path = generate_outbound_path_steps(steps)
    
    plot(path[:, 1], path[:, 2])
end

function generate_outbound_path_steps(steps) 
    mu = 0.0
    kappa = 100.0

    vm = VonMises(mu, kappa)

    path = zeros(steps, 2)
    heading = 0.0
    velocity = [0.0, 0.0]
    position = [0.0, 0.0]

    for i = 1:steps
        heading, velocity, position = walk(heading, velocity, position, vm)
        path[i, :] = position
    end

    return path
end


end # Module PathIntegration

PathIntegration.path_integration()