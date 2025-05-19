# Define the base probability pattern (centered)
base_pattern = [0.00, 0.00, 0.05, 0.20, 0.50, 0.20, 0.05, 0.00]

# Initialize the CPT matrix
memory_cpt = zeros(8, 8)

# Fill the matrix with shifted patterns
for i in 1:8
    shift = i - 1
    memory_cpt[i, :] = circshift(base_pattern, shift)
end

# Display the matrix
println("memory_cpt =")
println(memory_cpt)
