using Plots
using Random
using Distributions
using DSP

includet("../../utils/loggy.jl")
using .Loggy
includet("model.jl")
using .PPModel

default_acc = 0.15  
default_drag = 0.15
directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
dir_to_deg = Dict(d => (i - 1) * 45 for (i, d) in enumerate(directions))

turn_speed = 10.0
left_turn = deg2rad(-turn_speed)
right_turn = deg2rad(turn_speed)
rand_walk_vm = VonMises(0.0, 100.0)
straight_vm = VonMises(0.0, 1000.0) 
left_vm = VonMises(deg2rad(-turn_speed), 100.0)
right_vm = VonMises(deg2rad(turn_speed), 100.0)

# TODO: have probabilities of turning depend on memory (how obvious a certain direction is)
# as memory becomes more equalized, probabilities of turning decrease

# TODO: maybe dont execute homing every step, sometimes let him walk straight to give memory a chance to update

function run_experiment() 
    #Random.seed!(422)
    plotlyjs()
    #gr()

    noisy = true
    steps = 2000
    snapshot_every = 100
    homing_start = div(steps, 2)

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

    thetas = []

    memory = Dict(d => 0.5 for d in directions)
    snapshots = Vector{Tuple{Int, Dict{String, Float64}}}()

    for i = 2:steps
        @debug string("-- ", i, " --", rad2deg(θ))
        
        compass = [i == heading_to_index(θ) ? 1.0 : 0.0 for i in 1:8]
        walking_h[:compass] = compass

        if homing
            homing_h[:compass] = compass
            homing_h[:memory] = memory_to_prior(memory)
            _, a = predictive_processing(homing_h, ext, homing_pro, true)

            θ, v, path[i, :] = homing_walk(θ, v, path[i-1, :], a, noisy)
            push!(thetas, θ)
        else
            θ, v, path[i, :] = random_walk(θ, v, path[i-1, :])
            push!(thetas, θ)
        end

        _, a = predictive_processing(walking_h, ext, walking_pro, false)
        memory = act_walking(memory, a)

        if homing == false && i > homing_start
            homing = true
        end 

        if i % snapshot_every == 0
            push!(snapshots, (i, copy(memory))) 
        end
    end

    mem_plots = []
    for (step, snapshot) in snapshots[end-5:end]
        mem_plot = bar(
            directions, [snapshot[d] for d in directions], 
            label="memory at $step", 
            xlabel="step $step", ylabel="", title="", 
            xticks=(0.5:1:7.5, ["N", "", "E", "", "S", "", "W", ""]),
            guidefont=font(8), 
            tickfont=font(6), 
            legend=false, 
            size=(200, 200)
        )
        hline!(mem_plot, [0.5], color=:red, linestyle=:dash, linewidth=2)
        push!(mem_plots, mem_plot)
    end 

    path_plot = plot(path[1:homing_start, 1], path[1:homing_start, 2], color=:blue, label="Outbound", legend=true, axis=([], false))
    plot!(path_plot, path[homing_start:end, 1], path[homing_start:end, 2], color=:orange, label="Inbound")

    scatter!(path_plot, [path[1, 1]], [path[1, 2]], marker=(:circle, 4, :red), label=false)
    scatter!(path_plot, [path[homing_start, 1]], [path[homing_start, 2]], marker=(:diamond, 4, :purple), label=false)

    # for i in 1:snapshot_every:steps
    #     annotate!(path_plot, path[i, 1], path[i, 2], text(string(i-1), :black, 8))
    # end

    # θ_hat = direction_to_heading(memory)
    # dx, dy = sin(θ_hat), cos(θ_hat)
    #annotate!(path_plot, path[1, 1] + anno_offset, path[1, 2] + anno_offset, text("nest", :red, :right, 8))  
    #annotate!(path_plot, path[homing_start, 1] + anno_offset, path[homing_start, 2] + anno_offset, text("food", :purple, :right, 8))
    #quiver!(path_plot, [path[end, 1]], [path[end, 2]], quiver=([dx*steps/50], [dy*steps/50]), arrow=:closed, color=:orange, linewidth=2)

    layout = @layout [a{0.9w, 0.7h}; grid(1, length(mem_plots))]
    #plot(path_plot, mem_plots...; layout=layout, size=(1000, 500))
    plot(path_plot)
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
        memory[dir] = memory[dir] + ((a[i] - 0.05) / 100)
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

function homing_walk(theta::Float64, velocity::Vector{Float64}, position::Vector{Float64}, actions::Dict, noisy::Bool = true)      
    if haskey(actions, :st_left)
        p = Categorical(actions[:st_left])
        if rand(p) - 1 == 0
            theta = turn_left(theta, noisy)
        end
    end

    if haskey(actions, :st_right)
        p = Categorical(actions[:st_right])
        if rand(p) - 1 == 0
            theta = turn_right(theta, noisy)
        end
    end

    if !haskey(actions, :st_left) && !haskey(actions, :st_right)
        theta = walk_straight(theta, noisy)
    end

    next_heading, next_velocity = next_movement_state(velocity, theta, default_acc, default_drag)
    return next_heading, next_velocity, position + next_velocity
end

function turn_left(theta::Float64, noisy::Bool)
    return noisy ? rotate(theta, rand(left_vm)) : rotate(theta, left_turn)
end

function turn_right(theta::Float64, noisy::Bool)
    return noisy ? rotate(theta, rand(right_vm)) : rotate(theta, right_turn)
end

function walk_straight(theta::Float64, noisy::Bool)
    return noisy ? rotate(theta, rand(straight_vm)) : theta
end

function random_walk(heading::Float64, velocity::Vector{Float64}, position::Vector{Float64})
    theta = rotate(heading, rand(rand_walk_vm))
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
