using SafeTestsets

@safetestset "SBM tests" begin include("test_sbm.jl") end
@safetestset "Dataset tests" begin include("test_datasets.jl") end
@safetestset "Opt Methods tests" begin include("test_opt_methods.jl") end
@safetestset "Opt Results tests" begin include("test_results.jl") end
@safetestset "Heuristics tests" begin include("test_heuristic.jl") end
@safetestset "Exact tests" begin include("test_exact.jl") end
