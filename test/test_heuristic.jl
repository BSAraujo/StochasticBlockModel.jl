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
    opt_method = StochasticBlockModel.OptMethod("ls1", 10.0, false, 0, false)
    w = StochasticBlockModel.optimalProbMatrix(dataset, x)
    obj_before = StochasticBlockModel.calculateObjective(dataset, w, x)
    # Run local search
    x_ = StochasticBlockModel.localSearchAssignments(opt_method, dataset, w, x)
    w_ = StochasticBlockModel.optimalProbMatrix(dataset, x_)
    obj_after = StochasticBlockModel.calculateObjective(dataset, w_, x_)
    @test x_ == [0 1; 1 0; 1 0; 0 1; 0 1; 1 0; 1 0; 0 1]
    @test obj_after ≈ 2.454822555520437 rtol = 1e-5

end


@testset "Local Search 1" begin

    A = [0 1 1 0 0 0 0 0;
         1 0 0 1 0 0 0 0;
         1 0 0 1 0 0 0 0;
         0 1 1 0 0 0 0 0;
         0 0 0 0 0 1 1 0;
         0 0 0 0 1 0 0 1;
         0 0 0 0 1 0 0 1;
         0 0 0 0 0 1 1 0]
    dataset = StochasticBlockModel.Dataset(A, 2)
    opt_method = StochasticBlockModel.OptMethod("ls1", 10.0, false, 0, false)
    sbm, x, opt_results = StochasticBlockModel.localSearch1(opt_method, dataset)
    @test opt_results.UB ≈ 2.454822555520437 rtol = 1e-5
    @test opt_results.LB == -Inf
end
