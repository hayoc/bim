using Pkg

Pkg.activate(joinpath(@__DIR__, ".."))

includet(joinpath(@__DIR__, "..", "src", "Bim.jl"))

using .Bim

PathIntegration.path_integration()