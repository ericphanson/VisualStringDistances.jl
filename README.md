# VisualStringDistances

[![Build Status](https://github.com/ericphanson/VisualStringDistances.jl/workflows/CI/badge.svg)](https://github.com/ericphanson/VisualStringDistances.jl/actions)
[![Coverage](https://codecov.io/gh/ericphanson/VisualStringDistances.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/ericphanson/VisualStringDistances.jl)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ericphanson.github.io/VisualStringDistances.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ericphanson.github.io/VisualStringDistances.jl/dev)

Provides a notion of "visual distance" between two strings, via the exported function `visual_distance`.

This package was the subject of the 2020 JuliaCon talk [How similar do two strings look? Visual distances in Julia](https://www.youtube.com/watch?v=hf2b9ganGxE),
so check that out if you like video explanations and animated gifs. For a text explanation, keep reading.

There are lots of ways to calculate distances between strings; [StringDistances.jl](https://github.com/matthieugomez/StringDistances.jl)
includes many of them, including edit distances which count how many "edits" of various kinds are needed to turn one string into another.

This package provides a distance measure via a very different mechanism. It tries to quantify how visually different two strings *look*.
It does this by rendering both strings with a font (GNU Unifont, in this case) to get a pixel bitmap, i.e. a matrix of 0s and 1s indicating
which pixels should be colored white or black in order to display a representation of the string.

Then these bitmaps are compared by a technique called *optimal transport*. In this technique, we see the 1s as units of mass setting at various
locations (corresponding to their indices in the matrix). We ask: how much mass do we need to move, and how far,
to turn the first bitmap into the second? We can formulate this as an optimization problem and solve it to give a notion of distance.

One subtlety we need to address is that if two strings have different amounts of black pixels in their bitmap, we cannot simply move mass around
to turn one bitmap into the other. We in fact need to create or destroy mass. We do this by adding a penalty term in our optimization problem
corresponding to creation or destruction of mass.

The actual optimization is performed by [UnbalancedOptimalTransport.jl](https://github.com/ericphanson/UnbalancedOptimalTransport.jl), and
the [docs](https://ericphanson.github.io/UnbalancedOptimalTransport.jl/stable/optimal_transport/)
for that package go into a lot more detail about optimal transport. In particular, we are actually computing the Sinkhorn divergence
corresponding to an entropically-regularized unbalanced optimal transport problem, following the algorithm of [SFVTP19].

[SFVTP19] Séjourné, T., Feydy, J., Vialard, F.-X., Trouvé, A., Peyré, G., 2019. Sinkhorn Divergences for Unbalanced Optimal Transport. [arXiv:1910.12958](https://arxiv.org/abs/1910.12958).


*Note*: While this package's source code is MIT licensed, it relies on GNU Unifont, which is GPL-licensed.

## Quick demo

```julia
julia> using VisualStringDistances

julia> printglyph("aaa")






  ####    ####    ####
 #    #  #    #  #    #
      #       #       #
  #####   #####   #####
 #    #  #    #  #    #
 #    #  #    #  #    #
 #   ##  #   ##  #   ##
  ### #   ### #   ### #



julia> printglyph("aaa")






  ####    ####    ####
 #    #  #    #  #    #
      #       #       #
  #####   #####   #####
 #    #  #    #  #    #
 #    #  #    #  #    #
 #   ##  #   ##  #   ##
  ### #   ### #   ### #



julia> printglyph("ZZZ")




 ######  ######  ######
      #       #       #
      #       #       #
     #       #       #
    #       #       #
   #       #       #
  #       #       #
 #       #       #
 #       #       #
 ######  ######  ######



julia> visual_distance("aaa", "ZZZ")
51.169602195312166

julia> printglyph("III")




  #####   #####   #####
    #       #       #
    #       #       #
    #       #       #
    #       #       #
    #       #       #
    #       #       #
    #       #       #
    #       #       #
  #####   #####   #####



julia> printglyph("lll")



   ##      ##      ##
    #       #       #
    #       #       #
    #       #       #
    #       #       #
    #       #       #
    #       #       #
    #       #       #
    #       #       #
    #       #       #
  #####   #####   #####



julia> visual_distance("III", "lll")
9.7349485622592

```
