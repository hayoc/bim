using Revise

includet("utils/loggy.jl")
using .Loggy


experiments = [
    "foraging",
    "obstacle_avoidance",
]
experiment = length(ARGS) > 0 ? ARGS[1] : experiments[1]
experiments_dir = joinpath(@__DIR__, "experiments")
includet(joinpath(experiments_dir, experiment, "agent.jl"))


function main()
    init_loggy()
    run_experiment()
end

main()

