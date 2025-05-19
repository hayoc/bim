using Plots
#gr()  # Ensure you're using the GR backend

function draw_arrow(heading_deg::Float64)
    θ = deg2rad(heading_deg)
    dx, dy = sin(θ), cos(θ)

    plot(xlim=(0, 20), ylim=(0, 20), aspect_ratio=1, legend=false)
    quiver!([10.0], [10.0], quiver=([dx * 3], [dy * 3]), arrow=:closed, color=:blue)
end

draw_arrow(135.)  # SE