using Pkg, VisualStringDistances
using VisualStringDistances: KL, sinkhorn_divergence!
using StringDistances
using DataFrames
using Transducers

const DL = DamerauLevenshtein()

function get_all_package_names(registry_dir::AbstractString)
    packages = [x["name"] for x in values(Pkg.TOML.parsefile(joinpath(registry_dir, "Registry.toml"))["packages"])]
    sort!(packages)
    unique!(packages)
    return packages
end

names = get_all_package_names(expanduser("~/.julia/registries/General"))

filter!(x -> !endswith(x, "_jll"), names)
@info "Loaded list of non-JLL package names ($(length(names)) names)"

normalized_dl_cutoff = .2
dl_cutoff = 1
@info "Computing list of pairs of package names within $(dl_cutoff) in DL distance or $(normalized_dl_cutoff) in normalized DL distance"
@time df = DataFrame(tcollect( (name1=names[i],name2=names[j]) for i = 1:length(names) for j = 1:(i-1) if (normalize(DL)(names[i], names[j]) <= normalized_dl_cutoff) || DL(names[i], names[j]) <= dl_cutoff))


df.longest_length = max.(length.(df.name1), length.(df.name2))

function compute_sd(df, penalty, ϵ)
    tcollect( sinkhorn_divergence!(penalty, word_measure(df.name1[i]), word_measure(df.name2[i]), ϵ) for i = 1:size(df,1))
end

@info "Computing DL distances for pairs..."
col_dict = Dict{Any, String}()
col = "DL unnormalized"
col_dict[(name = :DL, normalization = :unnormalized, params=tuple())] = col
df[!, col] = DL.(df.name1, df.name2)

i = 0
for ϵ in (0.1, 0.5, 1.0), ρ in (1.0, 5.0, 10.0)
    global i += 1
    @info "($(i)/9) Computing sinkhorn divergences with ϵ=$ϵ, ρ=$ρ..."
    col = "SD ϵ=$(ϵ) ρ=$(ρ) unnormalized"
    col_dict[(name = :SD, normalization = :unnormalized, params=(ϵ=ϵ, ρ=ρ))] = col
    @time df[!, col] = compute_sd(df, KL(ρ), ϵ)
end

@info "Computing normalized distances..."
@time begin
    for ϵ in (0.1, 0.5, 1.0), ρ in (1.0, 5.0, 10.0)
        col = "SD ϵ=$(ϵ) ρ=$(ρ) normalized"
        col_dict[(name = :SD, normalization = :normalized, params=(ϵ=ϵ, ρ=ρ))] = col
        df[!,  col] = df[!, col_dict[(name = :SD, normalization = :unnormalized, params=(ϵ=ϵ, ρ=ρ))]] ./ df[!, :longest_length]

        col = "SD ϵ=$(ϵ) ρ=$(ρ) sqrt normalized"
        col_dict[(name = :SD, normalization = :sqrt_normalized, params=(ϵ=ϵ, ρ=ρ))] = col
        df[!,  col] = df[!, col_dict[(name = :SD, normalization = :unnormalized, params=(ϵ=ϵ, ρ=ρ))]] ./ sqrt.(df[!, :longest_length])
    end
end

col = "DL sqrt normalized"
col_dict[(name = :DL, normalization = :sqrt_normalized, params=tuple())] = col
df[!, col] =  df[!, col_dict[(name = :DL, normalization = :unnormalized, params=tuple())]] ./ sqrt.(df[!, :longest_length])

col = "DL normalized"
col_dict[(name = :DL, normalization = :normalized, params=tuple())] = col
df[!, col] =  df[!, col_dict[(name = :DL, normalization = :unnormalized, params=tuple())]] ./ df[!, :longest_length]


using Serialization
@info "Serializing..."
serialize(joinpath(@__DIR__, "names_df.jls"), Dict{Any, Any}(:df => df, :col_dict => col_dict))

@info "Done!"
