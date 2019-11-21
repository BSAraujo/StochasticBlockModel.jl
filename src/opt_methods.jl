

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
        throw("The dimensions of the assignment matrix do not match the dimensions of the dataset.")
    end
    # Calculate objective value
    L = 0
    for g=1:q, h=1:q, i=1:n, j=i+1:n
        if x[i,g] * x[j,h] == 1
            if A[i,j] != 0
                L += (- A[i,j]*log(w[g,h]) + ((k[i]*k[j])/(2*m)) * w[g,h])
            else
                L += ( ((k[i]*k[j])/(2*m)) * w[g,h] )
            end
        end
    end
    for g=1:q, i=1:n
        if x[i,g] == 1
            if A[i,i] != 0
                L += 0.5 * ( - A[i,i]*log(w[g,g]) + ((k[i]^2)/(2*m)) * w[g,g] )
            else
                L += ( 0.5 * ((k[i]^2)/(2*m)) * w[g,g] )
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
        throw("The dimensions of the assignment matrix do not match the dimensions of the dataset.")
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
