
function localSearch3(estimator::SBMEstimator, dataset::Dataset)::Tuple{SBM, Matrix{Int}, OptResults}
    """ Local Search 3
    1. Initialize with random assignments;
    2. Solve analytically for the optimal probability matrix w;
    3. Solve quadratic program for the optimal assignments, given w;
    4. Repeat step 2, until no more improvement can be made.

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
    timeLimit = estimator.time_limit

    start = time(); # Start counting time

    # Initialize with random assignments
    x = randomAssignments(dataset, seed=estimator.seed)
    w = optimalProbMatrix(dataset, x)

    # Calculate objective value
    obj_value = calculateObjective(dataset, w, x)
    best_obj = obj_value

    status = nothing
    iterations = 0
    improved = true
    while true
        ## Base cases
        # Break if there is no improvement
        if ~improved
            status = :LocalOptimum_LS3
            break
        end
        improved = false

        # Break if time limit is exceeded
        availableTime = timeLimit - (time() - start)
        if availableTime <= 0
            status = :UserLimit
            break
        end

        # Optimal Assignments
        sbm = SBM(w, "poisson")
        assignment_results, x_opt = optimalAssignments(dataset, sbm, time_limit=availableTime,
                                                       verbose=estimator.verbose)
        if assignment_results.status == :Optimal
            x = x_opt
        end

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
