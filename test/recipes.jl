@testitem "FunctionPlot" begin
    using CairoMakie, Dates, DimensionalData

    t0 = DateTime(2001, 1, 1)
    t1 = DateTime(2001, 1, 2)

    function func(t0, t1)
        x = t0:Hour(1):t1
        y = @. sin(2pi * ((x - t0) / Day(1)))
        DimArray(y, Ti(x))
    end

    @test_nowarn tplot(func, t0, t1)
end

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
    using CairoMakie, Dates, DimensionalData, Unitful
    ys = [[1, 2, 4] [3, 4, 10]]
    @test_nowarn linesplot(ys)
    @test_nowarn linesplot([10, 20, 30], ys)

    t = Ti(range(DateTime(2000), step = Hour(1), length = 4))
    A = rand(t, Y(1:5); metadata= (; labels = ["Y1", "Y2", "Y3", "Y4", "Y5"], xlabel="Time"))
    Au = A * 1u"nT"
    f = @test_nowarn linesplot(Au)
    @test f.axis.xlabel[] == "Time"
    @test length(f.figure.layout.content) == 2 # axis and legend

    @test_nowarn let
        f = Figure()
        ax = Axis(f[1, 1]; SpacePhysicsMakie.axis_attributes(Au)...)
        linesplot!(ax, t.val, Au)
        f
    end
end
