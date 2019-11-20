using StochasticBlockModel
using Test

@testset "Dataset struct" begin

    dataset = StochasticBlockModel.Dataset(Matrix([0 1; 1 0]), 2)
    @test dataset.n == 2
    @test dataset.m == 1
    @test dataset.k == [1; 1]

    expected_A = [ 2  1  0  1  0  0  0  0
                    1  2  1  0  1  0  0  1
                    0  1  0  1  1  1  0  0
                    1  0  1  2  0  0  1  0
                    0  1  1  0  2  0  1  0
                    0  0  1  0  0  2  1  1
                    0  0  0  1  1  1  0  1
                    0  1  0  0  0  1  1  2]
    dataset = StochasticBlockModel.Dataset("../instances/g01.in")
    @test dataset.A == expected_A
    @test dataset.n == 8
    @test dataset.m == 19
    @test dataset.n_communities == 2
    @test dataset.k == [4; 6; 4; 5; 5; 5; 4; 5]

    # Test if self-edges correctly count as 2 in the adjacency matrix
    @test_throws ArgumentError StochasticBlockModel.Dataset(Matrix([1 0; 0 0]), 2)
    # Test if negative values in the adjacency matrix cause an Exception
    @test_throws DomainError StochasticBlockModel.Dataset(Matrix([-1 0; 0 0]), 2)
    # Test if zero value in the number of clusters cause an Exception
    @test_throws DomainError StochasticBlockModel.Dataset(Matrix([2 0; 0 0]), 0)
    # Test if negative value in the number of clusters cause an Exception
    @test_throws DomainError StochasticBlockModel.Dataset(Matrix([2 1; 1 0]), -2)

    @test_throws ArgumentError StochasticBlockModel.Dataset(Matrix([2 1; 1 0]), 4, 2, 2, [3; 1])
    @test_throws ArgumentError StochasticBlockModel.Dataset(Matrix([2 1; 1 0]), 2, 4, 2, [3; 1])
    @test_throws DomainError StochasticBlockModel.Dataset(Matrix([-2 1; 1 0]), 2, 2, 2, [3; 1])
    @test_throws DomainError StochasticBlockModel.Dataset(Matrix([2 1; 1 0]), 2, 2, -2, [3; 1])
end
