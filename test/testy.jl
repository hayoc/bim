using Plots


default_acc = 0.15  
default_drag = 0.15

function walk(heading::Float64, velocity::Vector{Float64}, position::Vector{Float64})
    next_heading, next_velocity = next_movement_state(velocity, heading, default_acc, default_drag)
    return next_heading, next_velocity, position + next_velocity
end

function next_movement_state(velocity, theta, acceleration, drag)
    v = velocity + thrust(theta, acceleration)
    v -= drag * v
    return theta, v
end

function rotate(theta, r)
    return (theta + r + π) % (2.0 * π) - π
end

function thrust(theta, acceleration)
    return [sin(theta), cos(theta)] * acceleration
end

function run()
    steps = 5
    heading = 0.0
    path = zeros(steps, 2)
    velocity = [0.0, 0.0]
    for i in 2:steps
        heading = rotate(heading, deg2rad(90.0))  
        heading, velocity, position = walk(heading, [0.0, 0.0], path[i-1, :])
        path[i, :] = position
    end

    println("Path: ", path)

    plot(path[:, 1], path[:, 2], color=:blue, label="Outbound", legend=false)
end

run()




