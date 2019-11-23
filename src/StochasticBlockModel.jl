module StochasticBlockModel

using Distributions, Random, JuMP, GLPKMathProgInterface

include("datasets.jl")
include("sbm.jl")
include("opt_methods.jl")
include("results.jl")
include("exact.jl")
include("heuristic.jl")

export generate

end # module
