using Documenter
using Shapes

DocMeta.setdocmeta!(Shapes, :DocTestSetup, :(using Shapes); recursive = true)

makedocs(;
    modules = [Shapes],
    sitename = "shapes-julia",
    authors = "shapes contributors",
    remotes = nothing,
    format = Documenter.HTML(; prettyurls = false, edit_link = nothing, repolink = ""),
    pages = ["Home" => "index.md"],
    checkdocs = :exports,
)
