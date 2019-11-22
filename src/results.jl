struct OptResults
    LB::Float64             # Lower Bound on the objective
    UB::Float64             # Upper Bound on the objective
    status::Any             # Status
    solvetime::Float64      # Solve time in seconds
    iterations::Int         # Number of iterations (for local search)
    nodecount::Int          # Node count of the Branch-and-Bound tree
    lazycount::Int          # Number of lazy constraints added during solving

    function OptResults(lb::Float64, ub::Float64, status::Any, solvetime::Float64, iterations::Int, nodecount::Int, lazycount::Int)
        if ~(lb <= ub)
            throw(ArgumentError("Lower Bound value must be less than or equal to Upper Bound."))
        end
        if solvetime <= 0
            throw(DomainError("Solve time must be a positive number in seconds."))
        end
        if iterations < 0
            throw(DomainError("Number of iterations must be a positive integer number."))
        end
        if nodecount < 0
            throw(DomainError("Number of nodes in B&B must be a non-negative integer number."))
        end
        if lazycount < 0
            throw(DomainError("Number of lazy constraints added must be a non-negative integer number."))
        end

        new(lb, ub, status, solvetime, iterations, nodecount, lazycount)
    end
end

function display(opt_results::OptResults)
    print(string("\n",
          "--------------- Opt Results ---------------\n",
          "Obj. LB = ",round(opt_results.LB, digits=5),"\n",
          "Obj. UB = ",round(opt_results.UB, digits=5),"\n",
          "Status: $(opt_results.status)\n",
          "Solve time: ",round(opt_results.solvetime, digits=5)," seconds\n",
          "Iterations: $(opt_results.iterations)\n",
          "Number of nodes: $(opt_results.nodecount)\n",
          "Number of lazy constraints: $(opt_results.lazycount)\n"))
end

function write(opt_results::OptResults, path::String; oneline::Bool=false, header::Bool=false)
    throw("not implemented")
end
