module Agent

export plot_agent, generate_outbound_path, walk

using Plots
using Distributions
using DSP


default_acc = 0.15  
default_drag = 0.15


function walk(heading::Float64, velocity::Vector{Float64}, position::Vector{Float64}, rotations::VonMises)
    next_heading, next_velocity = next_movement_state(heading, velocity, rand(rotations), default_acc, default_drag)

    return next_heading, next_velocity, position + next_velocity
end

function generate_outbound_path(steps)
    mu = 0.0
    kappa = 100.0

    rotation = rand(VonMises(mu, kappa), steps)

    acceleration = default_acc * ones(steps)
    
    headings = zeros(steps)
    velocity = zeros(steps, 2)

    for s in 2:steps
        headings[s], velocity[s, :] = next_movement_state(headings[s-1], velocity[s-1, :], rotation[s], acceleration[s], default_drag)
    end

    return cumsum(velocity, dims=1)
end

function plot_agent(plt, path)
    x = path[:, 1]
    y = path[:, 2]

    plot!(plt, x, y, color=:blue)
end

function rotate(theta, r)
    return (theta + r + π) % (2.0 * π) - π
end

function thrust(theta, acceleration)
    return [sin(theta), cos(theta)] * acceleration
end

function next_movement_state(heading, velocity, rotation, acceleration, drag)
    theta = rotate(heading, rotation)
    v = velocity + thrust(theta, acceleration)
    v -= drag * v
    return theta, v
end

end # Module Agent