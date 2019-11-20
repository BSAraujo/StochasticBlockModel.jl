module StochasticBlockModel

using Distributions, Random, JuMP

include("sbm.jl")
include("datasets.jl")

export generate

end # module
