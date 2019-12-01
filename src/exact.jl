function optimalAssignments(estimator::SBMEstimator, dataset::Dataset, sbm::SBM; time_limit::Float64=400.0)::Tuple{OptResults, Matrix{Int}}
    return optimalAssignments(dataset, sbm, time_limit=time_limit, verbose=estimator.verbose)
end

function optimalAssignments(dataset::Dataset, sbm::SBM; time_limit::Float64=400.0, verbose::Bool=false)::Tuple{OptResults, Matrix{Int}}
    """
    Solves the SBM optimization problem with its descriptive formulation,
    given the matrix of probabilities w.

    Parameters
    ----------
    dataset : Dataset
        Dataset representing an observed graph.
    sbm : SBM
        Stochastic Block Model

    Returns
    -------
    (obj_value, elapsed, x_opt) : type
        Value of objective, elapsed time, and optimal values for x
    """
    A = dataset.A
    q = dataset.n_communities
    n = dataset.n
    m = dataset.m
    k = dataset.k
    w = sbm.w

    if verbose
        println("q = $q groups\nn = $n nodes\nm = $m edges");
        println("w=")
        println(w)
        println("Time limit: $time_limit seconds")
    end

    # convert from seconds to milli-seconds
    time_limit = Int(round(time_limit*1000))

    w[w .== 0] .= 1e-30
    W = zeros(n,n,q,q);
    for i=1:n, j=1:n, g=1:q, h=1:q
        if A[i,j] != 0
            W[i,j,g,h] = 0.5*( -A[i,j]*log(w[g,h]) + ((k[i]*k[j])/(2*m))*w[g,h] )
        else
            W[i,j,g,h] = 0.5*((k[i]*k[j])/(2*m))*w[g,h]
        end
    end

    ############################
    # TODO: set time limit and verbose options
    model = Model(solver=GLPKSolverMIP(tm_lim=time_limit)) # version 0.18 of JuMP

    # Variables
    @variable(model, 0 <= y[1:n,1:n,1:q,1:q] <= 1)
    @variable(model, x[1:n,1:q], Bin);

    # Objective
    @objective(model, Min, sum(
            (W[i,j,g,h] * y[i,j,g,h])
            for g=1:q, h=1:q, i=1:n, j=1:n));

    # Constraints
    @constraint(model, con1[i=1:n, j=1:n, g=1:q, h=1:q], x[i,g] - y[i,j,g,h] >= 0)
    @constraint(model, con2[i=1:n, j=1:n, g=1:q, h=1:q], x[j,h] - y[i,j,g,h] >= 0)
    @constraint(model, con3[i=1:n, j=1:n, g=1:q, h=1:q], 1 - x[i,g] - x[j,h] + y[i,j,g,h] >= 0)

    # Assignment constraints
    @constraint(model, assign[i = 1:n], sum(x[i,g] for g=1:q) == 1); # assignment constraint

    # Symmetry breaking constraints
    @constraint(model, conObj1, x[1,1] == 1); # object 1 must be in cluster 1
    @constraint(model, conObj[j=2:n], (1 - x[j,2]) <= sum((1 - x[i,1]) for i=2:(j-1)) + x[j,1] ) # if objects 2,...,j-1 are in cluster 1 and object j is not, then object j must be in cluster 2

    # Solve
    start = time()
    status = solve(model) # version 0.18 of JuMP
    solvetime = time() - start
    obj_lb = getobjectivebound(model);
    if isnan(obj_lb)
        obj_lb = -Inf
    end
    obj_ub = getobjectivevalue(model);
    if isnan(obj_ub)
        obj_ub = Inf
    end
    iterations = nothing
    nodecount = nothing
    lazycount = nothing
    ############################
    # Recover variable values
    x = getvalue(x)
    x = round.(x[:,:])
    x[map(v -> isnan(v) , x)] .= 0 # replace NaN values with 0
    x = Int.(x)

    opt_results = OptResults(obj_lb, obj_ub, status, solvetime, iterations, nodecount, lazycount)
    if verbose
        displayResults(opt_results)
    end
    return opt_results, x
end


function MINLP(estimator::SBMEstimator, dataset::Dataset)
    throw("not implemented")
end
