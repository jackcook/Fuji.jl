using Documenter, Fuji

makedocs(
    format = :html,
    sitename = "Fuji"
)

deploydocs(
    repo = "github.com/jackcook/Fuji.jl.git",
    julia = "0.6",
    osname = "linux",
    deps = nothing,
    make = nothing,
    target = "build"
)
