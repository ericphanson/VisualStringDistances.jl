# # How similar do two strings look? Visual distances in Julia

# <img src="assets/julia_strings.gif" style="width: 90%" class="center" />

# ---

# ## Let's compare strings

using StringDistances
str1 = "Julia"; str2 = "JuIia"; str3 = "JuQia"
(str1, str2, str3)

# How many single-character edits are needed to turn `str1` into `str2`?

StringDistances.Levenshtein()(str1, str2)

# What about `str1` into `str3`?
StringDistances.Levenshtein()(str1, str3)


# We can also compare based on how many times consecutive pairs of letters appear in each string...

StringDistances.QGram(2)(str1, str2), StringDistances.QGram(2)(str1, str3)

# ---
# # Visual distances

# But none of these take into account that `str1` and `str2` look pretty similar, while `str1` and `str3` look pretty different.

using VisualStringDistances: VisualStringDistances
const VSD = VisualStringDistances
VSD.visual_distance(str1, str2), VSD.visual_distance(str1, str3)

# That seems better! But how do we know it does something reasonable in other cases too? And how does it work?

# Just need two tools:
# 1. A way to translate strings into images
# 2. A way to compare images

# ---

# ## 1. A way to translate strings into images: GNU Unifont

VSD.printglyph("GNU Unifont"; symbols=("#", "-"))

# It is low resolution, but simple and comprehensive, with 57086 supported characters, including...

chars = [VSD.get_char(k) for k in rand(collect(keys(VSD.UNIFONT_LOOKUP)), 5)];
permutedims(chars)

# ---

# Which render as:

VSD.printglyph(join(chars, " "))

# ---

# Unifont lets easily render characters to bitmaps (see also FreeTypeAbstraction.jl to do this with many fonts!):

VSD.Glyph("Julia")


# ---

# ## 2. A way to compare images: Optimal transport

# * you have $a(1)$ amount of stuff at site $x_1$, $a(2)$ amount of stuff at $x_2$, ..., $a(n)$ stuff at $x_n$.
# * you want to move it around until you have $b(1)$ stuff at site $y_1$, $b(2)$ stuff at $y_2$, ..., $b(m)$ stuff at $y_m$
# * it costs $c(x_i, y_j)$ to move one unit of mass from $x_i$ to $y_j$

# ```math
# \begin{aligned}
# \operatorname{OT}(a,b) := \text{minimize} \quad & \sum\_{x,y} π(x,y) c(x,y)\\\\
# \text{such that} \quad & a(x) = \sum\_{y} \pi(x,y)\\\\
# & b(y) = \sum\_{x} \pi(x,y) \\\\
# & \pi(x,y) \geq 0 
# \end{aligned}
# ```

# If we have a black pixel in the 3rd column and 2nd row of the matrix, we can see that as $a(1) = 1$ unit of mass at site $x_1 = (2,3)$.
# In this way, we can translate the bitmap representation of the string into the language of optimal transport.
#
# This isn't my idea! It's used quite a lot in the imaging community (look up "Wasserstein GANs").

