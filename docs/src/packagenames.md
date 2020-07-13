# Package names

One of the motivations for this package was to investigate using visual distances to look out for issues similar
to [typosquatting](https://en.wikipedia.org/wiki/Typosquatting) in the Julia General package registry.

The problem of interest is the following: say a user is following a Julia tutorial online, but a malicious
person has substituted a popular package name for a similiar-looking one in the tutorial. When the unsuspecting
user copy-pastes the commands to install the package, they don't realize they are installing the malicious one.
To prevent this kind of abuse, it could be useful to add an automated check to the registry process to check
that new package registrations' names aren't very close visually to existing packages, and to perhaps
issue a warning when they are.

[`visual_distance`](@ref) provides a means of evaluating how close two strings look. Let's investigate
it in the context of package names.

Let us consider some visually-confusable names, and compute their visual distances, as well as a simple
edit distance (the Damerau-Levenshtein distance).

```@repl pkgnames
using VisualStringDistances, DataFrames, StringDistances
const DL = DamerauLevenshtein();

# Define our distance measure
d(s1, s2) = visual_distance(s1, s2; normalize=x -> 5 + sqrt(x))
d((s1,s2)) = d(s1, s2)

df_subs = DataFrame([
    ("jellyfish", "jeIlyfish"), # https://developer-tech.com/news/2019/dec/05/python-libraries-dateutil-jellyfish-stealing-ssh-gpg-keys/
    ("DifferentialEquations", "DifferentIalEquations"),
    ("ANOVA", "AN0VA"),
    ("ODEInterfaceDiffEq", "0DEInterfaceDiffEq"),
    ("ValueOrientedRiskManagementInsurance", "ValueOrientedRiskManagementlnsurance"),
    ("IsoPkg", "lsoPkg"),
    ("DiffEqNoiseProcess", "DiffEgNoiseProcess"),
    ("Graph500", "Graph5O0")
]);
rename!(df_subs, [:name1, :name2]);
df_subs.DL = DL.(df_subs.name1, df_subs.name2);
df_subs.sqrt_normalized_DL = df_subs.DL ./ ( 5 .+ sqrt.(max.(length.(df_subs.name1), length.(df_subs.name2))) );
df_subs.sqrt_normalized_visual_dist = d.(df_subs.name1, df_subs.name2);
sort!(df_subs, :sqrt_normalized_visual_dist);
```

```@example pkgnames
df_subs
```
We can see all the pairs have DL distance of 1, since they are 1 edit apart. Their normalized
DL-distances thus just depend on their length. However, they have various visual distances,
depending on what subsitution was made. Note that GNU Unifont renders zeros with a slash through
the middle, and hence VisualStringDistances.jl sees "O" and "0" as fairly different.

Let us compare to some real package names from the registry. We will in fact consider all
package names, but then filter them down to a manageable list via the edit distance.

```@repl pkgnames
using Pkg

function get_all_package_names(registry_dir::AbstractString)
    packages = [x["name"] for x in values(Pkg.TOML.parsefile(joinpath(registry_dir, "Registry.toml"))["packages"])]
    sort!(packages)
    unique!(packages)
    return packages
end

names = get_all_package_names(expanduser("~/.julia/registries/General"));

filter!(x -> !endswith(x, "_jll"), names);
@info "Loaded list of non-JLL package names ($(length(names)) names)"

normalized_dl_cutoff = .2;
dl_cutoff = 1;
@info "Computing list of pairs of package names within $(dl_cutoff) in DL distance or $(normalized_dl_cutoff) in normalized DL distance..."
@time df = DataFrame(collect( (name1=names[i],name2=names[j]) for i = 1:length(names) for j = 1:(i-1) if (normalize(DL)(names[i], names[j]) <= normalized_dl_cutoff) || DL(names[i], names[j]) <= dl_cutoff));

@info "Found $(size(df,1)) pairs of packages meeting the criteria.";

df.DL = DL.(df.name1, df.name2);
df.sqrt_normalized_DL = df.DL ./ ( 5 .+ sqrt.(max.(length.(df.name1), length.(df.name2))) );

@info "Computing visual distance...";
@time df.sqrt_normalized_visual_dist = d.(df.name1, df.name2);
```

Let's look at the 5 closest pairs according to the normalized visual distance.
```@example pkgnames
sort!(df, :sqrt_normalized_visual_dist);
df[1:5, :]
```
Here, we see that by this measurement, the closest pair of packages is "Modia"
and "Media". Indeed they look fairly similar, although they are not as easy
to mistake for each other as many of the earlier examples.

Let's compare to the 5 closest pairs according to the normalized edit distance.

```@example pkgnames
sort!(df, :sqrt_normalized_DL);
df[1:5, :]
```

These are just the longest package names that are 1 edit away from each other.
