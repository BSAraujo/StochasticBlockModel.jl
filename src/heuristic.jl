function randomAssignments(dataset::Dataset; seed::Union{Nothing, Int}=nothing)::Matrix{Int}
    """ Generates random assignments of n nodes to q groups

    Parameters
    ----------
    dataset : Dataset
        Dataset representing an observed graph.

    Returns
    -------
    x : Array{Int64,2}
        Matrix of assignments of nodes to groups
    """
    n = dataset.n
    q = dataset.n_communities
    if seed != nothing
        Random.seed!(seed)
    end

    assign = rand(1:q, n)

    x = zeros(Int, n, q)
    for i=1:n
        x[i,assign[i]] = 1
    end
    @assert sum(x) == n
    return x
end


function findImprovingRelocation(dataset::Dataset, w::Matrix{Float64}, x::Matrix{Int},
                                 reeval_w::Bool; best_imp::Bool=true, time_limit::Float64=400.0)
    """
    Parameters
    ----------
    dataset : Dataset
        Dataset representing an observed graph.
    x : Matrix{Int}
        Matrix of assignments of nodes to groups.
    w : Matrix{Float64}
        Matrix of probabilities of the SBM.
    reeval_w : Bool
        Whether to re-evaluate w to evaluate every possible move.
    best_imp : Bool
        Whether to take the best possible improving move (true) or to take the first improving move (false).
    """
    if best_imp == false
        throw("not implemented")
    end

    start = time(); # Start counting time

    n = dataset.n
    q = dataset.n_communities

    # Calculate objective value
    best_obj = calculateObjective(dataset, w, x)
    best_solution = (copy(w), copy(x))
    improved = false

    # loop through all nodes
    for i=1:n
        # Get current assignment of node i
        current_assign = argmax(x[i,:])
        for g=1:(q-1) # Find the best relocate move for node i

            # Break if time limit is exceeded
            availableTime = time_limit - (time() - start)
            if availableTime <= 0
                (w, x) = best_solution
                return improved, best_obj, w, x
            end

            # Set new assignment for node i
            new_assign = (current_assign + g)
            if new_assign > q
                new_assign = new_assign % q
            end

            # Reassign move
            x[i,current_assign] = 0
            x[i,new_assign] = 1

            # Evaluate move
            if reeval_w ##### Evaluate move on corresponding optimal w
                w = optimalProbMatrix(dataset, x)
            end
            #####
            obj_value = calculateObjective(dataset, w, x)
            if obj_value < best_obj
                best_obj = obj_value
                best_solution = (copy(w), copy(x))
                improved = true
            end

            # Undo reassign move
            x[i,current_assign] = 1
            x[i,new_assign] = 0
        end
    end

    # Reassign using the best move
    ##### Update matrix of probabilities w
    (w, x) = best_solution
    return improved, best_obj, w, x
end



function localSearchAssignments(estimator::SBMEstimator, dataset::Dataset, w::Union{Nothing,Matrix{Float64}}, x::Matrix{Int}; time_limit::Float64=400.0)
    """ Local Search in the space of the assignments x,
    by looking for the best relocate move.
    The value of w (probability matrix) is fixed and
    does not get updated inside this function

    Parameters
    ----------
    estimator : SBMEstimator
        Optimization method specifications.
    dataset : Dataset
        Dataset representing an observed graph.
    w : Union{Nothing,Matrix{Float64}}
        Matrix of probabilities. If nothing, then the optimal w will be calculated for the given x
    x : Matrix{Int}
        Matrix of assignments of nodes to groups.
    time_limit : Float64
        Time limit in seconds.

    Returns
    -------
    x : Matrix{Int}
        Matrix of assignments of nodes to groups (local optimum).
    """

    # Check if a matrix w was given
    if w == nothing
        w = optimalProbMatrix(dataset, x)
    end

    start = time(); # Start counting time

    improved = true
    while improved
        improved = false
        # Break if time limit is exceeded
        availableTime = time_limit - (time() - start)
        if availableTime <= 0
            break
        end
        improved, best_obj, w, x = findImprovingRelocation(dataset, w, x, false, best_imp=true, time_limit=availableTime)
    end
    return x
end
