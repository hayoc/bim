using RxInfer, Distributions
using Printf
using GraphViz


function update(hypos)
    result = infer(model = xmodel(hypos = hypos), 
                    data = (compass = missing, mem_output = [0, 1]))

    return result
end

function prediction()
    h = Dict(
        :compass=>[1, 0, 0, 0, 0, 0, 0, 0],
        :memory=>[1, 0, 0, 0, 0, 0, 0, 0],
    )

    initialization = @initialization begin
        μ(compass) = Categorical(fill(1/8, 8))
        μ(memory) = Categorical(fill(1/8, 8))
    end


    result = infer(
        model = xmodel(h = h), 
        data = (st_left = UnfactorizedData(missing), st_right = UnfactorizedData(missing)),
        initialization = initialization,
    )

    return result
end

@model function xmodel(h, st_left, st_right)
    st_left_cpt = gen_cpt("LEFT")
    st_right_cpt = gen_cpt("RIGHT")

    compass ~ Categorical(h[:compass])
    memory ~ Categorical(h[:memory])

    st_left ~ DiscreteTransition(compass, st_left_cpt, memory)
    st_right ~ DiscreteTransition(compass, st_right_cpt, memory)
end

function gen_cpt(node::String)
    cpt = zeros(2, 8, 8)  # [true/false, compass_idx, memory_idx]
    directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
    dir_to_index = Dict(d => i for (i, d) in enumerate(directions))

    for (i, compass_dir) in enumerate(directions)
        for (j, memory_dir) in enumerate(directions)
            compass_idx = dir_to_index[compass_dir]
            memory_idx = dir_to_index[memory_dir]

            offset = mod(memory_idx - compass_idx, 8)
            if node == "RIGHT"
                if offset == 4
                    true_val = 0.5
                elseif offset in (1, 2, 3)
                    true_val = 1.0
                else
                    true_val = 0.0
                end
            elseif node == "LEFT"
                if offset == 4
                    true_val = 0.5
                elseif offset in (5, 6, 7)
                    true_val = 1.0
                else
                    true_val = 0.0
                end
            else
                error("Unknown node: $node")
            end

            cpt[1, compass_idx, memory_idx] = true_val  
            cpt[2, compass_idx, memory_idx] = 1.0 - true_val 
        end
    end

    return cpt
end

preds = prediction()
for (k, v) in preds.predictions
    @printf("%s: %s\n", k, round.(v.p, digits=3))
end

# model_generator = xmodel(hypos = [[0, 1], [1, 0]]) | (ext_mem = [ 1.0, 0.0 ], pro_steer = [ 0.0, 1.0])
# model_to_plot   = RxInfer.getmodel(RxInfer.create_model(model_generator))
# GraphViz.load(model_to_plot, strategy = :simple)



