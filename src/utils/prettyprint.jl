module PrettyPrint

export print_vec

function print_vec(v)
    return "["*join(round.(v, sigdigits=3),",")*"]"
end

end
