include("plotting.jl")

# animate_words("hello", "heIIo"; D = KL(1.0), save_path=abspath(joinpath(@__DIR__, "hello_heIIo.gif")))
# animate_words("Julia", "Strings"; D = Balanced(), normalize_density=true, save_path=abspath(joinpath(@__DIR__, "julia_strings.gif")), duration=4)
# animate_words("Julia", "distances"; D = Balanced(), normalize_density=true, save_path=abspath(joinpath(@__DIR__, "Julia_distances.gif")))


# animate_words("DifferentialEquations", "DifferentiaIEquations"; D = KL(1.0), save_path=abspath(joinpath(@__DIR__, "DifferentiaIEquations.gif")), duration=4)


# animate_words("FIux", "Flux"; D = KL(5.0), save_path=abspath(joinpath(@__DIR__, "FIux.gif")), duration=4)

# animate_words("Julia", "Visual"; D = KL(1.0), save_path=abspath(joinpath(@__DIR__, "FIux.gif")), duration=4)

animate_words("Julia", "visual"; D = Balanced(), normalize_density=true, save_path=abspath(joinpath(@__DIR__, "julia_visual.gif")), duration=4,
total_frames = 50*4,
pause_frames = 50*4 ÷ 3)

# animate_words("Julia", "visual"; D = KL(5), save_path=abspath(joinpath(@__DIR__, "julia_visual_unbalanced.gif")), duration=4)


# julia> calculate_contributions(KL(5.0), word_measure("Flux"), word_measure("FIux"), 0.1)
# (transport_cost = 4.074841771685898, regularization = 496.6252591146831, marginal_1_penalty = 0.1502096716498963, marginal_2_penalty = 1.2417285590962812)
