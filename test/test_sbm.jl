using StochasticBlockModel
using Test

@testset "Generate graphs" begin

    expected_A = [0  1  2  1  0  0  0  0
                 1  0  1  1  0  0  0  0
                 2  1  0  1  0  0  0  0
                 1  1  1  2  0  0  0  0
                 0  0  0  0  0  1  2  1
                 0  0  0  0  1  0  1  1
                 0  0  0  0  2  1  0  2
                 0  0  0  0  1  1  2  0]
    @test StochasticBlockModel.generate([1.0 0.0; 0.0 1.0], [4 4], seed=2) == expected_A

    expected_A = [0  1  2  0  0  0
                  1  0  1  0  0  0
                  2  1  0  0  0  0
                  0  0  0  0  1  1
                  0  0  0  1  0  0
                  0  0  0  1  0  2]
    @test StochasticBlockModel.generate([1.0 0.0; 0.0 1.0], [3 3], seed=2) == expected_A

    expected_A = [0  1  1  1  0  0  0  0
                  1  0  1  1  0  0  0  0
                  1  1  0  1  0  0  0  0
                  1  1  1  0  0  0  0  0
                  0  0  0  0  0  1  1  1
                  0  0  0  0  1  0  1  1
                  0  0  0  0  1  1  0  1
                  0  0  0  0  1  1  1  0]
    @test StochasticBlockModel.generate([1.0 0.0; 0.0 1.0], [4 4], distribution="bernoulli", seed=2) == expected_A

    # Test for invalid argument for "distribution"
    @test_throws ArgumentError StochasticBlockModel.generate([1.0 0.0; 0.0 1.0], [4 4], distribution="a", seed=2)

    # Test for invalid argument for "n_per_community"
    @test_throws DomainError StochasticBlockModel.generate([1.0 0.0; 0.0 1.0], [4 -4], distribution="poisson", seed=2)
    @test_throws DomainError StochasticBlockModel.generate([1.0 0.0; 0.0 1.0], [0 2], distribution="bernoulli", seed=2)

    # Test for invalid argument for "probability_matrix"
    @test_throws DomainError StochasticBlockModel.generate([1.0 -0.2; 0.0 1.0], [4 4], distribution="poisson", seed=2)
    @test_throws DomainError StochasticBlockModel.generate([-1.0 0.0; 0.0 1.0], [2 2], distribution="bernoulli", seed=2)
end
