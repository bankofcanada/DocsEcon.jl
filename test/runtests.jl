
using Pkg
using Test

@info "Testing TimeSeriesEcon:"
using TimeSeriesEcon
Pkg.test("TimeSeriesEcon")

@info "Testing ModelBaseEcon:"
using ModelBaseEcon
Pkg.test("ModelBaseEcon")

@info "Testing StateSpaceEcon:"
using StateSpaceEcon
Pkg.test("StateSpaceEcon")

@info "Testing Tutorials"

@testset "Time Series" begin
    @test true
    include(joinpath("..", "src", "Tutorials", "1.TimeSeriesEcon", "main.jl"))
end

@testset "Simple RBC" begin
    include(joinpath("..", "src", "Tutorials", "2.simple_RBC", "main.jl"))
end

@testset "US_SW07" begin
    include(joinpath("..", "src", "Tutorials", "3.US_SW07", "main.jl"))
end

@info "All done."
