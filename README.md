# StochasticBlockModel

[![Build Status](https://travis-ci.com/BSAraujo/StochasticBlockModel.jl.svg?branch=master)](https://travis-ci.com/BSAraujo/StochasticBlockModel.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/BSAraujo/StochasticBlockModel.jl?svg=true)](https://ci.appveyor.com/project/BSAraujo/StochasticBlockModel-jl)
[![Codecov](https://codecov.io/gh/BSAraujo/StochasticBlockModel.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/BSAraujo/StochasticBlockModel.jl)
[![Coveralls](https://coveralls.io/repos/github/BSAraujo/StochasticBlockModel.jl/badge.svg?branch=master)](https://coveralls.io/github/BSAraujo/StochasticBlockModel.jl?branch=master)


StochasticBlockModel.jl is a Julia package that provides methods for common tasks related to Stochastic Block Models (SBM), such as generating random graphs with community structure and detecting communities in a given network. Community detection is performed by estimating the parameters of a SBM from an observed graph. Different heuristics and one exact method are provided for the problem of finding the maximum log-likelihood estimate of the parameters of a SBM.


## Installation

To install this package, open the Julia REPL and type `]add StochasticBlockModel`.

## Example Usage

Generating a graph with community structure:

```julia
julia> using StochasticBlockModel

julia> w = [1.0 0.2;
            0.2 1.0]
            
julia> n_per_community = [6; 6]

julia> dataset = generate(w, n_per_community, seed=0)

julia> dataset.A
12×12 Array{Int64,2}:
 2  2  0  0  1  1  0  0  0  0  0  0
 2  0  0  0  1  1  0  0  0  0  0  0
 0  0  0  0  0  2  0  1  0  1  0  0
 0  0  0  4  2  3  0  1  1  0  0  0
 1  1  0  2  0  2  0  0  1  0  0  0
 1  1  2  3  2  0  0  0  0  0  0  0
 0  0  0  0  0  0  0  0  0  2  1  1
 0  0  1  1  0  0  0  2  0  1  1  1
 0  0  0  1  1  0  0  0  0  1  2  0
 0  0  1  0  0  0  2  1  1  2  0  1
 0  0  0  0  0  0  1  1  2  0  4  1
 0  0  0  0  0  0  1  1  0  1  1  0
```

Detecting communities in a graph:

```julia
julia> using StochasticBlockModel

julia> dataset = Dataset("../instances/zachary.in")

julia> sbm, x, opt_results = estimate(dataset, time_limit=10.0)

julia> sbm.w
2×2 Array{Float64,2}:
 0.551446  1.59584
 1.59584   0.20851

julia> StochasticBlockModel.displayResults(opt_results)

--------------- Opt Results ---------------
Obj. LB = -Inf
Obj. UB = 62.52483
Status: LocalOptimum_LS1
Solve time: 0.016 seconds
Iterations: 2
```

