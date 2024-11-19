using RxInfer
using Printf


@model function pp_model(hypos, ext_left, ext_right, pro_left, pro_right)
    h_left ~ Categorical(hypos[1])
    h_right ~ Categorical(hypos[2])

    P_cpt = [0.9 0.1; 
             0.1 0.9] 
    E_cpt = [0.9 0.1; 
             0.1 0.9] 
             
    ext_left ~ Transition(h_left, E_cpt)
    ext_right ~ Transition(h_right, E_cpt)
    pro_left ~ Transition(h_left, P_cpt)
    pro_right ~ Transition(h_right, P_cpt)
end

function run()
    hypotheses = [[0.5, 0.5], [0.5, 0.5]]
    result = infer(model = pp_model(hypos = hypotheses), 
    data = (ext_left = missing, ext_right = missing,
            pro_left = missing, pro_right = missing))
    predictions = Dict(k => v.p for (k, v) in result.predictions)

    println(predictions)
end

run()