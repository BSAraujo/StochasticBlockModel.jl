function optimalAssignments(dataset::Dataset, sbm::SBM; time_limit=400, verbose=true)
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
    model = Model(solver=GurobiSolver(TimeLimit=time_limit, OutputFlag=verbose)) # version 0.18 of JuMP

    # Variables
    @variable(model, x[1:n,1:q], Bin);

    # Objective
    @objective(model, Min, sum(
            (W[i,j,g,h] * x[i,g] * x[j,h] )
            for g=1:q, h=1:q, i=1:n, j=1:n));

    # Constraints
    # Assignment constraints
    @constraint(model, con[i = 1:n], sum(x[i,g] for g=1:q) == 1); # assignment constraint

    # Symmetry breaking constraints
    @constraint(model, conObj1, x[1,1] == 1); # object 1 must be in cluster 1
    @constraint(model, conObj[j=2:n], (1 - x[j,2]) <= sum((1 - x[i,1]) for i=2:(j-1)) + x[j,1] ) # if objects 2,...,j-1 are in cluster 1 and object j is not, then object j must be in cluster 2

    # Solve
    status = solve(model) # version 0.18 of JuMP
    solvetime = getsolvetime(model)
    obj_lb = getobjectivebound(model);
    obj_ub = getobjectivevalue(model);
    nodecount = getnodecount(model)
    ############################
    # Recover variable values
    x_opt = getvalue(x)

    opt_results = OptResults(obj_lb, obj_ub, status, solvetime, 0, nodecount, 0)
    if verbose
        display(opt_results)
    end
    return opt_results
end
