import StochasticBlockModel
using Test

@testset "StochasticBlockModel.jl" begin

    expected_A = [0  1  2  1  0  0  0  0
                 1  0  1  1  0  0  0  0
                 2  1  0  1  0  0  0  0
                 1  1  1  2  0  0  0  0
                 0  0  0  0  0  1  2  1
                 0  0  0  0  1  0  1  1
                 0  0  0  0  2  1  0  2
                 0  0  0  0  1  1  2  0]
    @test StochasticBlockModel.generatePoissonSBM([1.0 0.0; 0.0 1.0], [4 4], seed=2) == expected_A

    expected_A = [0  1  2  0  0  0
                  1  0  1  0  0  0
                  2  1  0  0  0  0
                  0  0  0  0  1  1
                  0  0  0  1  0  0
                  0  0  0  1  0  2]
    @test StochasticBlockModel.generatePoissonSBM([1.0 0.0; 0.0 1.0], [3 3], seed=2) == expected_A

end
