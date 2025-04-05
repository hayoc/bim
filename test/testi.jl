using Plots
function V(x)
    return x^2
end    

function run()
    tx = -1:0.02:+1
    x = [-1. -1. -1.] #Starting positions
    δt = 0.05
    anim = Animation()
    tEnd = 2π; 
    t = 0; 
    vb = [-1,+1];

    while t < tEnd
        x[3] = 2x[2] - x[1] -x[2]*δt^2
        plot(tx,V.(tx),legend=:none)
        scatter!([x[2]] ,[V(x[2])],xlim=vb,ylim=vb,legend=:none,ticks=:false
            ,markersize=3,frame=:box,dpi=150,aspectratio=1,markerstrokecolor="blue",
            markercolor="blue")
        x[2],x[1] = x[3],x[2]
        t += δt
        frame(anim)
    end
    gif(anim)
end

run()
