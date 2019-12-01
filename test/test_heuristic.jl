using StochasticBlockModel
using Test

@testset "Random assignemnt" begin

    A = [0 1 1 0 0 0 0 0;
         1 0 0 1 0 0 0 0;
         1 0 0 1 0 0 0 0;
         0 1 1 0 0 0 0 0;
         0 0 0 0 0 1 1 0;
         0 0 0 0 1 0 0 1;
         0 0 0 0 1 0 0 1;
         0 0 0 0 0 1 1 0]
    dataset = StochasticBlockModel.Dataset(A, 2)
    x = StochasticBlockModel.randomAssignments(dataset, seed=1)
    @test x == [1 0; 1 0; 0 1; 0 1; 0 1; 1 0; 1 0; 0 1]
    x = StochasticBlockModel.randomAssignments(dataset, seed=2)
    @test x == [1 0; 0 1; 0 1; 0 1; 0 1; 1 0; 0 1; 1 0]

end

@testset "Local Search Assignments" begin

    A = [0 1 1 0 0 0 0 0;
         1 0 0 1 0 0 0 0;
         1 0 0 1 0 0 0 0;
         0 1 1 0 0 0 0 0;
         0 0 0 0 0 1 1 0;
         0 0 0 0 1 0 0 1;
         0 0 0 0 1 0 0 1;
         0 0 0 0 0 1 1 0]
    dataset = StochasticBlockModel.Dataset(A, 2)
    x = StochasticBlockModel.randomAssignments(dataset, seed=1)
    estimator = StochasticBlockModel.SBMEstimator("ls1", 10.0, false, 0, false)
    w = StochasticBlockModel.optimalProbMatrix(dataset, x)
    obj_before = StochasticBlockModel.calculateObjective(dataset, w, x)
    # Run local search
    x_ = StochasticBlockModel.localSearchAssignments(estimator, dataset, w, x)
    w_ = StochasticBlockModel.optimalProbMatrix(dataset, x_)
    obj_after = StochasticBlockModel.calculateObjective(dataset, w_, x_)
    @test x_ == [0 1; 1 0; 1 0; 0 1; 0 1; 1 0; 1 0; 0 1]
    @test obj_after ≈ 2.454822555520437 rtol = 1e-5

end


@testset "Local Search Methods" begin

    A = [0 1 1 0 0 0 0 0;
         1 0 0 1 0 0 0 0;
         1 0 0 1 0 0 0 0;
         0 1 1 0 0 0 0 0;
         0 0 0 0 0 1 1 0;
         0 0 0 0 1 0 0 1;
         0 0 0 0 1 0 0 1;
         0 0 0 0 0 1 1 0]
    dataset = StochasticBlockModel.Dataset(A, 2)
    estimator = StochasticBlockModel.SBMEstimator("ls1", 10.0, false, 0, false)
    sbm, x, opt_results = StochasticBlockModel.localSearch1(estimator, dataset)
    @test opt_results.UB ≈ 2.454822555520437 rtol = 1e-5
    @test opt_results.LB == -Inf

    estimator = StochasticBlockModel.SBMEstimator("ls2", 10.0, false, 0, false)
    sbm, x, opt_results = StochasticBlockModel.localSearch2(estimator, dataset)
    @test opt_results.UB ≈ 2.454822555520437 rtol = 1e-5
    @test opt_results.LB == -Inf


    dataset = StochasticBlockModel.Dataset("../instances/RW/zachary.in")
    estimator = StochasticBlockModel.SBMEstimator("ls1", 10.0, false, 0, false)
    sbm, x, opt_results = StochasticBlockModel.localSearch1(estimator, dataset)
    time_ls1 = opt_results.solvetime
    @test opt_results.UB ≈ 67.88545219325196 rtol = 1e-5
    @test opt_results.LB == -Inf
    @test opt_results.status == :LocalOptimum_LS1
    @test sbm.w ≈ [0.57483 1.49603; 1.49603 0.421296] rtol = 1e-5

    estimator = StochasticBlockModel.SBMEstimator("ls2", 10.0, false, 0, false)
    sbm, x, opt_results = StochasticBlockModel.localSearch2(estimator, dataset)
    @test opt_results.UB ≈ 63.973982362428586 rtol = 1e-5
    @test opt_results.LB == -Inf
    @test opt_results.status == :LocalOptimum_LS2
    # @test time_ls1 < opt_results.solvetime
    @test sbm.w ≈ [0.518201 1.5768; 1.5768 0.309462] rtol = 1e-5

end


@testset "Local Search 2" begin

    A = [0 1 1 0 0 0 0 0;
         1 0 0 1 0 0 0 0;
         1 0 0 1 0 0 0 0;
         0 1 1 0 0 0 0 0;
         0 0 0 0 0 1 1 0;
         0 0 0 0 1 0 0 1;
         0 0 0 0 1 0 0 1;
         0 0 0 0 0 1 1 0]
    dataset = StochasticBlockModel.Dataset(A, 2)
    estimator = StochasticBlockModel.SBMEstimator("ls2", 10.0, false, 0, false)
    sbm, x, opt_results = StochasticBlockModel.localSearch2(estimator, dataset)
    @test opt_results.UB ≈ 2.454822555520437 rtol = 1e-5
    @test opt_results.LB == -Inf
end
