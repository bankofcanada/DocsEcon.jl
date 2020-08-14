
using Documenter
using StateSpaceEcon
using ModelBaseEcon
using TimeSeriesEcon


makedocs(
    sitename="StateSpaceEcon Docs",
    format=Documenter.HTML(prettyurls=get(ENV, "CI", nothing) == "true"),
    pages=[
        "index.md",
        # "Tutorials" => tutorials,
        "Reference" => [
            "TimeSeriesEcon" => "timeseriesecon.md",
            "ModelBaseEcon" => "modelbaseecon.md",
            "StateSpaceEcon" => "statespaceecon.md",
        ],
        "Index" => "indexpage.md"
    ]
)

