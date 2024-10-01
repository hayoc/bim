module PPModel

export predictive_processing

using RxInfer




function predictive_processing(observations, motors)
    # 1. prediction
    # 2. prediction error
    # 3. prediction error minimization


end

@model function parr_book(prior, y)
    frog_or_apple ~ prior # frog = 0 (and thus apple = 1)
    T_mat = [0.99 0.19; 
             0.01 0.81] # First column: jump = 0, second column: jump = 1, first row: apple, second row: frogs
    y ~ Transition(frog_or_apple, T_mat)
end

# HYPOTHESIS UPDATE (given observation)
function update(hypotheses, observation)
    result = infer(model = parr_book(prior = Categorical(hypotheses)), data = (y = observation,))

    return result.posteriors[:frog_or_apple].p
end

# OBSERVATION prediction (given hypotheses)
function prediction(hypotheses)
    result = infer(model = parr_book(prior = Categorical(hypotheses)), data = (y = missing,))

    return result.predictions[:y].p
end

prediction()



# result = infer(
#     model = beta_bernoulli(a = 1.0, b = 1.0),
#     data  = (y = [ missing, missing, missing, missing, missing ], )
# )
end # Module PPModel