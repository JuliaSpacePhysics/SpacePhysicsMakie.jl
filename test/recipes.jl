@testitem "DualPlot" begin
    using CairoMakie
    axis = (; title = "Dual y-axes")
    data1 = [1, 3, 2]
    data2 = [2, 4, 1, 3]
    data3 = [4, 3, 4, 2]
    @test_nowarn SpacePhysicsMakie.dualplot(data1, data2; axis)
    SpacePhysicsMakie.dualplot([data1, data2], data3; axis)
    f = Figure()
    ax = Axis(f[1, 1])
    dualplot!(ax, data1, data3)
    f
end

@testitem "LinesPlot" begin
    using CairoMakie
    using Unitful
    using DimensionalData
    using Dates
    ys = [[1, 2, 4] [3, 4, 10]]
    @test_nowarn linesplot(ys)
    @test_nowarn linesplot([10, 20, 30], ys)

    t = Ti(range(DateTime(2000), step = Hour(1), length = 4))
    A = rand(t, Y(1:5))
    Au = A * 1u"nT"
    @test_nowarn linesplot(Au)

    @test_nowarn let
        f = Figure()
        ax = Axis(f[1, 1]; SpacePhysicsMakie.axis_attributes(Au)...)
        linesplot!(ax, t.val, Au)
        f
    end
end
