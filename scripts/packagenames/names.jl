using DataFrames, UnicodePlots, Test, Random, StatsBase

input = deserialize(joinpath(@__DIR__, "names_df.jls"))
df = input[:df]
col_dict = input[:col_dict]

# naive O(n^2) algorithm
function kendall_tau_distance(σ1, σ2)
    n = length(σ1)
    n == length(σ2) || throw(DimensionMismatch())
    D = 0
    for j = 1:n
        for i = 1:(j-1)
            D += ( (σ1[i] < σ1[j]) & (σ2[i] > σ2[j]) ) |
                ( (σ1[i] > σ1[j]) & (σ2[i] < σ2[j]) )
        end
    end
    return D
end


# Example borrowed from http://arxiv.org/abs/1905.02752
@test kendall_tau_distance([2, 4, 1, 3], [4, 1, 3, 2]) == 5
π = randperm(4)
@test kendall_tau_distance([2, 4, 1, 3][π], [4, 1, 3, 2][π]) == 5

function normalized_kendall_tau_distance(σ1, σ2)
    n = length(σ1)
    2*kendall_tau_distance(σ1, σ2) / (n * (n-1))
end
kendall_tau_coeff(x,y) = 1 - normalized_kendall_tau_distance(x,y)

function corrs(coeff, suffix)
    cols =  [v for (k, v) in pairs(col_dict) if k[2] == suffix ]
    [ coeff(df[!, c1] , df[!, c2])  for c1 in cols, c2 in cols]
end

all_cols = collect(values(col_dict))
sort!(all_cols)
corrs(coeff) = [ coeff(df[!, s1] , df[!, s2])   for s1 in all_cols, s2 in all_cols  ]

suffix = :sqrt_normalized
for coeff in (corkendall, corspearman, kendall_tau_coeff)
    cols =  [v for (k, v) in pairs(col_dict) if k.normalization == suffix ]
    @info cols
    @info "$coeff with $suffix" corrs(coeff, suffix) heatmap(corrs(coeff, suffix))
end

for coeff in (corkendall, corspearman, kendall_tau_coeff)
    @info all_cols
    @info "$coeff" corrs(coeff) heatmap(corrs(coeff))
end


for (k, v) in pairs(col_dict)
    k.normalization == :sqrt_normalized || continue
    if !isempty(k.params)
        k.params.ϵ > .5 && continue
        k.params.ρ > 5 && continue
    end
    n = size(df, 1)

    # Shuffle dataframe
    p = randperm(n)
    for c in propertynames(df)
        permute!(df[!, c], p)
    end

    top5 = sort!(df, v)[1:5, ["name1", "name2", v]]
    num = count(x -> x <= df[5, v], df[!, v])
    @info "$k; showing random top 5 with $(num) candidates to show" top5
end
