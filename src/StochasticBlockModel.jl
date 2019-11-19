module StochasticBlockModel

using Distributions, Random, JuMP

greet() = print("Hello World!")

include("generative_models.jl")

export generatePoissonSBM

end # module
