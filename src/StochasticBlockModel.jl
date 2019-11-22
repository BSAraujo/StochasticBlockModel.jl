module StochasticBlockModel

using Distributions, Random, JuMP, Gurobi

include("sbm.jl")
include("datasets.jl")
include("opt_methods.jl")
include("results.jl")
include("exact.jl")

export generate

end # module
