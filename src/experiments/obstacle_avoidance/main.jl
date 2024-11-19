using Revise

using Random
using Plots
using Distributions
using Printf

includet("vision.jl")
includet("model.jl")
using .Vision
using .PPModel


#Random.seed!(421)


function run()
    #TODO: basically why peepo always turned in circles is because there is no "neutral" setting qua observation
    # If there is no obstacle in the vicinity, then still either left or right obs is activated
    # solution would be to introduce a third observation (exteroception) node, ext_null
    println("=============================================================")
    println("===========================START=============================")
    println("=============================================================")

    steps = 100
    v = 0.5 # velocity
    θ = 0 # rotation
    a = Dict(:pro_left=>[0.5, 0.5], :pro_right=>[0.5, 0.5]) # proprioception
    h = [[0.5, 0.5], [0.5, 0.5]] # hypotheses
    o = create_obstacles(60, 300)

    original_o = o
    path = Array{Float64}(undef, steps, 2)
    path[1, :] = [30, 30]
    
    for i = 2:steps
        @printf("------------------------%d------------------------\n", i)
        x, y = path[i-1, :]
        x, y, θ, a, h = step(x, y, θ, v, a, h, o)
        path[i, :] = [x, y]      
        #o = clear_obstacles(x, y, o) # Todo: add cleared obstacle to new list to track which ones were hit
    end

    return path, original_o
end

function step(x, y, θ, v, proprioception, hypotheses, obstacles)
    x_ = x + v * cos(θ)
    y_ = y + v * sin(θ)

    exteroception = get_sectors(obstacles, [x_, y_], v, θ)

    hypotheses, proprioception, action = predictive_processing(hypotheses, exteroception, proprioception)

    θ_ = act(θ, action)

    return x_, y_, θ_, proprioception, hypotheses
end

function act(θ, a)
    # TODO: maybe increase rotation based on prediction error size? This way we could more naturally
    # introduce random deviations during no turning behavior
    if haskey(a, :pro_left)
        println("ROTATO LEFT")
        return rotate(θ, rand(VonMises(findmax(a[:pro_left])[2] == 1 ? -0.5 : 0.5, 100.0)))
    elseif haskey(a, :pro_right)
        println("ROTATO RIGHT")
        return rotate(θ, rand(VonMises(findmax(a[:pro_right])[2] == 1 ? 0.5 : -0.5, 100.0)))
    else
        println("NO ROTATO")
        return rotate(θ, rand(VonMises(0.0, 1000.0)))
    end
end

function create_obstacles(map_size::Int64, number_obstacles::Int64)
    obstacles = [rand(1:map_size, 2) for _ in 1:number_obstacles]
    return obstacles
end

function rotate(θ, r)
    return (θ + r + π) % (2.0 * π) - π
end

function execute()
    path, obstacles = run()
    obstacles = reduce(hcat, obstacles)'
    plt = plot(obstacles[:, 1], obstacles[:, 2], seriestype=:scatter, markersize=2, legend=false)
    plt = plot(plt, path[:, 1], path[:, 2], label=false)
    display(plt)
end

execute()











# function create_agent(run_for::Int64, obstacles::Matrix{Int64})
#     v = 2 # velocity
#     θ = 0.0 # rotation
#     path = Array{Float64}(undef, run_for, 2)
#     e_lines = Array{Float64}(undef, run_for, 2)
    
#     for i = 2:run_for
#         path[i, :] = path[i-1, :] + ([cos(θ), sin(θ)] * v)
#         e_lines[i, :] = end_line(path[i-1, 1], path[i-1, 2], v*3, θ)
#         θ = rotate(θ, rand(VonMises(0.0, 100.0)))
#     end

#     return path, e_lines
# end
# function run2()
#     obstacles = create_obstacles(500, 50)
#     a_path, a_lines = create_agent(100, obstacles)
    
#     #plot(obstacles[:, 1], obstacles[:, 2], seriestype=:scatter, legend=false)
#     plt = plot(a_path[:, 1], a_path[:, 2], label=false)
#     for (p, l) in zip(eachrow(a_path), eachrow(a_lines))
#         x1, y1 = p
#         x2, y2 = l
#         plot!([x1, x2], [y1, y2], label=false)
#     end
#     display(plt)
# end

# function run1()
#     obstacle = [6.6, 5.4]
#     center = [5, 5]
#     v = 2 # velocity
#     θ = 0.0 # rotation

#     plt = plot([center[1]], [center[2]], seriestype=:scatter, legend=false, xlims=(0,10), ylims=(0,10))
#     plot!([obstacle[1]], [obstacle[2]], seriestype=:scatter, legend=false)
    
#     sectors = get_sectors([obstacle], center, v, θ)

#     print(sectors)
#     display(plt)
# end
