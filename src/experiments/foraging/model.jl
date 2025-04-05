module PPModel

export predictive_processing

using Revise

using RxInfer
using Distances


include("../../utils/loggy.jl")
using .Loggy


function predictive_processing(hypotheses, exteroception, proprioception)
    # 1. prediction
    # 2. prediction error
    # 3. prediction error minimization

    result = infer(model = pp_model(hypos = hypotheses), 
                    data = (ext_left = missing, ext_right = missing,
                            pro_left = missing, pro_right = missing))
    predictions = sort([(k, v.p) for (k, v) in result.predictions], by = x -> x[1], rev = true)

    error_names = []
    errors = []
    preds = []

    @debug "Hypotheses: $(print_vec(hypotheses[1])), $(print_vec(hypotheses[2]))"

    for (key, prediction) in predictions
        observation = observe(key, exteroception, proprioception)
        error = observation - prediction
        error_size = kl_divergence(observation, prediction)
        
        @debug "Node $(key) - prediction: $(print_vec(prediction)) vs observation: $(print_vec(observation)) with error: $(round(error_size, digits=3))"

        if error_size > 0.05
            push!(errors, error)
            push!(error_names, key)
            push!(preds, prediction)
        end
    end

    action = Dict()

    for i in eachindex(error_names)
        name = error_names[i]
        e = errors[i]
        p = preds[i]

        if haskey(exteroception, name)
            result = infer(model = pp_model(hypos = hypotheses), 
            data = (ext_left = name == :ext_left ? p + e : missing, 
                    ext_right = name == :ext_right ? p + e : missing,
                    pro_left = name == :pro_left ? p + e : missing, 
                    pro_right = name == :pro_right ? p + e : missing))
            hypotheses = [h.p for h in values(result.posteriors)]
            old_hypos = hypotheses
            @debug "Hypo update: $(print_vec(old_hypos[1])), $(print_vec(old_hypos[2])) ===> $(print_vec(hypotheses[1])), $(print_vec(hypotheses[2]))"
        elseif haskey(proprioception, name)
            proprioception[name] = p
            action[name] = p
            @debug "Action update: $(name) ===> $(print_vec(p))"
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

@model function pp_model(hypos, ext_left, ext_right, pro_left, pro_right)
    h_left ~ Categorical(hypos[1])
    h_right ~ Categorical(hypos[2])

    P_cpt = [0.9 0.1; 
             0.1 0.9] 
    E_cpt = [0.9 0.1; 
             0.1 0.9] 

    ext_left ~ DiscreteTransition(h_left, E_cpt)
    ext_right ~ DiscreteTransition(h_right, E_cpt)
    pro_left ~ DiscreteTransition(h_right, P_cpt)
    pro_right ~ DiscreteTransition(h_left, P_cpt)
end

end # module PPModel