
using Documenter
using StateSpaceEcon
using ModelBaseEcon
using TimeSeriesEcon

# Scans the src/Tutorials path and populates the tutorials array used below
include("scan_tutorials.jl")

makedocs(
    sitename="StateSpaceEcon Docs",
    format=Documenter.HTML(prettyurls=get(ENV, "CI", nothing) == "true"),
    pages=[
        "index.md",
        tutorials,
        "Reference" => [
            "TimeSeriesEcon" => "Reference/timeseriesecon.md",
            "ModelBaseEcon" => "Reference/modelbaseecon.md",
            "StateSpaceEcon" => "Reference/statespaceecon.md",
        ],
        "Index" => "indexpage.md"
    ]
)

deploydocs(
    repo = "github.com/bbejanov/DocsEconTest.jl.git"
)
