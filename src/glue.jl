struct ConstantVector{c,T} <: AbstractVector{T}
    len::Int
end
Base.size(v::ConstantVector) = (v.len,)
Base.getindex(::ConstantVector{c,T}, i::Int) where {c,T} = T(c)
Base.sum(v::ConstantVector{c}) where {c} = c * length(v)

LinearAlgebra.dot(::ConstantVector{c}, v::AbstractVector) where {c} = conj(c) * sum(v)
LinearAlgebra.dot(v::AbstractVector, ::ConstantVector{c}) where {c} = c * conj(sum(v))

UnbalancedOptimalTransport.fdot(f, ::ConstantVector{c}, v::AbstractVector) where {c} = conj(c) * sum(f, v)
UnbalancedOptimalTransport.fdot(f, v::AbstractVector, ::ConstantVector{c}) where {c} = conj(sum(v)) * f(c)

function word_measure(s::String; normalize_size = true, normalize_mass = false, T = Float64)
    gc = GlyphCoordinates{T}(s)
    if normalize_size
        sz = SVector{2,T}(gc.sz)
        for i in eachindex(gc.v)
            gc.v[i] = gc.v[i] ./ sz
        end
    end

    n = length(gc)
    if normalize_mass
        DiscreteMeasure(ConstantVector{one(T)/T(n),T}(n), ConstantVector{-log(T(n)),T}(n), gc)
    else
        DiscreteMeasure(ConstantVector{one(T),T}(n), ConstantVector{zero(T),T}(n), gc)
    end
end
