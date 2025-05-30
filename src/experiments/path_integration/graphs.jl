module Graphs

export plot_graph

using Plots

function plot_static(path, snapshots, homing_start)
    plotlyjs()

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

    #annotate!(path_plot, path[1, 1] + anno_offset, path[1, 2] + anno_offset, text("nest", :red, :right, 8))  
    #annotate!(path_plot, path[homing_start, 1] + anno_offset, path[homing_start, 2] + anno_offset, text("food", :purple, :right, 8))

    layout = @layout [a{0.9w, 0.7h}; grid(1, length(mem_plots))]
    #plot(path_plot, mem_plots...; layout=layout, size=(1000, 500))
    plot(path_plot)
end

end # module Graphs