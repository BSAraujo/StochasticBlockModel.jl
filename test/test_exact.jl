using StochasticBlockModel
using Test

@testset "Optimal assignments" begin


    A = [0 1 1 0 0 0 0 0;
         1 0 0 1 0 0 0 0;
         1 0 0 1 0 0 0 0;
         0 1 1 0 0 0 0 0;
         0 0 0 0 0 1 1 0;
         0 0 0 0 1 0 0 1;
         0 0 0 0 1 0 0 1;
         0 0 0 0 0 1 1 0]
    dataset = StochasticBlockModel.Dataset(A, 2)
    sbm = StochasticBlockModel.SBM([2.0 0.0; 0.0 2.0], "poisson")
    opt_results, x = StochasticBlockModel.optimalAssignments(dataset, sbm)
    @test x == [1 0; 1 0; 1 0; 1 0; 0 1; 0 1; 0 1; 0 1]
    @test opt_results.UB ≈ 2.4548225555204373 rtol = 1e-5
    @test opt_results.LB ≈ 2.4548225555204373 rtol = 1e-5
    @test opt_results.status == :Optimal

    estimator = StochasticBlockModel.SBMEstimator("ls1", 10.0, true, 1, false)
    sbm = StochasticBlockModel.SBM([1.3 0.2; 0.2 0.8], "poisson")
    opt_results1, x1 = StochasticBlockModel.optimalAssignments(estimator, dataset, sbm)
    opt_results2, x2 = StochasticBlockModel.optimalAssignments(dataset, sbm, verbose=true)
    @test x1 == x2
end
