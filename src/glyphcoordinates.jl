
"""
    GlyphCoordinates{T} <: AbstractVector{T}

A sparse representation of a [`Glyph`](@ref).
"""
struct GlyphCoordinates{T} <: AbstractVector{T}
    v::Vector{SVector{2,T}}
    sz::Tuple{Int,Int}
end

Base.size(g::GlyphCoordinates) = size(g.v)
Base.getindex(g::GlyphCoordinates, i::Int) = getindex(g.v, i)
Base.getindex(g::GlyphCoordinates, I...) = getindex(g.v, I...)
Base.IndexStyle(g::GlyphCoordinates) = IndexLinear()

GlyphCoordinates(args...) = GlyphCoordinates{Float64}(args...)

function GlyphCoordinates{T}(g::Glyph) where {T}
    GlyphCoordinates([SVector{2,T}(Tuple(ci))
                      for ci in CartesianIndices(g) if !iszero(g[ci])], size(g))
end

const COORDS_CACHE = Dict{Char,GlyphCoordinates{Float64}}()

function GlyphCoordinates{Float64}(c::Char)
    get!(COORDS_CACHE, c) do
        GlyphCoordinates{Float64}(Glyph(c))
    end
end

# fallback for generic types
GlyphCoordinates{T}(c::Char) where {T} = GlyphCoordinates{T}(Glyph(c))

# Use the character cache `COORDS_CACHE`
function GlyphCoordinates{T}(s::String) where {T}
    gcs = [GlyphCoordinates{T}(c) for c in s]
    L = sum(length, gcs)
    v = Vector{SVector{2,T}}(undef, L)
    shift = SVector{2,Int}(0, 0)
    j = 1
    for gc in gcs
        l = length(gc.v)
        v[j:j+l-1] .= gc.v .+ Ref(shift)
        j += l
        shift += SVector{2,Int}(0, gc.sz[2])
    end
    GlyphCoordinates{T}(v, Tuple(shift + SVector(16, 0)))
end

function printglyph(io, g::GlyphCoordinates{T}) where {T}
    for r = 1:g.sz[1]
        for c = 1:g.sz[2]
            if SVector{2,T}(r, c) ∈ g.v
                print(io, "#")
            else
                print(io, "-")
            end
        end
        println(io)
    end
end
