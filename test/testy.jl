using RxInfer
using Printf


@model function predict_model(prior, y)
    frog_or_apple ~ prior # frog = 0 (and thus apple = 1)
    T_mat = [0.99 0.19; 
             0.01 0.81] # First column: jump = 0, second column: jump = 1, first row: apple, second row: frogs
    y ~ Transition(frog_or_apple, T_mat)
end

# HYPOTHESIS UPDATE (given observation)
function update(hypos)
    result = infer(model = complex_model_prediction(hypos = hypos), 
                    data = (ext_left = missing, ext_right = [0, 1],
                            pro_left = missing, pro_right = missing))

    return result
end

# OBSERVATION prediction (given hypotheses)
function prediction(hypos)
    result = infer(model = complex_model_prediction(hypos = hypos), 
                    data = (ext_left = missing, ext_right = missing,
                            pro_left = missing, pro_right = missing))

    return result
end

@model function complex_model_prediction(hypos, ext_left, ext_right, pro_left, pro_right)
    #       H
    #    ___|___
    #   |       |
    #   E       P

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


println("----------------1-------------------")
hypos = [[0.1, 0.9], [0.9, 0.1]]

preds = prediction(hypos)
for (k, v) in preds.predictions
    @printf("%s: %s\n", k, round.(v.p, digits=3))
end


# result = update(hypos)
# for (k, v) in result.posteriors
#     @printf("%s: %s\n", k, round.(v.p, digits=3))
# end

# println("---------------2--------------------")
# hypos = [v.p for (k, v) in result.posteriors]
# preds = prediction(hypos)
# for (k, v) in preds.predictions
#     @printf("%s: %s\n", k, round.(v.p, digits=3))
# end
# result = update(hypos)
# for (k, v) in result.posteriors
#     @printf("%s: %s\n", k, round.(v.p, digits=3))
# end

# println("----------------3-------------------")
# hypos = [v.p for (k, v) in result.posteriors]
# preds = prediction(hypos)
# for (k, v) in preds.predictions
#     @printf("%s: %s\n", k, round.(v.p, digits=3))
# end
# result = update(hypos)
# for (k, v) in result.posteriors
#     @printf("%s: %s\n", k, round.(v.p, digits=3))
# end