struct Dataset
    A::Matrix{Int}          # Adjacency matrix of an observed graph
    n::Int                  # Number of nodes in the graph
    m::Int                  # Number of edges in the graph
    n_communities::Int      # Number of communities to be recovered
    k::Vector{Int}          # Degrees of each node

    # Constructor function for struct Dataset
    function Dataset(A::Matrix{Int}, q::Int)
        if any(A .< 0)
            throw(DomainError("Adjacency matrix A must have only non-negative integer elements."))
        end
        if q <= 0
            throw(DomainError("Number of communities/clusters q must be a positive integer value."))
        end
        if ~all([A[i,i] for i=1:size(A,1)] .% 2 .== 0)
            throw(ArgumentError("Self-edges should count as 2. Please check the elements in the diagonal of the adjacency matrix."))
        end
        n = size(A,1)
        m = Int(sum(A)/2)
        k = vec(sum(A, dims=1))
        return Dataset(A, n, m, q, k)
    end

    function Dataset(dataset_path::String)
        return loadDataset(dataset_path)
    end

    function Dataset(A::Matrix{Int}, n::Int, m::Int, q::Int, k::Vector{Int})
        if any(A .< 0)
            throw(DomainError("Adjacency matrix A must have only non-negative integer elements."))
        end
        if (size(A,1) != n)
            throw(ArgumentError("The size of the adjacency matrix A must match the specified number of nodes n=$n"))
        end
        if (sum(A)/2 != m)
            throw(ArgumentError("Number of edges in adjacency matrix A does not match the specified value of m=$m."))
        end
        if (A != A')
            throw(ArgumentError("Adjacency matrix must be symmetric."))
        end
        if q <= 0
            throw(DomainError("Number of communities/clusters q must be a positive integer value."))
        end
        # TODO: check if matrix A follows the convention that self edges count as 2
        return new(A, n, m, q, k)
    end
end


function loadDataset(dataset_path::String)::Dataset
    lines = readlines(dataset_path)
    n,m,q = map(x->parse(Int,x), split(lines[1],","))
    A = Matrix(zeros(Int,n,n))
    for line in lines[2:end]
        i,j = map(x->parse(Int,x), split(line,","))
        A[i,j] += 1
    end
    A = A + A'
    k = vec(sum(A, dims=1)) # get node degree of each node
    dataset = Dataset(A, n, m, q, k)
    return dataset
end


function saveDataset(dataset::Dataset, path::String)
    firstline = string(join([dataset.n, dataset.m, dataset.n_communities], ","),"\n")
    open(path, "w") do f
        # Write fist line to file
        write(f, firstline)
        # Write edges as edge list
        for i=1:dataset.n, j=i:dataset.n
            n_edges = dataset.A[i,j]
            if i == j
                n_edges = Int(n_edges / 2)
            end
            for w in 1:n_edges
                write(f, "$i,$j\n")
            end
        end
    end
end


function loadKarate()
    dataset_path = "../instances/zachary.in"
    return Dataset(dataset_path)
end
