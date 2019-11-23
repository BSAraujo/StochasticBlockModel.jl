module StochasticBlockModel

using Distributions, Random, JuMP, GLPKMathProgInterface

include("datasets.jl")
include("sbm.jl")
include("estimate.jl")
include("results.jl")
include("exact.jl")
include("heuristic.jl")

export generate, estimate

end # module
