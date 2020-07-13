using Random, Pkg, VisualStringDistances

# Define our distance measure
d(s1, s2) = visual_distance(s1, s2; normalize=x -> 2 + sqrt(x))
d((s1,s2)) = d(s1, s2)

confusable_names = [
    ("DifferentialEquations", "DifferentIalEquations"),
    ("jellyfish", "jeIlyfish"), # example from python
    ("ANOVA", "AN0VA"),
    ("ODEInterfaceDiffEq", "0DEInterfaceDiffEq"),
    ("ValueOrientedRiskManagementInsurance", "ValueOrientedRiskManagementlnsurance"),
    ("IsoPkg", "lsoPkg"),
    ("DiffEqNoiseProcess", "DiffEgNoiseProcess"),
    ("Graph500", "Graph5O0")
]
@show d.(confusable_names)

function get_all_package_names(registry_dir::AbstractString)
    packages = [x["name"] for x in values(Pkg.TOML.parsefile(joinpath(registry_dir, "Registry.toml"))["packages"])]
    sort!(packages)
    unique!(packages)
    return packages
end

names = get_all_package_names(expanduser("~/.julia/registries/General"))
filter!(x -> !endswith(x, "_jll"), names)


confusable = ["O" => "0", "I" => "l", "I" => "1", "g" => "q"]
append!(confusable, reverse.(confusable))

function gen_list(names; N = 10)
    list = Tuple{String, String}[]
    while length(list) < N
        name = rand(names)
        swap = rand(confusable)
        if occursin(first(swap), name)
            new_name = replace(name, swap; count=1)
            push!(list, (name, new_name))
        end
    end
    return list
end

list = gen_list(names)
dists = d.(list)
dist, idx = findmax(dists)
@show dist, list[idx]
