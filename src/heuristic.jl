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



function localSearchAssignments(opt_method::OptMethod, dataset::Dataset, w::Union{Nothing,Matrix{Float64}}, x::Matrix{Int}; start::Union{Nothing,Float64}=nothing)
    """ Local Search in the space of the assignments x,
    by looking for the best relocate move.
    The value of w (probability matrix) is fixed and
    does not get updated inside this function

    Parameters
    ----------
    opt_method : OptMethod
        Optimization method specifications.
    dataset : Dataset
        Dataset representing an observed graph.
    w : Union{Nothing,Matrix{Float64}}
        Matrix of probabilities. If nothing, then the optimal w will be calculated for the given x
    x : Matrix{Int}
        Matrix of assignments of nodes to groups.
    start : Union{Nothing,Float64}
        Start of the solve process if it has started before this function call. Otherwise nothing.

    Returns
    -------
    x : Matrix{Int}
        Matrix of assignments of nodes to groups (local optimum).
    """
    A = dataset.A
    n = dataset.n
    m = dataset.m
    q = dataset.n_communities
    k = dataset.k
    timeLimit = opt_method.time_limit

    # Check if a matrix w was given
    if w == nothing
        w = optimalProbMatrix(dataset, x)
    end

    if start == nothing # check if the time counter has started before this function call
        start = time(); # Start counting time
    end

    # Calculate and store initial objective value
    obj_value = calculateObjective(dataset, w, x)
    best_obj = obj_value
    best_move = nothing

    improved = true
    iteration = 0
    while improved
        improved = false
        # Break if time limit is exceeded
        if time() - start > timeLimit
            status = :UserLimit
            break
        end
        iteration += 1
        if opt_method.verbose
            println("iteration=$iteration")
        end
        # loop through all nodes
        for i=1:n
            # Get current assignment of node i
            current_assign = argmax(x[i,:])
            for g=1:(q-1) # Find the best relocate move for node i
                loop_start = time() # Record loop start time
                if opt_method.verbose
                    print("i=$i; g=$g; ")
                end
                new_assign = (current_assign + g)
                if new_assign > q
                    new_assign = new_assign % q
                end

                # Reassign move
                x[i,current_assign] = 0
                x[i,new_assign] = 1

                # Evaluate move
                # TODO: calculate difference in objective value more efficiently
                obj_value = calculateObjective(dataset, w, x)
                if obj_value < best_obj
                    best_obj = obj_value
                    best_move = (i, current_assign, new_assign)
                    improved = true
                end

                # Undo reassign move
                x[i,current_assign] = 1
                x[i,new_assign] = 0

                loop_time = time() - loop_start # loop time
                if opt_method.verbose
                    println("loop time=$loop_time")
                end

                if improved && opt_method.accept_early
                    break
                end
            end
        end

        # Reassign using the best move
        if improved
            (idx, current_g, new_g) = best_move
            x[idx, current_g] = 0
            x[idx, new_g] = 1
        end
    end
    return x
end


function localSearch1(opt_method::OptMethod, dataset::Dataset)
    """ Local Search 1
    Initialization with random assignments x.
    This local search heuristic works in two steps:
    1- Performs a loop of local search in the
    space of the assignments x (with w fixed).
    2- After a local optimum for x has been found,
    updates w with the optimal value (with x fixed),
    found analytically using the derivatives of the objective function.

    Parameters
    ----------
    opt_method : OptMethod
        Optimization method specifications.
    dataset : Dataset
        Dataset representing an observed graph.

    Returns
    -------
    sbm : SBM
        Stochastic Block Model
    x : Array{Int64,2}
        Matrix of assignments of nodes to groups
    opt_results : OptResults
        Results of the optimization process
    """
    timeLimit = opt_method.time_limit

    start = time(); # Start counting time

    # Initialize with random assignments
    x = randomAssignments(dataset)
    w = optimalProbMatrix(dataset, x)

    # Calculate objective value
    obj_value = calculateObjective(dataset, w, x)
    best_obj = obj_value

    iterations = 0
    improved = true
    while improved
        improved = false
        # Break if time limit is exceeded
        availableTime = timeLimit - (time() - start)
        if availableTime <= 0
            status = :UserLimit
            break
        end
        # Local Search on the space of assignments
        x = localSearchAssignments(opt_method, dataset, w, x,
                                   start=start)
        # Update w with optimal value
        w = optimalProbMatrix(dataset, x)
        # Evaluate move
        obj_value = calculateObjective(dataset, w, x)
        if obj_value < best_obj
            best_obj = obj_value
            improved = true
        end
        iterations += 1
    end
    status = :LocalOptimum_LS1
    solvetime = time() - start;

    # SBM
    sbm = SBM(w, "poisson") # assumes a poisson distribution

    # Build OptResults
    obj_lb = -Inf
    obj_ub = obj_value
    nodecount = 0
    println("Solvetime: $solvetime")
    opt_results = OptResults(obj_lb, obj_ub, status, solvetime, iterations, nodecount, 0)
    if opt_method.verbose
        display(opt_results)
    end
    return sbm, x, opt_results
end


function localSearch2(opt_method::OptMethod, dataset::Dataset)
    throw("not implemented")
end

function localSearch3(opt_method::OptMethod, dataset::Dataset)
    throw("not implemented")
end
