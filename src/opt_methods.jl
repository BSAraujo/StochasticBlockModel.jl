struct OptMethod
    exact::Bool                 # Whether the method is exact, i.e. returns a global optimum
    method::String              # Name of the method
    time_limit::Float64         # Time limit in seconds
    verbose::Bool               # Verbose
    seed::Union{Nothing,Int}    # Random seed (for assignments initialization)
    accept_early::Bool          # Specific option for local search 1

    function OptMethod(method::String, time_limit::Float64, verbose::Bool, seed::Union{Nothing,Int}, accept_early::Bool)
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

    function OptMethod(method::String, time_limit::Float64, verbose::Bool, accept_early::Bool)
        seed = nothing
        return OptMethod(method, time_limit, verbose, seed, accept_early)
    end
end

function run(opt_method::OptMethod, dataset::Dataset)::OptResults
    if opt_method.method == "ls1"
        return LocalSearch1(opt_method, dataset)
    elseif opt_method.method == "ls2"
        return LocalSearch2(opt_method, dataset)
    elseif opt_method.method == "ls3"
        return LocalSearch3(opt_method, dataset)
    elseif opt_method.method == "exact"
        return MINLP(opt_method, dataset)
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
