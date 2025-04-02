module PPModel

export predictive_processing

using Revise

using RxInfer
using Distances
using Printf


include("../../utils/prettyprint.jl")
using .PrettyPrint


function predictive_processing(hypotheses, exteroception, proprioception)
    # 1. prediction
    # 2. prediction error
    # 3. prediction error minimization

    result = infer(model = pp_model(hypos = hypotheses), 
                    data = (ext_left = missing, ext_right = missing,
                            pro_left = missing, pro_right = missing))
    predictions = sort([(k, v.p) for (k, v) in result.predictions], by = x -> x[1], rev = true)

    m_error_size = 0.
    m_error_name = ""
    m_error = [0., 0.]
    m_prediction = [0., 0.]

    @printf("Hypotheses: %s, %s\n", 
            "["*join(round.(hypotheses[1], sigdigits=3),",")*"]", 
            "["*join(round.(hypotheses[2], sigdigits=3),",")*"]")

    for (key, prediction) in predictions
        observation = observe(key, exteroception, proprioception)
        error = observation - prediction
        error_size = kl_divergence(observation, prediction)
        
        @printf("Node %s - prediction: %s vs observation: %s with error: %.3f\n", 
                key, 
                "["*join(round.(prediction, sigdigits=3),",")*"]", 
                "["*join(round.(observation, sigdigits=3),",")*"]",
                error_size)

        if error_size >= m_error_size
            m_error_size = error_size
            m_error_name = key
            m_error = error
            m_prediction = prediction
        end
    end

    action = Dict()
    
    if m_error_size > 0.05
        if haskey(exteroception, m_error_name)
            result = infer(model = pp_model(hypos = hypotheses), 
                            data = (ext_left = m_error_name == :ext_left ? m_prediction + m_error : missing, 
                                    ext_right = m_error_name == :ext_right ? m_prediction + m_error : missing,
                                    pro_left = m_error_name == :pro_left ? m_prediction + m_error : missing, 
                                    pro_right = m_error_name == :pro_right ? m_prediction + m_error : missing))
            old_hypos = hypotheses
            hypotheses = [h.p for h in values(result.posteriors)]
            @printf("Hypo update - %s, %s ===> %s, %s\n", 
                    print_vec(old_hypos[1]), print_vec(old_hypos[2]),
                    print_vec(hypotheses[1]), print_vec(hypotheses[2]))
        elseif haskey(proprioception, m_error_name)
            @printf("Action update - %s ===> %s\n", m_error_name, print_vec(m_prediction))
            act_arr = m_prediction

            proprioception[m_error_name] = act_arr
            action = Dict(m_error_name=>act_arr)
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
    pro_left ~ DiscreteTransition(h_left, P_cpt)
    pro_right ~ DiscreteTransition(h_right, P_cpt)
end

end # module PPModel