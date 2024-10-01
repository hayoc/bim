using Distributions
using Plots


# Define the parameters
μ = 0.5    # Mean direction (center)
κ = 100.0    # Concentration (higher κ means higher concentration around μ)

# Create a von Mises distribution
vm_dist = VonMises(μ, κ)
# Sample 1000 points from the distribution
samples = rand(vm_dist, 1000)

# Plot histogram of the samples
histogram(samples, bins=30, normalize=true, label="Sampled Data", xlabel="θ", ylabel="Frequency", title="von Mises Samples", alpha=0.5)
