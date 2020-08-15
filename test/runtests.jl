
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

using StateSpaceEcon
@using_example E1
@using_example E2
empty!(E1.model.sstate.constraints)
empty!(E2.model.sstate.constraints)
# clear_sstate!(E1.model)

@info "Testing StateSpaceEcon:"
using StateSpaceEcon
cd(joinpath(dirname(pathof(StateSpaceEcon)), "..", "test")) do
    include(joinpath(pwd(), "runtests.jl"))
end

@info "All done."
