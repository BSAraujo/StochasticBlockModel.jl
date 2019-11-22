using StochasticBlockModel
using Test

@testset "Calculate objective" begin
    A = [0 1 1 0 0 0 0 0;
         1 0 0 1 0 0 0 0;
         1 0 0 1 0 0 0 0;
         0 1 1 0 0 0 0 0;
         0 0 0 0 0 1 1 0;
         0 0 0 0 1 0 0 1;
         0 0 0 0 1 0 0 1;
         0 0 0 0 0 1 1 0]
    dataset = StochasticBlockModel.Dataset(A, 2)
    x = [1 0; 1 0; 1 0; 1 0; 0 1; 0 1; 0 1; 0 1]
    w = StochasticBlockModel.optimalProbMatrix(dataset, x)
    obj = StochasticBlockModel.calculateObjective(dataset, w, x)
    @test w ≈ [2.0 0.0; 0.0 2.0] rtol = 1e-5
    @test obj ≈ 2.4548225555204373 rtol = 1e-5

    x = [1 0; 0 1; 0 1; 1 0; 1 0; 0 1; 0 1; 1 0]
    w = StochasticBlockModel.optimalProbMatrix(dataset, x)
    obj = StochasticBlockModel.calculateObjective(dataset, w, x)
    @test w ≈ [0.0 2.0; 2.0 0.0] rtol = 1e-5
    @test obj ≈ 2.4548225555204373 rtol = 1e-5

    w = [1  0.0; 0.0  1]
    x = [1 0; 1 0; 1 0; 1 0; 0 1; 0 1; 0 1; 0 1]
    @test StochasticBlockModel.calculateObjective(dataset, w, x) == 4

    x = [1 0; 1 0; 1 0; 1 0; 0 1; 0 1; 0 1; 0 1]
    @test StochasticBlockModel.optimalProbMatrix(dataset, x) == [2.0 0.0; 0.0 2.0]

    # Test with a simple graph with 4 nodes and 2 edges
    A = [0 1 0 0;
         1 0 0 0;
         0 0 0 1;
         0 0 1 0]
    dataset = StochasticBlockModel.Dataset(A, 2)
    x = [1 0; 1 0; 0 1; 0 1]
    @test StochasticBlockModel.optimalProbMatrix(dataset, x) ≈ [2.0 0; 0 2.0] rtol = 1e-5
    x = [1 0; 0 1; 1 0; 0 1]
    @test StochasticBlockModel.optimalProbMatrix(dataset, x) ≈ [0.0 2.0; 2.0 0.0] rtol = 1e-5
    w = StochasticBlockModel.optimalProbMatrix(dataset, x)
    @test StochasticBlockModel.calculateObjective(dataset, w, x) ≈ 0.6137056388801094 rtol = 1e-5
    x = [1 0; 0 1; 0 1; 1 0]
    @test StochasticBlockModel.optimalProbMatrix(dataset, x) ≈ [0.0 2.0; 2.0 0.0] rtol = 1e-5
    x = [1 0; 1 0; 1 0; 1 0]
    @test StochasticBlockModel.optimalProbMatrix(dataset, x) ≈ [1.0  0.0; 0.0  0.0] rtol = 1e-5
    x = [1 0; 1 0; 1 0; 0 1]
    @test StochasticBlockModel.optimalProbMatrix(dataset, x) ≈ [0.88888888 1.33333333; 1.33333333 0.0] rtol = 1e-5
    w = StochasticBlockModel.optimalProbMatrix(dataset, x)
    @test StochasticBlockModel.calculateObjective(dataset, w, x) ≈ 1.830100963204603 rtol = 1e-5

    # Graph with self edges
    A = [2 1 0 0;
         1 2 0 0;
         0 0 2 1;
         0 0 1 2]
     dataset = StochasticBlockModel.Dataset(A, 2)
     x = [1 0; 1 0; 0 1; 0 1]
     @test StochasticBlockModel.optimalProbMatrix(dataset, x) ≈ [2.0 0; 0 2.0] rtol = 1e-5
     x = [1 0; 0 1; 1 0; 0 1]
     @test StochasticBlockModel.optimalProbMatrix(dataset, x) ≈ [1.33333333 0.66666666; 0.66666666 1.33333333] rtol = 1e-5
     x = [1 0; 0 1; 0 1; 1 0]
     @test StochasticBlockModel.optimalProbMatrix(dataset, x) ≈ [1.33333333 0.66666666; 0.66666666 1.33333333] rtol = 1e-5
     x = [1 0; 1 0; 1 0; 0 1]
     @test StochasticBlockModel.optimalProbMatrix(dataset, x) ≈ [1.1851851851851851 0.4444444444444444; 0.4444444444444444 2.666666666666666] rtol = 1e-5
     x = [1 0; 1 0; 1 0; 1 0]
     @test StochasticBlockModel.optimalProbMatrix(dataset, x) ≈ [1.0 0.0; 0.0 0.0] rtol = 1e-5
end
