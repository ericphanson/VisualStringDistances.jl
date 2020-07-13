@info "Loading packages..."
@time begin
    using VisualStringDistances, UnbalancedOptimalTransport
    using AbstractPlotting: px
    using UnbalancedOptimalTransport: KL, Balanced
    using Makie, MakieLayout
    using GeometryBasics: Point2f0
    using PlotUtils: RGBA, RGB
end


function hide_decorations!(ax)
    ax.xticksvisible=false
    ax.yticksvisible=false
    ax.xticklabelsvisible=false
    ax.yticklabelsvisible=false
    ax.bottomspinevisible = false
    ax.leftspinevisible = false
    ax.topspinevisible = false
    ax.rightspinevisible = false
    ax.xgridvisible=false
    ax.ygridvisible=false
end

function imgrot(v)
    Point2f0(v[2], 1-v[1])
end


# transparent to black for 0 to 1, then becomes redder from 1 to 2
const CMAP = cgrad([RGBA{Float64}(0.0,0.0,0.0,0.0), RGBA{Float64}(0.0,0.0,0.0,1.0), RGBA{Float64}(1.0,0.0,0.0,1.0)], [0,1,1.5])

density_to_color(d) = get(CMAP, d/2)


function animate_words(string1, string2;
    normalize_density = false,
    D = KL(1.0),
    random_colors = false,
    kwargs...
)
    w1 = word_measure(string1)
    w2 = word_measure(string2)

    if normalize_density
        w1 = DiscreteMeasure(w1.density / sum(w1.density), w1.set)
        w2 = DiscreteMeasure(w2.density / sum(w2.density), w2.set)
    end

    if random_colors
        # doesn't matter how we chose `π`
        π = ones(length(w1.set), length(w2.set))
    else
        π = optimal_coupling!(D, w1, w2)
    end


    
    scene, layout = layoutscene()
    layout[1,1] = ax = LAxis(scene)
    display(scene)
    animate_coupling!(scene, ax, π, w1.set, w2.set; random_colors = random_colors, kwargs...)
    return
end

function animate_coupling!(scene, ax, π, coords1, coords2;
    duration = 2,
    total_frames = 50*duration,
    pause_frames = total_frames ÷ 4,
    move_frames = total_frames - 2*pause_frames,
    markersize = 20px,
    random_colors = false,
    save_path = nothing,
    α = 0.7,
    compression = 20
)

    x_min = min(minimum([x[1] for x in imgrot.(coords1)]), minimum([x[1] for x in imgrot.(coords2)]))
    x_max = max(maximum([x[1] for x in imgrot.(coords1)]), maximum([x[1] for x in imgrot.(coords2)]))
    y_min = min(minimum([x[2] for x in imgrot.(coords1)]), minimum([x[2] for x in imgrot.(coords2)]))
    y_max = max(maximum([x[2] for x in imgrot.(coords1)]), maximum([x[2] for x in imgrot.(coords2)]))
    
    hide_decorations!(ax)

    s1, s2 = size(π)
    if random_colors
        cvals = collect(Iterators.Flatten(Iterators.repeated([ RGBA(rand(RGB), α) for _ = 1:s1], s2)))
    else
        scale = sqrt(prod(size(π)))
        cvals = density_to_color.(scale * vec(π) ./ sum(π))
    end

    t = 0
    locations = Node([ imgrot( (1-t)*coords1[i] + t*coords2[j]) for j = 1:size(π,2) for i = 1:size(π,1)])
    
    anim_plt = scatter!(ax, locations, color = cvals, markersize=markersize,
    transparency=true)
    x_pad = (x_max - x_min)*.05
    y_pad = (y_max - y_min)*.05
    limits!(ax, x_min - x_pad, x_max + x_pad, y_min - y_pad, y_max + y_pad)


    move_ts = range(0, 1; length=move_frames)
    do_frame = function(j)
        if (j <= pause_frames) || (j > total_frames - pause_frames)
            save_path === nothing && sleep(duration/total_frames)
        else
            t = move_ts[j - pause_frames]
            locations[] = [ imgrot((1-t)*coords1[i] + t*coords2[j]) for j = 1:size(π,2) for i = 1:size(π,1)]
            save_path === nothing && sleep(duration/total_frames)
        end
    end

    if save_path === nothing
        map(do_frame, 1:total_frames)
    else
        record(do_frame, scene, save_path, 1:total_frames, framerate = round(Int, total_frames / duration), compression=compression)
    end
    return
end


@eval AbstractPlotting begin
   function save(path::String, io::VideoStream;
              framerate::Int = 24, compression = 20)
    close(io.process)
    wait(io.process)
    p, typ = splitext(path)
    if typ == ".mkv"
        cp(io.path, path, force=true)
    elseif typ == ".mp4"
        ffmpeg_exe(`-loglevel quiet -i $(io.path) -crf $compression -c:v libx264 -preset slow -r $framerate -pix_fmt yuv420p -c:a libvo_aacenc -b:a 128k -y $path`)
    elseif typ == ".webm"
        ffmpeg_exe(`-loglevel quiet -i $(io.path) -crf $compression -c:v libvpx-vp9 -threads 16 -b:v 2000k -c:a libvorbis -threads 16 -r $framerate -vf scale=iw:ih -y $path`)
    elseif typ == ".gif"
        filters = "fps=$framerate,scale=iw:ih:flags=lanczos"
        palette_path = dirname(io.path)
        pname = joinpath(palette_path, "palette.bmp")
        isfile(pname) && rm(pname, force = true)
        ffmpeg_exe(`-loglevel quiet -i $(io.path) -vf "$filters,palettegen" -y $pname`)
        ffmpeg_exe(`-loglevel quiet -i $(io.path) -r $framerate -f image2 $(palette_path)/image_%06d.png`)
        ffmpeg_exe(`-loglevel quiet -framerate $framerate -i $(palette_path)/image_%06d.png -i $pname -lavfi "$filters [x]; [x][1:v] paletteuse" -y $path`)
        rm(pname, force = true)
    else
        rm(io.path)
        error("Video type $typ not known")
    end
    rm(io.path)
    return path
end
end


@info "Generating animations..."

@time begin
    animate_words("hello", "heIIo"; D = KL(1.0), save_path=abspath(joinpath(@__DIR__, "..", "..", "docs", "assets", "hello_heIIo.gif")))
    animate_words("hello", "heIIo"; D = Balanced(), normalize_density=true, save_path=abspath(joinpath(@__DIR__, "..", "..", "docs", "assets", "hello_heIIo_balanced.gif")))
end

@info "Done!"
