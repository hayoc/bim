using Pkg

Pkg.activate(joinpath(@__DIR__, ".."))

include(joinpath(@__DIR__, "..", "src", "Bipom.jl"))

using .Bipom

PathIntegration.path_integration()