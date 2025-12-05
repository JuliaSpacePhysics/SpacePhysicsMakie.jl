@testitem "FunctionPlot" begin
    using CairoMakie, Dates, DimensionalData

    t0 = DateTime(2001, 1, 1)
    t1 = DateTime(2001, 1, 2)

    function func(t0, t1)
        x = t0:Hour(1):t1
        y1 = @. sin(2pi * ((x - t0) / Day(1)))
        y2 = @. cos(2pi * ((x - t0) / Day(1)))
        DimArray([y1 y2], (Ti(x), Y()))
    end

    f, axes = @test_nowarn tplot(func, t0, t1)

    @testset "MultiFunctionPlot" begin
        f2 = (t0, t1) -> -func(t0, t1)
        @test_nowarn tplot([func, f2], t0, t1)
        @test_nowarn tplot([[func, f2]], t0, t1)
    end
end

@testitem "MultiAxisPlot" begin
    using CairoMakie

    # Basic test with three axes
    y1 = [9, 7, 5, 1, 3, 5]
    y2 = [12, 25, 23, 16, 34, 19]
    y3 = [0, -1, -2, -3, -4, -5]
    f1 = (t1, t2) -> t1 .+ t2 .+ rand(5)

    # Test with MultiAxisData
    data = MultiAxisData(y1, (y2, y3))
    @test length(data) == 3

    result = multiaxisplot(y1, y2, y3; plottypes = ScatterLines)
    result = @test_nowarn multiaxisplot(y1, y2, f1, 0, 1)
    @test result isa Figure

    axis = (; title = "Dual y-axes")
    data1 = [1, 3, 2]
    data2 = [2, 4, 1, 3] .* 1000
    data3 = [4.2, 3.1, 4.3, 2.2]
    @test_nowarn SpacePhysicsMakie.dualplot(data1, data2; axis)
    f = @test_nowarn SpacePhysicsMakie.dualplot([data1, data2], data3; axis)
    @test f.content[2].ylabelcolor[] == Makie.wong_colors()[3]
end

@testitem "LinesPlot" begin
    using CairoMakie, Dates, DimensionalData, Unitful
    ys = [[1, 2, 4] [3, 4, 10]]
    linesplot(ys)
    @test_broken linesplot([10, 20, 30], ys)

    t = Ti(range(DateTime(2000), step = Hour(1), length = 4))
    A = rand(t, Y(1:5); metadata = (; labels = ["Y1", "Y2", "Y3", "Y4", "Y5"], xlabel = "Time"))
    Au = A * 1u"nT"
    @test_nowarn tplot(Au)
    f = @test_nowarn linesplot(Au)
    # Check whether axis and legend are present
    @test length(f.figure.layout.content) == 2 # axis and legend

    @test_nowarn let
        f = Figure()
        ax = Axis(f[1, 1]; SpacePhysicsMakie.axis_attributes(Au)...)
        linesplot!(ax, t.val, Au)
        f
    end
end
