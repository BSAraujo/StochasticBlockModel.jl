using StochasticBlockModel

A = [0 1 1 0 0 0 0 0;
     1 0 0 1 0 0 0 0;
     1 0 0 1 0 0 0 0;
     0 1 1 0 0 0 0 0;
     0 0 0 0 0 1 1 0;
     0 0 0 0 1 0 0 1;
     0 0 0 0 1 0 0 1;
     0 0 0 0 0 1 1 0]

x = [1 0; 0 1; 0 1; 1 0; 1 0; 0 1; 0 1; 1 0]
dataset = StochasticBlockModel.Dataset(A, 2)

w = StochasticBlockModel.optimalProbMatrix(dataset, x)
obj = StochasticBlockModel.calculateObjective(dataset, w, x)
println("Obj = $obj")

sbm = StochasticBlockModel.SBM(w, "poisson")
opt_results = StochasticBlockModel.optimalAssignments(dataset, sbm, time_limit=400, verbose=true)
