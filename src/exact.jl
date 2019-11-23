function optimalAssignments(opt_method::OptMethod, dataset::Dataset, sbm::SBM; time_limit::Float64=400.0)
    return optimalAssignments(dataset, sbm, time_limit=time_limit, verbose=opt_method.verbose)
end

function optimalAssignments(dataset::Dataset, sbm::SBM; time_limit::Float64=400.0, verbose::Bool=false)
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
    end

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
    model = Model(solver=GLPKSolverMIP()) # version 0.18 of JuMP

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
    obj_ub = getobjectivevalue(model);
    iterations = nothing
    nodecount = nothing
    lazycount = nothing
    ############################
    # Recover variable values
    x_opt = getvalue(x)

    opt_results = OptResults(obj_lb, obj_ub, status, solvetime, iterations, nodecount, lazycount)
    if verbose
        display(opt_results)
    end
    return opt_results, x_opt
end


function MINLP(opt_method::OptMethod, dataset::Dataset)
    throw("not implemented")
end
