using RxInfer
using Printf


@model function predict_model(prior, y)
    frog_or_apple ~ prior # frog = 0 (and thus apple = 1)
    T_mat = [0.99 0.19; 
             0.01 0.81] # First column: jump = 0, second column: jump = 1, first row: apple, second row: frogs
    y ~ Transition(frog_or_apple, T_mat)
end

# HYPOTHESIS UPDATE (given observation)
function update(hypotheses)
    result = infer(model = complex_model_prediction(hypos = hypotheses), 
                    data = (ext_left = [0.1, 0.9], pro_left = missing))

    return result
end

# OBSERVATION prediction (given hypotheses)
function prediction()
    result = infer(model = complex_model_prediction(hypos = [[1, 0], [1, 0]]), 
                    data = (ext_left = missing, ext_right = missing,
                            pro_left = missing, pro_right = missing))

    return result
end

@model function complex_model_prediction(hypos, ext_left, pro_left)
    #       H
    #    ___|___
    #   |       |
    #   E       P

    h_left ~ Categorical(hypos[1])

    # -> col wise e.g: [0.9, 0.0, 0.1; 
    #                   0.5, 0.3, 0.2]
    E_cpt = [0.9 0.1; 
             0.1 0.9] 
    P_cpt = [0.9 0.1; 
             0.1 0.9] 
             
    ext_left ~ Transition(h_left, E_cpt)
    pro_left ~ Transition(h_left, P_cpt)

end

hypo1 = [[0.6, 0.4]]
result = update(hypo1)

for (k, v) in result.posteriors
    @printf("%s: %s\n", k, v.p)
end

# hypo2= [[0.5, 0.5]]
# result = update(hypo2)

# for (k, v) in result.posteriors
#     @printf("%s: %s\n", k, v.p)
# end