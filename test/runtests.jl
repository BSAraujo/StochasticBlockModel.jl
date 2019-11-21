using SafeTestsets

@safetestset "SBM tests" begin include("test_sbm.jl") end
@safetestset "Dataset tests" begin include("test_datasets.jl") end
@safetestset "Opt Methods tests" begin include("test_opt_methods.jl") end
