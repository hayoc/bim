using Revise

const experiments_dir = joinpath(@__DIR__, "experiments")

includet(joinpath(experiments_dir, "obstacle_avoidance", "agent.jl"))

run_experiment()
