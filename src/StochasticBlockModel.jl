module StochasticBlockModel

using Distributions, Random, JuMP

include("sbm.jl")
include("datasets.jl")
include("opt_methods.jl")

export generate

end # module
