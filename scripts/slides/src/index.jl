# # How similar do two strings look?

# ## VisualStringDistances.jl

# <img src="assets/julia_visual.gif" style="width: 65%" class="center" />

# ---

# ## Let's compare strings

# <br />

using StringDistances

# How many single-character edits are needed to turn "Julia" into "JuIia"?

StringDistances.Levenshtein()("Julia", "JuIia")

# What about "Julia" into "JuQia"?

StringDistances.Levenshtein()("Julia", "JuQia")


# We can also compare based on how many times consecutive pairs of letters appear in each string...

StringDistances.QGram(2)("Julia", "JuIia"), StringDistances.QGram(2)("Julia", "JuQia")

# ---
# ## Visual distances

# <br />


# But none of these take into account that "Julia" and "JuIia" look pretty similar, while "Julia" and "JuQia" look pretty different.

using VisualStringDistances: VisualStringDistances
const VSD = VisualStringDistances
VSD.visual_distance("Julia",  "JuIia"), VSD.visual_distance("Julia", "JuQia")

# <br />

# That seems better! But how do we know it does something reasonable in other cases too? And how does it work?

# <br />

# Just need two tools:
# 1. <p> A way to translate strings into images </p>
# 2. <p> A way to compare images </p>

# ---

# ## 1. A way to translate strings into images: GNU Unifont

VSD.printglyph("GNU Unifont"; symbols=("#", "-"))

# A bitmap font!

# ---

# Unifont stores characters as bitmaps, making things quite easy for us:

VSD.Glyph("Julia")

# <br />

# (see also FreeTypeAbstraction.jl to render bitmaps from many fonts!)

# ---

# It is low resolution, but simple and comprehensive, with 57086 supported characters, including...

chars = [VSD.get_char(k) for k in rand(collect(keys(VSD.UNIFONT_LOOKUP)), 5)];
permutedims(chars)

# Which render as:

VSD.printglyph(join(chars, " "))

# ---

VSD.printglyph("Julia vs JuIia"); VSD.printglyph("Julia vs JuQia") # hide

# ---

# ## 2. A way to compare images: Optimal transport

# <br />

# * <p> you have $a(x_1)$ amount of stuff at site $x_1$, $a(x_2)$ amount of stuff at $x_2$, ..., $a(x_n)$ stuff at $x_n$. </p>
# * <p> you want to move it around until you have $b(y_1)$ stuff at site $y_1$, $b(y_2)$ stuff at $y_2$, ..., $b(y_m)$ stuff at $y_m$ </p>
# * <p> it costs $c(x_i, y_j)$ to move one unit of mass from $x_i$ to $y_j$ </p>

# ```math
# \begin{aligned}
# \operatorname{OT}(a,b) := \text{minimize} \quad & \sum\_{x,y} π(x,y)\, c(x,y)\\\\
# \text{such that} \quad & a(x) = \sum\_{y} \pi(x,y)\\\\
# & b(y) = \sum\_{x} \pi(x,y) \\\\
# & \pi(x,y) \geq 0 
# \end{aligned}
# ```

# * <p> We optimize to find the variables $\pi(x,y)$ (how much stuff to move from $x$ to $y$) </p>

# ---

# ## How does optimal transport relate to our problem?

# <br />

# - <p> If we have a black pixel in the 3rd column and 2nd row of the bitmap, we can see that as $a(1) = 1$ unit of mass at site $x_1 = (2,3)$. </p>
# - <p> In this way, we can translate the bitmap representation of the string into the language of optimal transport. </p>
# - <p> $c(x,y)$ is just the distance between those points </p>
# - <p> Note: we do two modifications to this </p>
#   - <p> we solve an approximate version for speed ("entropic regularization") </p>
#   - <p> add penalties for creating/destroying stuff for the case $\sum_x a(x) \neq  \sum_y b(y)$   &nbsp; [1]. </p>

# <br />
# <br />
# <br />

# [1]: Séjourné, T., Feydy, J., Vialard, F.-X., Trouvé, A., Peyré, G., 2019. *Sinkhorn Divergences for Unbalanced Optimal Transport*. https://arxiv.org/abs/1910.12958.


# ---

# ## What use does this have?

# Making gifs!


# ---

# ## What use does this have?


# Adding a check for new packages being added to the General registry to try to prevent the malicious impersonation another package.

# Two main concerns:

# 1. Possibly, one will make a typo, and end up at the wrong package ("typosquatting") $\leadsto$ edit distance check
# 2. Possibly, one will copy a malicious tutorial that has mimicked the appearance of the name of a popular package $\leadsto$ visual distance

# <img src="assets/FIux.gif" style="width: 45%" class="center" />


# ---

# ## Is this the right visual distance for an automated registry check?

# I'm not sure.

# * <p> Human perception is actually a bit different </p>
#   * e.g. we mix up "p" vs "q" more than "a" vs "e"  [2], but `visual_distance` says "p" and "q" are further apart than "a" and "e"
# * <p> optimal transport is a bit slow (though not prohibitively so, with entropic regularization and the low resolution font) </p>
# * <p> there are several parameters and cutoffs to tune </p>
#
#
# Possibly a perceptually-weighted edit distance is more sensible.

# <br />
# <br />

# [2]: Courrieu, Pierre, Fernand Farioli, and Jonathan Grainger. *Inverse Discrimination Time as a Perceptual Distance for Alphabetic Characters*. Visual Cognition 11, no. 7 (October 2004): 901–19. https://doi.org/10.1080/13506280444000049.

# ---

# ## References & Notes

# * Package for `visual_distance`, `printglyph`, etc: VisualStringDistances.jl
# * <p> Package with the underlying algorithm optimal transport algorithm: UnbalancedOptimalTransport.jl </p>

# <br />
# <br />

# References:
# <br />

# [1]: Séjourné, T., Feydy, J., Vialard, F.-X., Trouvé, A., Peyré, G., 2019. *Sinkhorn Divergences for Unbalanced Optimal Transport*. https://arxiv.org/abs/1910.12958.
#
# [2]: Courrieu, Pierre, Fernand Farioli, and Jonathan Grainger. *Inverse Discrimination Time as a Perceptual Distance for Alphabetic Characters*. Visual Cognition 11, no. 7 (October 2004): 901–19. https://doi.org/10.1080/13506280444000049.

# <br />

# Slides made with the help of Remark.jl, Literate.jl, and Documenter.jl; gifs made with Makie.jl.

# Thanks to Stefan Karpinski for suggesting GNU Unifont.
