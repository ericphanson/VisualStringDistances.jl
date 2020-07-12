module VisualStringDistances

using LinearAlgebra
using UnbalancedOptimalTransport: UnbalancedOptimalTransport, DiscreteMeasure, KL,
                                  sinkhorn_divergence!

using DelimitedFiles
using StaticArrays

export Glyph, word_measure, visual_distance

include("compat.jl")
include("glyphs.jl")
include("glyphcoordinates.jl")
include("glue.jl")

function visual_distance(::Type{T}, s::AbstractString, t::AbstractString; D=KL(one(T)), ϵ=T(0.1)) where {T}
    sinkhorn_divergence!(D, word_measure(T, s), word_measure(T, t), ϵ)
end

function visual_distance(s::AbstractString, t::AbstractString; D=KL(1.0), ϵ=0.1)
    visual_distance(Float64, s, t; D=D, ϵ=ϵ)
end

end
