# VisualStringDistances

[![Build Status](https://github.com/ericphanson/VisualStringDistances.jl/workflows/CI/badge.svg)](https://github.com/ericphanson/VisualStringDistances.jl/actions)
[![Coverage](https://codecov.io/gh/ericphanson/VisualStringDistances.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/ericphanson/VisualStringDistances.jl)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ericphanson.github.io/VisualStringDistances.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ericphanson.github.io/VisualStringDistances.jl/dev)

Work-in-progress. Quick demo:

```julia
julia> using VisualStringDistances

julia> printglyph("aaa")
------------------------
------------------------
------------------------
------------------------
------------------------
------------------------
--####----####----####--
-#----#--#----#--#----#-
------#-------#-------#-
--#####---#####---#####-
-#----#--#----#--#----#-
-#----#--#----#--#----#-
-#---##--#---##--#---##-
--###-#---###-#---###-#-
------------------------
------------------------


julia> printglyph("ZZZ")
------------------------
------------------------
------------------------
------------------------
-######--######--######-
------#-------#-------#-
------#-------#-------#-
-----#-------#-------#--
----#-------#-------#---
---#-------#-------#----
--#-------#-------#-----
-#-------#-------#------
-#-------#-------#------
-######--######--######-
------------------------
------------------------


julia> visual_distance("aaa","ZZZ")
6.475914720385958

julia> printglyph("III")
------------------------
------------------------
------------------------
------------------------
--#####---#####---#####-
----#-------#-------#---
----#-------#-------#---
----#-------#-------#---
----#-------#-------#---
----#-------#-------#---
----#-------#-------#---
----#-------#-------#---
----#-------#-------#---
--#####---#####---#####-
------------------------
------------------------


julia> printglyph("lll")
------------------------
------------------------
------------------------
---##------##------##---
----#-------#-------#---
----#-------#-------#---
----#-------#-------#---
----#-------#-------#---
----#-------#-------#---
----#-------#-------#---
----#-------#-------#---
----#-------#-------#---
----#-------#-------#---
--#####---#####---#####-
------------------------
------------------------


julia> visual_distance("III","lll")
1.7754034789406319
```

Relies on [UnbalancedOptimalTransport.jl](https://github.com/ericphanson/UnbalancedOptimalTransport.jl) for unbalanced Sinkhorn divergences to define `visual_distance`. See that package's documentation for more information.


*Note*: While this package's source code is MIT licensed, it relies on GNU Unifont, which is GPL-licensed.
