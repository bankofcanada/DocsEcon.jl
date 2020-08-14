
@info "Testing TimeSeriesEcon:"
cd(joinpath(dirname(pathof(TimeSeriesEcon)), "..", "test")) do
    include(joinpath(pwd(), "runtests.jl"))
end

@info "Testing ModelBaseEcon:"
cd(joinpath(dirname(pathof(ModelBaseEcon)), "..", "test")) do
    include(joinpath(pwd(), "runtests.jl"))
end

@info "Testing StateSpaceEcon:"
cd(joinpath(dirname(pathof(StateSpaceEcon)), "..", "test")) do
    include(joinpath(pwd(), "runtests.jl"))
end

@info "All done."
