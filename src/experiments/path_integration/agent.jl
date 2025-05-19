using Plots
using Random
using Distributions
using DSP

include("../../utils/loggy.jl")
using .Loggy
includet("model.jl")
using .PPModel

default_acc = 0.15  
default_drag = 0.15
directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
dir_to_deg = Dict(d => (i - 1) * 45 for (i, d) in enumerate(directions))



function run_experiment() 
    Random.seed!(422)
    #plotlyjs()
    gr()

    vm = VonMises(0.0, 100.0)
    straight_vm = VonMises(0.0, 1000.0)
    left_vm = VonMises(deg2rad(-15.0), 100.0)
    right_vm = VonMises(deg2rad(15.0), 100.0)

    steps = 20000
    homing_start = div(steps, 3)
    path = zeros(steps, 2)
    
    ext = Dict() # exteroception
    
    walking_pro = Dict(:memory=>[0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125],) # proprioception
    walking_h = Dict(:compass=>[0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125],) # hypotheses

    homing_pro = Dict(:st_left=>[0.01, 0.99], :st_right=>[0.01, 0.99]) # proprioception
    homing_h = Dict(:compass=>[0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125],
                    :memory=>[0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125],) # hypotheses
    
    θ = 0.0 # heading
    v = [0.0, 0.0] # velocity x,y
    homing = false

    memory = Dict(d => 0.5 for d in directions)
    memory_halfway = nothing

    for i = 2:steps
        @debug print_loop(i)
        
        compass = [i == heading_to_index(θ) ? 1.0 : 0.0 for i in 1:8]

        walking_h[:compass] = compass
        _, a = predictive_processing(walking_h, ext, walking_pro, false)
        memory = act_walking(memory, a)

        if homing
            homing_h[:compass] = compass
            homing_h[:memory] = memory_to_prior(memory)
            _, a = predictive_processing(homing_h, ext, homing_pro, true)

            θ, v, path[i, :] = homing_walk(θ, v, path[i-1, :], a, left_vm, right_vm, straight_vm)
        else
            θ, v, path[i, :] = random_walk(θ, v, path[i-1, :], vm)
        end

        if homing == false && i > homing_start
            memory_halfway = copy(memory)
            homing = true
        end 
    end

    θ_hat = direction_to_heading(memory)
    dx, dy = sin(θ_hat), cos(θ_hat)

    plt_memory_1 = bar(directions, [memory_halfway[d] for d in directions], ylims=(0.0, 1.0),  label="memory", xlabel="direction", ylabel="memory (outbound)", title="", legend=false)
    plt_memory_2 = bar(directions, [memory[d] for d in directions], ylims=(0.0, 1.0), label="memory", xlabel="direction", ylabel="memory (homing)", title="", legend=false)
    hline!(plt_memory_1, [0.5], color=:red, linestyle=:dash, linewidth=2)
    hline!(plt_memory_2, [0.5], color=:red, linestyle=:dash, linewidth=2)

    anno_offset = 50.0
    plt_path = plot(path[1:homing_start, 1], path[1:homing_start, 2], color=:blue, label="Outbound", axis=([], false), legend=true)
    plot!(plt_path, path[homing_start:end, 1], path[homing_start:end, 2], color=:orange, label="Inbound")
    scatter!(plt_path, [path[1, 1]], [path[1, 2]], marker=(:circle, 4, :red), label=false)
    #annotate!(plt_path, path[1, 1] + anno_offset, path[1, 2] + anno_offset, text("nest", :red, :right, 8))  
    scatter!(plt_path, [path[homing_start, 1]], [path[homing_start, 2]], marker=(:diamond, 4, :purple), label=false)
    #annotate!(plt_path, path[homing_start, 1] + anno_offset, path[homing_start, 2] + anno_offset, text("food", :purple, :right, 8))

    #quiver!(plt_path, [path[end, 1]], [path[end, 2]], quiver=([dx*steps/50], [dy*steps/50]), arrow=:closed, color=:orange, linewidth=2)

    #plot(plt_path, plt_memory_1, plt_memory_2; layout = (1, 3), size=(1400, 800),)
    plot(plt_path)
end

function memory_to_prior(memory::Dict)
    values = [memory[d] for d in directions]
    one_hot = zeros(Float64, length(values))
    one_hot[argmax(values)] = 1.0
    return one_hot
end

function act_walking(memory, actions)
    a = actions[:memory]
    for (i, dir) in enumerate(directions)
        memory[dir] = memory[dir] + ((a[i] - 0.1) / 1000)
    end
    return memory
end

function heading_to_index(θ::Float64)
    deg = mod(rad2deg(θ), 360)
    index = Int(floor((deg + 22.5) / 45)) % 8 + 1
    return index
end

function direction_to_heading(memory::Dict)
    headings = Dict(
        "N"  => 0.0,
        "NE" => 45.0,
        "E"  => 90.0,
        "SE" => 135.0,
        "S"  => 180.0,
        "SW" => 225.0,
        "W"  => 270.0,
        "NW" => 315.0
    )
    max_dir = argmax(memory)
    return deg2rad(headings[max_dir])
end

function homing_walk(heading::Float64, velocity::Vector{Float64}, position::Vector{Float64}, actions::Dict, left_vm::VonMises, right_vm::VonMises, straight_vm::VonMises)      
    theta = heading
    
    if haskey(actions, :st_left)
        p = Categorical(actions[:st_left])
        if rand(p) - 1 == 1
            println("left")
            theta = rotate(heading, rand(left_vm))
        end
    elseif haskey(actions, :st_right)
        p = Categorical(actions[:st_right])
        if rand(p) - 1 == 1
            println("right")
            theta = rotate(heading, rand(right_vm))
        end
    else
        theta = rotate(heading, rand(straight_vm))
    end

    next_heading, next_velocity = next_movement_state(velocity, theta, default_acc, default_drag)
    return next_heading, next_velocity, position + next_velocity
end

function random_walk(heading::Float64, velocity::Vector{Float64}, position::Vector{Float64}, rotations::VonMises)
    theta = rotate(heading, rand(rotations))
    next_heading, next_velocity = next_movement_state(velocity, theta, default_acc, default_drag)
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