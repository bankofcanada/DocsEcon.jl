
using Test

@info "Testing TimeSeriesEcon:"
using TimeSeriesEcon
cd(joinpath(dirname(pathof(TimeSeriesEcon)), "..", "test")) do
    include(joinpath(pwd(), "runtests.jl"))
end

@info "Testing ModelBaseEcon:"
using ModelBaseEcon
cd(joinpath(dirname(pathof(ModelBaseEcon)), "..", "test")) do
    include(joinpath(pwd(), "runtests.jl"))
end

@info "Testing StateSpaceEcon:"
using StateSpaceEcon
cd(joinpath(dirname(pathof(StateSpaceEcon)), "..", "test")) do
    include(joinpath(pwd(), "runtests.jl"))
end

@info "Testing Tutorials"
@testset "US_SW07" begin
    include(joinpath("..", "src", "Tutorials", "US_SW07", "main.jl"))
end

@info "All done."
