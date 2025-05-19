using RxInfer
using Printf


function update(hypotheses, x)
    result = infer(model = xmodel(hypos = hypotheses), 
                    data = (x = x,))

    return result
end

function prediction(hypotheses)
    result = infer(model = xmodel(hypos = hypotheses), 
                    data = (x = missing, ))

    return result
end

@model function xmodel(hypos, x)
    h1 ~ Categorical(hypos[1])
    #h2 ~ Categorical(hypos[2])

    cpt = [
            0.6 0.2;
            0.4 0.8;
        ]


    x ~ DiscreteTransition(h1, cpt)
end

hypos = [[0.0, 1.0], [1.0, 0.0]]
result = prediction(hypos)

println(result.predictions)
# for (k, v) in result.predictions
#     @printf("%s: %s\n", k, v.p)
# end