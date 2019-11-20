using StochasticBlockModel
using Test

@testset "Dataset struct" begin

    dataset = StochasticBlockModel.Dataset(Matrix([0 1; 1 0]), 2)
    @test dataset.n == 2
    @test dataset.m == 1
    @test dataset.k == [1; 1]

    # Test if self-edges correctly count as 2 edges
    @test_throws ArgumentError StochasticBlockModel.Dataset(Matrix([1 0; 0 0]), 2)
    # Test if negative values in the adjacency matrix cause an Exception
    @test_throws DomainError StochasticBlockModel.Dataset(Matrix([-1 0; 0 0]), 2)
    # Test if zero value in the number of clusters cause an Exception
    @test_throws DomainError StochasticBlockModel.Dataset(Matrix([2 0; 0 0]), 0)
    # Test if negative value in the number of clusters cause an Exception
    @test_throws DomainError StochasticBlockModel.Dataset(Matrix([2 1; 1 0]), -2)

end
