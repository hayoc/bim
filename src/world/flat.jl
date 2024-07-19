module FlatWorld

export create_environment, plot_environment

using Plots

function create_environment(rows::Int, cols::Int, obstacles::Vector{Tuple{Int, Int}})
    grid = fill(0, rows, cols)
    
    for (x, y) in obstacles
        grid[x, y] = 1
    end
    
    return grid
end

function plot_environment(grid)
    println(grid)
    rows, cols = size(grid)
    
    plt = plot(xlim=(0, cols), ylim=(0, rows), legend=false, aspect_ratio=:equal, ticks=false)

    for x in 1:rows
        for y in 1:cols
            if grid[x, y] == 1
                scatter!(plt, [x], [y], color=:red, marker=:circle, markersize=2)
            end
        end
    end
    
    display(plt)
end

end # Module FlatWorld
