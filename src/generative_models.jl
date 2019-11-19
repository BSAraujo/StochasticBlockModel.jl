
function generateSBM(probability_matrix::Array{Float64,2}, n_per_community::Array{Int,2};
                            distribution::String="poisson", seed::Any=nothing)
    """
    Generates a graph from the Stochastic Block Model (Poisson version).

    Parameters
    ----------
    probability_matrix : Array{Float64,2}
        Matrix of expected number of edges under Poisson distribution.
    n_per_community : Array{Int64,2}
        Number of nodes in each community.
    distribution : String
        Distribution to be used for generating edges (either "poisson" or "bernoulli").
    seed : Any
        Seed for the random number generator.

    Returns
    -------
    adj_matrix : Array{Int64,2}
        Adjacency matrix of the generated graph
    """

    # Check input argument 'distribution'
    if ~(distribution in ["poisson","bernoulli"])
        throw(string("Invalid distribution: ", distribution))
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
            proba = probability_matrix[community_labels[i], community_labels[j]];
            if distribution == "poisson"
                if i == j
                    proba = proba / 2 # "The factor of half is included solely because it makes the algebra easier"
                end
                pois = Distributions.Poisson(proba);
                adj_matrix[i,j] = rand(pois);
            elseif distribution == "bernoulli"
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
