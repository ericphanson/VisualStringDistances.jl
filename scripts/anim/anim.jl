using VisualStringDistances, UnbalancedOptimalTransport
using AbstractPlotting: px
using UnbalancedOptimalTransport: KL
w1 = word_measure("abc")
w2 = word_measure("def")
π = optimal_coupling!(KL(1.0), w1, w2)
π_1 = vec(sum(π, dims=1))
π_2 = vec(sum(π, dims=2))

using Makie, MakieLayout
using GeometryBasics: Point2f0


function plot2d!(ax, gc::VisualStringDistances.GlyphCoordinates, density)
    scatter!(ax, [Point2f0(v[2], 1-v[1] ) for v in gc], color = density)
end

function Base.empty!(ax::LAxis)
    while !isempty(ax.scene.plots)
        plot = first(ax.scene.plots)
        delete!(ax.scene, plot)
    end
end

plot2d!(ax, w::DiscreteMeasure{<:Any, <:Any, <: VisualStringDistances.GlyphCoordinates}) = plot2d!(ax, w.set, w.density)

function imgrot(v)
    Point2f0(v[2], 1-v[1])
end

function gc_to_pts(gc)
    imgrot.(gc)
end
MARKERSIZE=50px
MARKERSIZE2=20px
using PlotUtils: RGBA
CMAP = cgrad([RGBA{Float64}(0.0,0.0,0.0,0.0), RGBA{Float64}(0.0,0.0,0.0,1.0), RGBA{Float64}(1.0,0.0,0.0,1.0)], [0,1,1.5])

scene, layout = layoutscene();
layout[1,1] = ax = LAxis(scene);


final_density = π_2
initial_density = density



lines!(ax, 1:length(initial_density), initial_density)
lines!(ax, 1:length(final_density), final_density)

# # empty!(ax)
# gc, density = w1.set, w1.density
# pts = Node(gc_to_pts(gc))
# colors = Node(get.(Ref(CMAP), density ./ 2))
# # colors = Node([rand(RGBA) for _ = eachindex(density)])
# # colors = Vector{Float32}(.99 * ones(length(density)))
# plt = scatter!(ax, pts, color = colors[], markersize=MARKERSIZE2)
# display(scene)

# final_density = π_2
# initial_density = density

# # Want density 1 to go to color .5
# # Want density 0 to go to color 0
# # Want density 2 to go to color 2
# density_to_color(d) = get(CMAP, d/2)
# map(range(0,1; length=50)) do t
#     # colors[] = density_to_color.(2*ones(length(final_density)))
#     colors[] = density_to_color.(final_density*t + (1-t)*initial_density)
#     # colors[] = [rand(RGBA) for _ = eachindex(initial_density)]
#     empty!(ax)
#     scatter!(ax, pts, color = colors[], markersize=MARKERSIZE2)
#     sleep(5/50)
# end

# sleep(1)
display(scene)

empty!(ax)
coords1 = w1.set
coords2 = w2.set
t = 0
locations = Node([ imgrot( (1-t)*coords1[i] + t*coords2[j]) for j = 1:size(π,2) for i = 1:size(π,1)])
scale = sqrt(prod(size(π)))
cvals = density_to_color.(scale * vec(π) ./ sum(π))
anim_plt = scatter!(ax, locations, color = cvals, markersize=MARKERSIZE2,
transparency=true )
# layout[1,2] = cbar = LColorbar(scene, anim_plt, label="Mass"); cbar.width = 30
display(scene)

map(range(0,1; length=50)) do t
    if t == 0
        sleep(1)
    else
        locations[] = [ imgrot((1-t)*coords1[i] + t*coords2[j]) for j = 1:size(π,2) for i = 1:size(π,1)]
        sleep(5/50)
    end
    if t==50
        sleep(45/50)
    end
end

sleep(1)
# empty!(ax)


# gc, density = w2.set, w2.density
# pts = Node(gc_to_pts(gc))
# colors = Node(Vector{Float32}(density))
# plt = scatter!(ax, pts, color = colors,  markersize=MARKERSIZE)
# display(scene)
