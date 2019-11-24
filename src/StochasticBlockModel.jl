module StochasticBlockModel

using Distributions, Random, JuMP, GLPKMathProgInterface

include("datasets.jl")
include("sbm.jl")
include("estimate.jl")
include("results.jl")
include("exact.jl")
include("heuristic.jl")
include("local_search1.jl")
include("local_search2.jl")
include("local_search3.jl")

export generate, estimate

end # module
