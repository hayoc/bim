using Pkg

Pkg.activate(joinpath(@__DIR__, ".."))

includet(joinpath(@__DIR__, "..", "src", "Bipom.jl"))

using .Bipom

PathIntegration.path_integration()