using Revise
using RxInfer

includet("../world/flat.jl")

using .FlatWorld


rows, cols = 10, 10
obstacles = [(2, 3)]

grid = create_environment(rows, cols, obstacles)
plot_environment(grid)


# @model function parr_book(prior, y)
#     frog_or_apple ~ prior # frog = 0 (and thus apple = 1)
#     T_mat = [0.99 0.19; 
#              0.01 0.81] # First column: jump = 0, second column: jump = 1, first row: apple, second row: frogs
#     y ~ Transition(frog_or_apple, T_mat)
# end

# function run()
#     hypo = [0.9, 0.1]
#     result = nothing

#     for _ = 1:10
#         result = infer(model = parr_book(prior = Categorical(hypo)), data = (y = [0.7 , 0.3],))
#         hypo = result.posteriors[:frog_or_apple].p
#         println(result.posteriors[:frog_or_apple])
#     end

#     return result
# end

# run()