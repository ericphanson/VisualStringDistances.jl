module VisualStringDistances

using LinearAlgebra
using UnbalancedOptimalTransport: UnbalancedOptimalTransport, DiscreteMeasure, KL,
                                  sinkhorn_divergence!

using DelimitedFiles
using StaticArrays

export printglyph, word_measure, visual_distance

include("compat.jl")
include("glyphs.jl")
include("glyphcoordinates.jl")
include("glue.jl")

"""
    visual_distance(::Type{T}, s::Union{Char,AbstractString},
                         t::Union{Char,AbstractString}; D=KL(one(T)), ϵ=T(0.1),
                         normalize=nothing) where {T}

Computes a measure of distance between the strings `s` and `t` in terms of their visual representation
as rendered by GNU Unifont and quantified by an unbalanced Sinkhorn divergence from UnbalancedOptimalTransport.jl.

* The keyword argument `D` chooses the `UnbalancedOptimalTransport.AbstractDivergence` used to penalize the creation
  or destruction of "mass" (black pixels). For `D = VisualStringDistances.KL(ρ)` for some number `ρ ≥ 0`,
  the distance is non-negative and zero if and only if the two visual representations of the strings
  are the same, as is generally desired.
* The keyword argument `ϵ` sets the "entropic regularization" in the Sinkhorn divergence; see the
  [documentation](https://ericphanson.github.io/UnbalancedOptimalTransport.jl/stable/optimal_transport/)
  there for more information. In short, smaller `ϵ` computes a quantity more directly related to the cost
  of moving mass, but takes longer to compute.
* The keyword argument `normalize` can be chosen to be a function which returns a normalizing constant
  given the maximum length of the two strings. The choice `normalize=identity` thus divides the result
  by the maximum length of the two strings. The choice `normalize=sqrt` has been found to give
  a good balance in some settings.

One may use [`printglyph`](@ref) to see the visual representation of the strings as rendered by GNU Unifont.

!!! note
    At the time of this writing, GNU Unifont is capable of rendering 57086 different unicode characters.
    However, it renders some unicode characters with the same graphical representation; specifically,
    689 distinct unicode characters have duplicate representations. Here's a set of six duplicates, for
    example: 

    * 'Ꮋ': Unicode U+13BB (category Lu: Letter, uppercase)
    * 'Н': Unicode U+041D (category Lu: Letter, uppercase)
    * 'ꓧ': Unicode U+A4E7 (category Lo: Letter, other)
    * 'Ⲏ': Unicode U+2C8E (category Lu: Letter, uppercase)
    * 'Η': Unicode U+0397 (category Lu: Letter, uppercase)
    * 'H': ASCII/Unicode U+0048 (category Lu: Letter, uppercase)

    The visual distance between these, therefore, is returned as zero (up to numerical error).

## Example

```julia
julia> using VisualStringDistances

julia> printglyph("abc")
------------------------
------------------------
------------------------
---------#--------------
---------#--------------
---------#--------------
--####---#-###----####--
-#----#--##---#--#----#-
------#--#----#--#------
--#####--#----#--#------
-#----#--#----#--#------
-#----#--#----#--#------
-#---##--##---#--#----#-
--###-#--#-###----####--
------------------------
------------------------

julia> printglyph("def")
------------------------
------------------------
------------------------
------#-------------##--
------#------------#----
------#------------#----
--###-#---####-----#----
-#---##--#----#--#####--
-#----#--#----#----#----
-#----#--######----#----
-#----#--#---------#----
-#----#--#---------#----
-#---##--#----#----#----
--###-#---####-----#----
------------------------
------------------------

julia> visual_distance("abc", "def")
31.57060117541754

julia> visual_distance("abc", "abe")
4.979840716647487
```

"""
function visual_distance(::Type{T}, s::Union{Char,AbstractString},
                         t::Union{Char,AbstractString}; D=KL(one(T)), ϵ=T(0.1),
                         normalize=nothing) where {T}
    d = sinkhorn_divergence!(D, word_measure(T, s), word_measure(T, t), ϵ)
    if normalize !== nothing
        d = d / normalize(max(length(s), length(t)))
    end
    return d
end

# `Float64` default.
function visual_distance(s::Union{Char,AbstractString}, t::Union{Char,AbstractString};
                         D=KL(1.0), ϵ=0.1)
    visual_distance(Float64, s, t; D=D, ϵ=ϵ)
end


end
