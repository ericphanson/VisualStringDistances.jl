struct ConstantVector{c,T} <: AbstractVector{T}
    len::Int
end
Base.size(v::ConstantVector) = (v.len,)
Base.getindex(::ConstantVector{c,T}, i::Int) where {c,T} = T(c)
Base.sum(v::ConstantVector{c}) where {c} = c * length(v)

LinearAlgebra.dot(::ConstantVector{c}, v::AbstractVector) where {c} = conj(c) * sum(v)
LinearAlgebra.dot(v::AbstractVector, ::ConstantVector{c}) where {c} = c * conj(sum(v))

function UnbalancedOptimalTransport.fdot(f, ::ConstantVector{c},
                                         v::AbstractVector) where {c}
    conj(c) * sum(f, v)
end
function UnbalancedOptimalTransport.fdot(f, v::AbstractVector,
                                         ::ConstantVector{c}) where {c}
    conj(sum(v)) * f(c)
end

function word_measure(::Type{T}, s::Union{Char,AbstractString}) where {T}
    gc = GlyphCoordinates{T}(s)
    n = length(gc)
    DiscreteMeasure(ConstantVector{one(T),T}(n), ConstantVector{zero(T),T}(n), gc)
end

word_measure(s::Union{Char,AbstractString}) = word_measure(Float64, s)
