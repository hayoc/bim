using Random
using Plots
using Distributions


function end_line(x, y, v, θ)
    x_ = x + v * cos(θ)
    y_ = y + v * sin(θ)
    return [x_, y_]
end

function point_in_triangle(px, py, x1, y1, x2, y2, x3, y3)
    denominator = (y2 - y3) * (x1 - x3) + (x3 - x2) * (y1 - y3)

    λ1 = ((y2 - y3)*(px - x3) + (x3 - x2)*(py - y3)) / denominator
    λ2 = ((y3 - y1)*(px - x3) + (x1 - x3)*(py - y3)) / denominator
    λ3 = 1 - λ1 - λ2

    return (0 <= λ1 <= 1) && (0 <= λ2 <= 1) && (0 <= λ3 <= 1)
end

function collision(p, t1, t2, t3)
    px, py = p
    x1, y1 = t1
    x2, y2 = t2
    x3, y3 = t3
    return point_in_triangle(px, py, x1, y1, x2, y2, x3, y3)
end

function run1()
    center = [5, 5]
    v = 2
    plot([center[1]], [center[2]], seriestype=:scatter, legend=false, xlims=(0,10), ylims=(0,10))

    rot = 0.0

    obstacle = [5.8,5.4]

    line_middle = end_line(center[1], center[2], v, rot)
    line_left = end_line(center[1], center[2], v, rot+1.2)
    line_right = end_line(center[1], center[2], v, rot-1.2)

    if collision(obstacle, center, line_left, line_middle)
        print("YES")

    else
        print("NO")

    end

    plot!([center[1], line_middle[1]], [center[2], line_middle[2]], legend=false)
    plot!([center[1], line_left[1]], [center[2], line_left[2]], legend=false)
    plot!([center[1], line_right[1]], [center[2], line_right[2]], legend=false)

    plot!([line_middle[1]], [line_middle[2]], seriestype=:scatter, legend=false)
    plot!([line_left[1]], [line_left[2]], seriestype=:scatter, legend=false)

    plot!([obstacle[1]], [obstacle[2]], seriestype=:scatter, legend=false)

end

function run()
    center = [5, 5]
    v = 2
    rot = 0.0

    plot([center[1]], [center[2]], seriestype=:scatter, legend=false, xlims=(0,10), ylims=(0,10))

    line_middle = end_line(center[1], center[2], v, rot)
    # line_left = end_line(center[1], center[2], v, rot+1.2)

    # lines = [line_middle, line_left]
    # println(lines)
    # for i in eachindex(lines)
    #     println(lines[i])
    # end
    lines = Array{Float64}(undef, 7, 2)
    for i = 1:size(lines, 1)
        lines[i, :] = end_line(center[1], center[2], v, rot) 
    end
    println(lines)

end

run()