using StochasticBlockModel
using Test

@testset "OptResults struct" begin

    @test_throws ArgumentError StochasticBlockModel.OptResults(2.0, 1.0, :Optimal, 2.0, 0, 0, 0) # Check LB, UB
    @test_throws ArgumentError StochasticBlockModel.OptResults(2.0, 4.0, :Optimal, 2.0, 0, 0, 0) # Check optimal status
    #@test_throws DomainError StochasticBlockModel.OptResults(2.0, 2.0, :Optimal, 0.0, 0, 0, 0) # Check solvetime domain
    @test_throws DomainError StochasticBlockModel.OptResults(2.0, 2.0, :Optimal, -2.0, 0, 0, 0) # Check solvetime domain
    @test_throws DomainError StochasticBlockModel.OptResults(2.0, 2.0, :Optimal, 2.0, -1, 0, 0) # Check iterations domain
    @test_throws DomainError StochasticBlockModel.OptResults(2.0, 2.0, :Optimal, 2.0, 0, -1, 0) # Check nodecount domain
    @test_throws DomainError StochasticBlockModel.OptResults(2.0, 2.0, :Optimal, 2.0, 0, 0, -1) # Check nodecount domain
end
