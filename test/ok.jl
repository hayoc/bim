using RxInfer

# @model function test_model(hypos, x)
#     p1 ~ Categorical(hypos[1])  
#     p2 ~ Categorical(hypos[2]) 

#     cpt = rand(2, 2, 2)

#     x ~ DiscreteTransition(A, cpt, B)
# end

@model function dummy(y)
    a ~ Categorical([1.0, 0.0]) 
    b ~ Categorical([0.0, 1.0]) 
    #c ~ Categorical([0.0, 1.0]) 


    T_mat = reshape([
        0.8, 0.1, 0.1,   # A=false, B=false
        0.3, 0.6, 0.1,  # A=false, B=true
        0.4, 0.5, 0.1 ,  # A=true,  B=false
        0.1, 0.8, 0.1  # A=true,  B=true
    ], 3, 2, 2)

    # T_mat = reshape([
    #     0.9, 0.1, # A=false, B=false, C=false
    #     0.6, 0.4, # A=false, B=false, C=true
    #     0.7, 0.3, # A=false, B=true, C=false
    #     0.2, 0.8, # A=false, B=true, C=true
    #     0.5, 0.5, # A=true, B=false, C=false
    #     0.3, 0.7, # A=true, B=false, C=true
    #     0.4, 0.6, # A=true, B=true, C=false
    #     0.1, 0.9 # A=true, B=true, C=true
    # ], 2, 2, 2, 2)

    y ~ DiscreteTransition(a, T_mat, b)
end

result = infer(
           model = dummy(),
           data = (y = UnfactorizedData(missing), ),
       )

#result = infer(model = dummy(), data = (y = missing,))
println(result.predictions)


# CONC: maybe I have to create my own factor node??
#hypos = [[0.9, 0.1], [0.6, 0.4]]


# # using Cairo, GraphPlot
# conditioned = bayesian_network(hypos=hypos) | (x = missing, )
# model = RxInfer.create_model(conditioned)
# # GraphPlot.gplot(RxInfer.getmodel(model))

# println("------------------FACT NODES---------------------")
# for node in RxInfer.getfactornodes(model)
#     println("--------------------------------------")
#     println(node)
#     println("--------------------------------------")
# end

# println("------------------RAND VARS---------------------")
# for node in RxInfer.getrandomvars(model)
#     println("--------------------------------------")
#     println(node)
#     println("--------------------------------------")
# end

# println("------------------DATA VARS---------------------")
# for node in RxInfer.getdatavars(model)
#     println("--------------------------------------")
#     println(node)
#     println("--------------------------------------")
# end

# println("------------------CONST VARS---------------------")
# for node in RxInfer.getconstantvars(model)
#     println("--------------------------------------")
#     println(node)
#     println("--------------------------------------")
# end

