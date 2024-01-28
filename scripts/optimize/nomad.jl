using UnbalancedOptimalTransport, VisualStringDistances, NOMAD, SparseArrays

target = collect(Float64, VisualStringDistances.Glyph("c"))[5:end, :]
n = Int(sum(target))
candidate = zero(target)
candidate[1:n] .= 1

measure(x) = DiscreteMeasure(x, eachindex(x))
D = UnbalancedOptimalTransport.KL(1.0)


function bb(x)
    candidate = reshape(x, size(target))
    f = sinkhorn_divergence!(D, DiscreteMeasure(candidate, eachindex(candidate)), DiscreteMeasure(target, eachindex(target)))
    success = !isnan(f)
    count_eval = true
    # bb_outputs = [f; sum(x) - sum(target)]
    bb_outputs = [f;]
    return (success, count_eval, bb_outputs)
end

A = ones(1, length(target))
b = [sum(target)]

p = NomadProblem(length(target), 1, ["OBJ"], bb,
    lower_bound=zeros(length(target)),
    upper_bound=ones(length(target)))

p.options.max_time = 60
# p.options.vns_mads_search = true
# p.options.linear_constraints_atol=1e-3
# p.options.linear_converter="QR"
# p.options.lh_search = (100, 0)
# result = solve(p, vec(candidate))
