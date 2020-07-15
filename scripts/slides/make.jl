using Remark, FileWatching

while true
    Remark.slideshow(@__DIR__; options = Dict("ratio" => "16:9"), credit=false,
    title = "How similar do two strings look? Visual distances in Julia")
    @info "Rebuilt"
    FileWatching.watch_folder(joinpath(@__DIR__, "src"))
end 
