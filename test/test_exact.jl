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

end
