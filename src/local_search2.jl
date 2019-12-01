
function localSearch2(estimator::SBMEstimator, dataset::Dataset)::Tuple{SBM, Matrix{Int}, OptResults}
    """ Local Search 2
    Initialization with random assignments x.
    This local search heuristic works in
    a solution representation-decoder scheme
    The local search (i.e. the search for improving moves) is done
    in the space of assignments x. However, whenever a solution
    is to be evaluated the complete solution is first retrieved,
    by finding the optimal value of w analytically.

    Parameters
    ----------
    estimator : SBMEstimator
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
    n = dataset.n
    q = dataset.n_communities

    timeLimit = estimator.time_limit

    start = time(); # Start counting time

    # Initialize with random assignments
    x = randomAssignments(dataset, seed=estimator.seed)
    w = optimalProbMatrix(dataset, x)

    # Calculate objective value
    obj_value = calculateObjective(dataset, w, x)
    best_solution = (copy(w), copy(x))
    best_obj = obj_value
    best_move = nothing

    status = nothing
    iterations = 0
    improved = true
    while true
        ## Base cases
        # Break if there is no improvement
        if ~improved
            status = :LocalOptimum_LS2
            break
        end
        improved = false

        # Break if time limit is exceeded
        availableTime = timeLimit - (time() - start)
        if availableTime <= 0
            status = :UserLimit
            break
        end
        iterations += 1

        # Find improving relocation move
        improved, best_obj, w, x = findImprovingRelocation(dataset, w, x, true, best_imp=true, time_limit=availableTime)
    end
    solvetime = time() - start;

    # SBM
    sbm = SBM(w, "poisson") # assumes a poisson distribution

    # Build OptResults
    obj_lb = -Inf
    obj_ub = best_obj
    nodecount = nothing
    lazycount = nothing
    opt_results = OptResults(obj_lb, obj_ub, status, solvetime, iterations, nodecount, lazycount)
    if estimator.verbose
        displayResults(opt_results)
    end

    return sbm, x, opt_results
end
