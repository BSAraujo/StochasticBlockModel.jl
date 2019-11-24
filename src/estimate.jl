
struct SBMEstimator
    exact::Bool                 # Whether the method is exact, i.e. returns a global optimum
    method::String              # Name of the method
    time_limit::Float64         # Time limit in seconds
    verbose::Bool               # Verbose
    seed::Union{Nothing,Int}    # Random seed (for assignments initialization)
    accept_early::Bool          # Specific option for local search 1

    function SBMEstimator(method::String, time_limit::Float64, verbose::Bool, seed::Union{Nothing,Int}, accept_early::Bool)
        if ~(method in ["ls1","ls2","ls3","exact"])
            throw(ArgumentError("Invalid method: $method."))
        end
        if time_limit <= 0
            throw(DomainError("Time limit must be a positive value (in seconds)."))
        end
        if method == "exact"
            exact = true
        else
            exact = false
        end
        return new(exact, method, time_limit, verbose, seed, accept_early)
    end

    function SBMEstimator(method::String, time_limit::Float64, verbose::Bool, accept_early::Bool)
        seed = nothing
        return SBMEstimator(method, time_limit, verbose, seed, accept_early)
    end
end

include("local_search1.jl")
include("local_search2.jl")
include("local_search3.jl")


function run(estimator::SBMEstimator, dataset::Dataset)::Tuple{SBM, Matrix{Int}, OptResults}
    if estimator.method == "ls1"
        return localSearch1(estimator, dataset)
    elseif estimator.method == "ls2"
        return localSearch2(estimator, dataset)
    elseif estimator.method == "ls3"
        return localSearch3(estimator, dataset)
    elseif estimator.method == "exact"
        return MINLP(estimator, dataset)
    end
end


function calculateObjective(dataset::Dataset, w::Matrix{Float64}, x::Matrix{Int})::Float64
    """ Calculates the maximum log-likelihood value

    Parameters
    ----------
    dataset : Dataset
        Dataset representing an observed graph.
    sbm : SBM
        An Stochastic Block Model
    x : Matrix{Int}
        Matrix of assignments of nodes to groups

    Returns
    -------
    L : Float64
        Maximum log-likelihood value
    """
    A = dataset.A
    n = dataset.n
    m = dataset.m
    q = dataset.n_communities
    k = dataset.k
    if ~((n,q) == size(x))
        throw(ArgumentError("The dimensions of the assignment matrix do not match the dimensions of the dataset."))
    end
    # Calculate objective value
    L = 0
    for g=1:q, h=1:q, i=1:n, j=1:n
        if x[i,g] * x[j,h] == 1
            if A[i,j] != 0
                L += 0.5*(- A[i,j]*log(w[g,h]) + ((k[i]*k[j])/(2*m)) * w[g,h])
            else
                L += 0.5*( ((k[i]*k[j])/(2*m)) * w[g,h] )
            end
        end
    end
    return L
end



function optimalProbMatrix(dataset::Dataset, x::Matrix{Int})::Matrix{Float64}
    """ Calculates the optimal probability matrix given the assignments

    Parameters
    ----------
    dataset : Dataset
        Dataset representing an observed graph.
    x : Array{Int64,2}
        Matrix of assignments of nodes to groups

    Returns
    -------
    w : Array{Int64,2}
        Matrix of probabilities
    """
    A = dataset.A
    n = dataset.n
    m = dataset.m
    q = dataset.n_communities
    k = dataset.k
    if ~((n,q) == size(x))
        throw(ArgumentError("The dimensions of the assignment matrix do not match the dimensions of the dataset."))
    end

    w = zeros(q,q)
    for g=1:q, h=1:q
        numerator = 0.5*sum(A[i,j]*x[i,g]*x[j,h] for i=1:n, j=1:n)
        denominator = 0.5*sum( ((k[i]*k[j])/(2*m)) *x[i,g]*x[j,h] for i=1:n, j=1:n)
        if numerator == 0
            w[g,h] = 0
        else
            w[g,h] = numerator / denominator
        end
    end
    return w
end


function estimate(dataset::Dataset; method::String="ls1", time_limit::Float64=400.0, verbose::Bool=false)::Tuple{SBM, Matrix{Int}, OptResults}
    estimator = SBMEstimator(method, time_limit, verbose, true)
    sbm, x, opt_results = run(estimator, dataset)
    return sbm, x, opt_results
end


function estimate(A::Matrix{Int}, q::Int; method::String="ls1", time_limit::Float64=400.0, verbose::Bool=false)::Tuple{SBM, Matrix{Int}, OptResults}
    dataset = Dataset(A, q)
    estimator = SBMEstimator(method, time_limit, verbose, true)
    sbm, x, opt_results = run(estimator, dataset)
    return sbm, x, opt_results
end
