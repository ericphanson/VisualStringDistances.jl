module VisualStringDistances

using LinearAlgebra
using UnbalancedOptimalTransport: UnbalancedOptimalTransport, DiscreteMeasure, KL, sinkhorn_divergence!

using CSV: CSV
using StaticArrays
using FreeTypeAbstraction

export Glyph, word_measure, visual_distance

include("compat.jl")
include("glyphs.jl")
include("glyphcoordinates.jl")
include("glue.jl")
include("freetype.jl")

visual_distance(s::AbstractString, t::AbstractString; D = KL(), ϵ = 1.0, kwargs...) =
    sinkhorn_divergence!(D, word_measure(s), word_measure(t), ϵ; kwargs...)
end
