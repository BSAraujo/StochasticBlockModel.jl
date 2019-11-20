struct SBM
    w::Matrix{Float64}      # Matrix of probabilities
    dist::String            # Distribution (either "poisson" or "bernoulli")
    n_communities::Int      # Number of communities/clusters

    # Constructor function for struct SBM
    function SBM(w::Matrix{Float64}, dist::String)
        # Check if w is a square matrix
        if size(w,1) != size(w,2)
            throw(ArgumentError("Matrix w must be a square matrix."))
        end
        # Check if elements in w are strictly positive
        if any(w .< 0)
            throw(DomainError("All elements in matrix of probabilities w must be strictly positive."))
        end
        # Check if matrix is symmetric
        if w != w'
            throw(ArgumentError("Matrix w must be symmetric."))
        end
        q = size(w,1)

        # Check input argument 'distribution'
        if ~(dist in ["poisson","bernoulli"])
            throw(ArgumentError(string("Invalid distribution: ", dist)))
        end
        if dist == "bernoulli"
            # Check if w is a matrix of 0-1 values
            if any(w .> 1)
                throw(DomainError("When using a bernoulli distribution all elements in matrix of probabilities w must be between 0 and 1."))
            end
        end
        return new(w, dist, q)
    end
end

function generate(sbm::SBM, n_per_community::Vector{Int}, seed::Any=nothing)::Matrix{Int}
    """
    Generates a graph from the Stochastic Block Model.

    Parameters
    ----------
    sbm : SBM
        An SBM structure.
    n_per_community : Vector{Int}
        Number of nodes in each community.
    seed : Any
        Seed for the random number generator.

    Returns
    -------
    adj_matrix : Matrix{Int}
        Adjacency matrix of the generated graph
    """
    # Check input argument 'n_per_community'
    if any(n_per_community .<= 0)
        throw(DomainError(string("Invalid value in argument n_per_community: ",
                                 "the number of nodes in each community must be strictly positive.")))
    end
    # Check if n_per_community matches the dimensions of w
    if ~(length(n_per_community) == sbm.n_communities)
        throw(ArgumentError("Number of communities in n_per_community must match the number of communities in SBM"))
    end

    # Set the random seed if one was provided
    if seed != nothing
        Random.seed!(seed)
    end
    # Define number of vertices, initialize adjacency matrix and community labels
    n_vertices = sum(n_per_community);
    adj_matrix = zeros(Int, n_vertices,n_vertices);
    community_labels = convert(Array{Int}, vcat([i*ones(ni) for (i,ni) in enumerate(n_per_community)]...));
    # Construct adjacency matrix
    for i=1:n_vertices
        for j=1:i
            proba = sbm.w[community_labels[i], community_labels[j]];
            if sbm.dist == "poisson"
                if i == j
                    proba = proba / 2 # "The factor of half is included solely because it makes the algebra easier"
                end
                pois = Distributions.Poisson(proba);
                adj_matrix[i,j] = rand(pois);
            elseif sbm.dist == "bernoulli"
                if i == j
                    adj_matrix[i,j] = 0;
                else
                    bernoulli = Bernoulli(proba);
                    adj_matrix[i,j] = rand(bernoulli);
                end
            end
        end
    end
    # "We have adopted the common convention that a self-edge is represented by A[i,j] = 2
    # (and not 1 as one might at first imagine)"
    adj_matrix += transpose(adj_matrix) #- Diagonal(adj_matrix)

    # Return adjacency matrix
    return adj_matrix
end

function generate(probability_matrix::Matrix{Float64}, n_per_community::Vector{Int};
                            distribution::String="poisson", seed::Any=nothing)::Matrix{Int}
    """
    Generates a graph from the Stochastic Block Model.

    Parameters
    ----------
    probability_matrix : Matrix{Float64}
        Matrix of expected number of edges under Poisson distribution.
    n_per_community : Vector{Int}
        Number of nodes in each community.
    distribution : String
        Distribution to be used for generating edges (either "poisson" or "bernoulli").
    seed : Any
        Seed for the random number generator.

    Returns
    -------
    adj_matrix : Matrix{Int}
        Adjacency matrix of the generated graph
    """
    sbm = SBM(probability_matrix, distribution)
    return generate(sbm, n_per_community, seed)
end
