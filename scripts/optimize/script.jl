using UnbalancedOptimalTransport, VisualStringDistances, Metaheuristics, SparseArrays

measure(x) = DiscreteMeasure(x, eachindex(x))

function print_without_summary(io, mat)
    str = sprint(show, MIME"text/plain"(), mat; context=io)
    for line in split(str, '\n')[2:end]
        println(io, line)
    end
end

function visualize(X, target; m=5)
    m = min(m, size(X, 1))
    v = zeros(size(target, 1), 1)
    o = hcat(v, v, v)
    mat = sparse(hcat((hcat(reshape(X[i, :], size(target)), i < m ? v : o) for i in 1:m)..., target))
    return mat
end

function solve_ga(str)
    target = collect(Float64, VisualStringDistances.Glyph(str))
    @show size(target)
    dim = length(target)
    D = UnbalancedOptimalTransport.KL(1.0)

    function f(x)
        # return norm(x - vec(target))
        candidate_measure = measure(reshape(Float64.(x), size(target)...))
        target_measure = measure(target)
        return sinkhorn_divergence!(D, candidate_measure, target_measure; tol=0.1)
    end
    last_call = -Inf

    function parallel_f(X)
        fitness = zeros(size(X, 1))
        @time Threads.@threads for i in 1:size(X, 1)
            fitness[i] = f(X[i, :])
        end
        if time() - last_call > 1
            mat = visualize(X, target; m=5)
            print_without_summary(stdout, mat)
            last_call = time()
        end
        return fitness
    end

    return optimize(parallel_f, BitArraySpace(dim), GA(; N=100, options=Options(; verbose=true, parallel_evaluation=true, store_convergence=true, time_limit=20.0))), target
end

result, target = solve_ga("hi")

for iter in result.convergence
    pop = copy(iter.population)
    # worst to best
    sort!(pop; by = x -> x.f, rev=true)
    m = min(length(pop), 5)
    inds = round.(Int, range(1, length(pop); length=m))
    X = stack(pop[inds[i]].x for i in 1:m; dims=1)
    mat = visualize(X, target; m)
    print_without_summary(stdout, mat)
end
