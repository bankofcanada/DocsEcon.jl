
using Documenter
using TimeSeriesEcon
using ModelBaseEcon
using StateSpaceEcon
using FAME

# Scans the src/Tutorials path and populates the tutorials array used below
# include("scan_tutorials.jl")

##

ENV["GKSwstype"] = "100"

makedocs(
    sitename="StateSpaceEcon",
    format=Documenter.HTML(prettyurls=get(ENV, "CI", nothing) == "true"),
    modules=[StateSpaceEcon, ModelBaseEcon, TimeSeriesEcon, FAME],
    doctest=false,
    pages=[
        "index.md",
        "Tutorials" => [
            "Tutorials/index.md",
            "Tutorials/README.md",
            "Tutorials/1.TimeSeriesEcon/main.md",
            "Tutorials/2.simple_RBC/main.md",
            "Tutorials/3.US_SW07/main.md",
            "FRB/US" => "Tutorials/4.FRB-US/main.md",
        ],
        "Reference" => [
            "TimeSeriesEcon" => "Reference/TimeSeriesEcon.md",
            "ModelBaseEcon" => "Reference/ModelBaseEcon.md",
            "StateSpaceEcon" => "Reference/StateSpaceEcon.md",
            "FAME" => "Reference/FAME.md",
        ],
        "Design Papers" => [
            "DesignPapers/index.md",
            "DesignPapers/final_conditions.md",
            "DesignPapers/log_variables.md",
        ],
        "Index" => "indexpage.md"
    ]
)

##

if get(ENV, "CI", nothing) == "true"
    deploydocs(repo="github.com/bankofcanada/DocsEcon.jl.git",
        push_preview=true)
end
