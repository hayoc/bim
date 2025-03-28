using RxInfer
using Printf


@model function predict_model(prior, y)
    frog_or_apple ~ prior # frog = 0 (and thus apple = 1)
    T_mat = [0.99 0.19; 
             0.01 0.81] # First column: jump = 0, second column: jump = 1, first row: apple, second row: frogs
    y ~ Transition(frog_or_apple, T_mat)
end

# HYPOTHESIS UPDATE (given observation)
function update()
                                                            #  h_left      h_right
    result = infer(model = complex_model_prediction(hypos = [[0.9, 0.1], [0.9, 0.1]]), 
                    data = (ext_left = [1, 0], ext_right = [1, 0],
                            pro_left = [1, 0], pro_right = [1, 0]))

    return result
end

# OBSERVATION prediction (given hypotheses)
function prediction()
    result = infer(model = complex_model_prediction(hypos = [[1, 0], [1, 0]]), 
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
             
    ext_left ~ Transition(h_left, E_cpt)
    ext_right ~ Transition(h_right, E_cpt)
    pro_left ~ Transition(h_left, P_cpt)
    pro_right ~ Transition(h_right, P_cpt)
end

result = update()

for (k, v) in result.posteriors
    @printf("%s: %s\n", k, v.p)
end