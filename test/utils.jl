@testitem "set_if_valid! skips empty and nothing" begin
    using SpacePhysicsMakie: set_if_valid!
    d = set_if_valid!(Dict{Symbol, Any}(), :a => 1, :b => "", :c => Int[], :d => nothing)
    @test d == Dict{Symbol, Any}(:a => 1)
end

@testitem "resample" begin
    using SpacePhysicsMakie: resample
    arr = collect(1:100)
    @test resample(arr; n = 10) == round.(Int, range(1, 100, length = 10))
    @test resample(arr; n = 200) === arr
    @test size(resample(reshape(1:20, 4, 5); n = 3, dim = 2)) == (4, 3)
end

@testitem "theme settings" begin
    using SpacePhysicsMakie: setting
    using Makie
    @test setting(:add_title) == false
    with_theme(SpacePhysicsMakie = (; add_title = true)) do
        @test setting(:add_title) == true
        @test setting(:delay) == 0.25
    end
    with_theme(SpacePhysicsMakie = (; add_titel = true)) do
        @test_throws ArgumentError setting(:add_title)
    end
end
