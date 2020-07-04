export font_glyph, font_glyph2
const DEFAULT_FACE = Ref(FreeTypeAbstraction.findfont("Times"))


function font_glyph(str::String, face = DEFAULT_FACE[])
    x_size  = 80*textwidth(str)
    y_size = 150
    buffer = 10
    img = zeros(UInt8, y_size, x_size)
    FreeTypeAbstraction.renderstring!(img::AbstractMatrix, str, face, 100, 100, buffer)
    img
end

# reduce(union, FreeTypeAbstraction.glyph_rects(str, VisualStringDistances.DEFAULT_FACE[], 1))
# str = join('a':'z')
# FreeTypeAbstraction.boundingbox(str, VisualStringDistances.DEFAULT_FACE[], 1)
