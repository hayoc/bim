using Random
using CairoMakie
using FileIO

n_steps = 100
step_size = 0.1  

path = zeros(Float64, n_steps, 2)

for i in 2:n_steps
    step = randn(2) .* step_size  
    path[i, :] = path[i-1, :] .+ step
end

fig = Figure()
ax = Axis(fig[1,1])
xlims!(ax, extrema(path[:, 1])...)
ylims!(ax, extrema(path[:, 2])...)

segment = Observable(path[1:1, :])
lines!(ax, segment)  

ant_img = load("res/ant.png")
ant_pos = Observable(reshape(path[1, :], 1, 2))  # Initial position of the ant
ant_angle = Observable(0.0) 
scatter!(ax, ant_pos; marker=ant_img, markersize=20, rotation=ant_angle)  


record(fig, "animation.gif", 2:n_steps, framerate=10) do t
    segment[] = path[1:t, :]  
    ant_pos[] = reshape(path[t, :], 1, 2) 
    dir = path[t, :] .- path[t-1, :]
    ant_angle[] = atan(dir[2], dir[1])
end