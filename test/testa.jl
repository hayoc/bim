using Distributions
using Random
using Plots


d = VonMises(0.0, 10000.0)


x = rand(d, 10000)


println(maximum(x))
println(minimum(x))
println("--------------")
histogram(x)
