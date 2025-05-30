module Gifs

export plot_gif

using CairoMakie
using FileIO

function plot_gif(path, snapshots, thetas, homing_start)
    fig = Figure()
    ax = Axis(fig[1,1])

    hidedecorations!(ax)  
    hidespines!(ax)

    x_min, x_max = extrema(path[:, 1])
    y_min, y_max = extrema(path[:, 2])
    x_buffer = 0.1 * (x_max - x_min)
    y_buffer = 0.1 * (y_max - y_min)

    xlims!(ax, x_min - x_buffer, x_max + x_buffer)
    ylims!(ax, y_min - y_buffer, y_max + y_buffer)

    scatter!(ax, [path[homing_start, 1]], [path[homing_start, 2]];
            marker=:diamond, color=:orange, markersize=10)
    scatter!(ax, [path[1, 1]], [path[1, 2]];
            marker=:circle, color=:blue, markersize=10)

    outbound_segment = Observable(path[1:1, :])
    homing_segment = Observable(path[homing_start:homing_start, :])
  
    lines!(ax, outbound_segment, color=:blue, linewidth=1)
    lines!(ax, homing_segment, color=:orange, linewidth=1)

    ant_img = load("res/ant.png")
    ant_pos = Observable(reshape(path[1, :], 1, 2))  
    ant_angle = Observable(0.0) 
    scatter!(ax, ant_pos; marker=ant_img, markersize=20, rotation=ant_angle)  

    record(fig, "pi.gif", 1:25:size(path, 1)-1, framerate=10) do t
        if t <= homing_start
            outbound_segment[] = path[1:t, :]
        else
            outbound_segment[] = path[1:homing_start, :]
            homing_segment[] = path[homing_start-2:t, :]
        end        
        ant_pos[] = reshape(path[t, :], 1, 2) 
        ant_angle[] = -thetas[t]
    end
end

end # module Gifs