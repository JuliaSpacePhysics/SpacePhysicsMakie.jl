using SpacePhysicsMakie
using Documenter

makedocs(
    sitename = "SpacePhysicsMakie.jl",
    pages = [
        "Home" => "index.md",
        "Examples" => "interactive.md",
    ],
    format = Documenter.HTML(size_threshold = nothing),
    modules = [SpacePhysicsMakie],
    warnonly = Documenter.except(:doctest),
    doctest = true
)

deploydocs(
    repo = "github.com/JuliaSpacePhysics/SpacePhysicsMakie.jl",
    push_preview = true
)
