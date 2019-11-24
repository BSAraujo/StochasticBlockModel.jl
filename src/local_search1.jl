
function localSearch1(estimator::Estimator, dataset::Dataset)
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
    estimator : Estimator
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
    timeLimit = estimator.time_limit

    start = time(); # Start counting time

    # Initialize with random assignments
    x = randomAssignments(dataset, seed=estimator.seed)
    w = optimalProbMatrix(dataset, x)

    # Calculate objective value
    obj_value = calculateObjective(dataset, w, x)
    best_solution = (copy(w), copy(x))
    best_obj = obj_value

    status = nothing
    iterations = 0
    improved = true
    while true
        ## Base cases
        # Break if there is no improvement
        if ~improved
            status = :LocalOptimum_LS1
            break
        end
        improved = false

        # Break if time limit is exceeded
        availableTime = timeLimit - (time() - start)
        if availableTime <= 0
            status = :UserLimit
            break
        end

        # Local Search on the space of assignments
        x = localSearchAssignments(estimator, dataset, w, x,
                                   time_limit=availableTime)
        
        # Update w with optimal value
        w = optimalProbMatrix(dataset, x)

        # Evaluate move
        obj_value = calculateObjective(dataset, w, x)

        # Check if there was an improvement
        if obj_value < best_obj
            best_obj = obj_value
            improved = true
        end
        iterations += 1 # Update counter
    end
    solvetime = time() - start;

    # SBM
    sbm = SBM(w, "poisson") # assumes a poisson distribution

    # Build OptResults
    obj_lb = -Inf
    obj_ub = obj_value
    nodecount = nothing
    lazycount = nothing
    opt_results = OptResults(obj_lb, obj_ub, status, solvetime, iterations, nodecount, lazycount)
    if estimator.verbose
        display(opt_results)
    end
    return sbm, x, opt_results
end