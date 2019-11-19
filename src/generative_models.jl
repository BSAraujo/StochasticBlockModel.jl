import Distributions
import Random

function generatePoissonSBM(probability_matrix::Array{Float64,2}, n_per_community::Array{Int64,2}; seed::Any=nothing)
    """
    Generates a graph from the Stochastic Block Model (Poisson version).

    Parameters
    ----------
    probability_matrix : Array{Float64,2}
        Matrix of expected number of edges under Poisson distribution.
    n_per_community : Array{Int64,2}
        Number of nodes in each community.
    seed : Any
        Seed for the random number generator.

    Returns
    -------
    adj_matrix : Array{Int64,2}
        Adjacency matrix of the generated graph
    """
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
            if i == j
                proba = proba / 2 # "The factor of half is included solely because it makes the algebra easier"
            end
            pois = Distributions.Poisson(proba);
            adj_matrix[i,j] = rand(pois);
        end
    end
    # "We have adopted the common convention that a self-edge is represented by A[i,j] = 2
    # (and not 1 as one might at first imagine)"
    adj_matrix += transpose(adj_matrix) #- Diagonal(adj_matrix)

    # Return adjacency matrix
    return adj_matrix
end
