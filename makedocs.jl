
using Documenter
using StateSpaceEcon
using ModelBaseEcon
using TimeSeriesEcon

# Scans the src/Tutorials path and populates the tutorials array used below
# include("scan_tutorials.jl")

makedocs(
    sitename="StateSpaceEcon",
    format=Documenter.HTML(prettyurls=get(ENV, "CI", nothing) == "true"),
    modules=[StateSpaceEcon, ModelBaseEcon, TimeSeriesEcon],
    doctest=false,
    pages=[
        # "index.md",
        "Tutorials" => [
            "Tutorials/index.md",
            "Tutorials/README.md",
            "Tutorials/US_SW07/main.md",
            "Tutorials/TimeSeriesEcon/main.md",
        ],
        "Reference" => [
            "TimeSeriesEcon" => "Reference/TimeSeriesEcon.md",
            "ModelBaseEcon" => "Reference/ModelBaseEcon.md",
            "StateSpaceEcon" => "Reference/StateSpaceEcon.md",
        ],
        "Index" => "indexpage.md"
    ]
)

if get(ENV, "CI", nothing) == "true"
    deploydocs(repo="github.com/bankofcanada/DocsEcon.jl.git")
end
