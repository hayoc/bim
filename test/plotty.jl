using Distributions
using Plots

# Define the Von Mises distribution
vm = VonMises(-0.5, 1000.0)

# Sample 1000 random values
samples = rand(vm, 1000)

# Plot histogram in bins
histogram(samples;
    bins=36,
    normalize=true,
    label="Samples",
    xlabel="Angle (radians)",
    ylabel="Density",
    title="Von Mises Samples Histogram"
)
