module Proprioception

export act

using Distributions

function act(θ, a, proprioception)
    # TODO: maybe increase rotation based on prediction error size? 
    # This way we could more naturally
    # introduce random deviations during no turning behavior

    #TODO: is it possible there's action updates for both left and right at the same time?
    # is so then need to fix this cause one will just override the other
    if haskey(a, :pro_left)
        if findmax(a[:pro_left])[2] == 1
            proprioception = Dict(:pro_left=>[0.9, 0.1], :pro_right=>[0.9, 0.1])
        else
            proprioception = Dict(:pro_left=>[0.1, 0.9], :pro_right=>[0.9, 0.1])
        end
    end

    if haskey(a, :pro_right)
        if findmax(a[:pro_right])[2] == 1
            proprioception = Dict(:pro_left=>[0.9, 0.1], :pro_right=>[0.9, 0.1])
        else
            proprioception = Dict(:pro_left=>[0.9, 0.1], :pro_right=>[0.1, 0.9])
        end
    end

    left_on = findmax(proprioception[:pro_left])[2] == 2
    right_on = findmax(proprioception[:pro_right])[2] == 2

    if  !left_on && !right_on
        return rotate(θ, rand(VonMises(0.0, 100.0))), proprioception
    elseif left_on
        return rotate(θ, rand(VonMises(-0.5, 100.0))), proprioception
    elseif right_on
        return rotate(θ, rand(VonMises(0.5, 100.0))), proprioception
    end
end

function rotate(θ, r)
    return (θ + r + π) % (2.0 * π) - π
end

end # module Proprioception