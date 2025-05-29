module PPModel

export predictive_processing

using Revise

using RxInfer
using Distances


include("../../utils/loggy.jl")
using .Loggy


directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]

function predictive_processing(hypotheses, exteroception, proprioception, homing)
    if homing
        @debug "Hypotheses: compass => $(print_vec(hypotheses[:compass])), memory => $(print_vec(hypotheses[:memory]))"

        initialization = @initialization begin
            μ(compass) = Categorical(fill(1/8, 8))
            μ(memory) = Categorical(fill(1/8, 8))
        end

        result = infer(
            model = model_homing(h = hypotheses), 
            data = (st_left = UnfactorizedData(missing), st_right = UnfactorizedData(missing)),
            initialization = initialization,
        )
    else
        @debug "Hypotheses: compass => $(print_vec(hypotheses[:compass]))"

        result = infer(
            model = model_walking(h = hypotheses), 
            data = (memory = UnfactorizedData(missing),),
        )
    end

    predictions = [(k, v.p) for (k, v) in result.predictions]

    error_names = []
    errors = []
    preds = []

    for (key, prediction) in predictions
        observation = observe(key, exteroception, proprioception)
        error = observation - prediction
        err_size = kl_divergence(observation, prediction)
        
        @debug "Node $(key) - prediction: $(print_vec(prediction)) vs observation: $(print_vec(observation)) with error: $(round(err_size, digits=3))"

        if err_size > 0.05
            push!(errors, error)
            push!(error_names, key)
            push!(preds, prediction)
        end
    end

    action = Dict()

    for i in eachindex(error_names)
        name = error_names[i]
        p = preds[i]

        if haskey(proprioception, name)
            action[name] = p
            @debug "Action update: $(name) ===> $(print_vec(p))"
        elseif haskey(exteroception, name)
            throw(error("Exteroception nodes not implemented in this model!"))
        end
    end
    
    return hypotheses, action
end

function observe(name, ext, pro) 
    if haskey(ext, name)
        return ext[name]
    elseif haskey(pro, name)
        return pro[name]
    else
        throw(error("Observations do not contain key. This should not happen!"))
    end
end

@model function model_walking(h, memory)
    memory_cpt = gen_memory_cpt()

    compass ~ Categorical(h[:compass])

    memory ~ DiscreteTransition(compass, memory_cpt)
end

@model function model_homing(h, st_left, st_right)
    st_left_cpt = gen_steering_cpt("LEFT")
    st_right_cpt = gen_steering_cpt("RIGHT")

    compass ~ Categorical(h[:compass])
    memory ~ Categorical(h[:memory])

    st_left ~ DiscreteTransition(compass, st_left_cpt, memory)
    st_right ~ DiscreteTransition(compass, st_right_cpt, memory)
end

function gen_memory_cpt()
    cpt = zeros(8, 8)

    pattern = [0.001, 0.001, 0.001, 0.3, 0.3, 0.3, 0.001, 0.001]
    pattern = pattern ./ sum(pattern)

    for i in 1:8
        cpt[i, :] = circshift(pattern, i - 1)
    end

    return cpt
end

function gen_steering_cpt(node::String)
    cpt = zeros(2, 8, 8)  # [true/false, compass_idx, memory_idx]
   
    for (compass_idx, _) in enumerate(directions)
        for (memory_idx, _) in enumerate(directions)
            offset = mod(memory_idx - compass_idx, 8)
            if node == "RIGHT"
                if offset == 4
                    true_val = 0.5
                elseif offset in (1, 2, 3)
                    true_val = 0.99
                else
                    true_val = 0.01
                end
            elseif node == "LEFT"
                if offset == 4
                    true_val = 0.5
                elseif offset in (5, 6, 7)
                    true_val = 0.99
                else
                    true_val = 0.01
                end
            end

            cpt[1, compass_idx, memory_idx] = true_val  
            cpt[2, compass_idx, memory_idx] = 1.0 - true_val 
        end
    end

    return cpt
end

end # module PPModel