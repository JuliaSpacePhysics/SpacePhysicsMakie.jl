using TestItemRunner

@run_package_tests

@testitem "Aqua" begin
    using Aqua
    Aqua.test_all(SpacePhysicsMakie)
end

@testitem "Basic plotting workflow" begin
    using CairoMakie
    using Unitful
    using Dates

    # Test data creation
    n = 10
    times = DateTime(2023, 1, 1):Hour(1):DateTime(2023, 1, 1, n - 1)
    data1 = rand(n) * 4u"km/s"
    data2 = rand(n) * 2u"eV"
    data3 = rand(n, 3)

    # Test basic tplot functionality
    @test_nowarn tplot(data1)
    @test_nowarn tplot([data1, data2])

    # Test with figure
    fig = Figure()
    @test_nowarn tplot(fig, data1)

    # Test panel plotting
    @test_nowarn tplot(fig[2, 1], data1)
    @test_nowarn tplot(fig[3, 1], [data1, data2])

    # Test dual axis data
    @test_nowarn tplot(fig[1:3, 2], [data3, (data1, data2)])
    fig
end


@testsnippet DataShare begin
    using CairoMakie
    using Unitful
    # Create sample data
    n = 24
    data1 = rand(n) * 4u"km/s"  # Vector with units
    data2 = rand(n) * 4u"km/s"  # Same units
    data3 = rand(n) * 1u"eV"    # Different units
    data4 = rand(n, 6)           # Matrix (for heatmap)
end

# "Multiple series"
@testitem "Multiple series" setup = [DataShare] begin
    f = Figure()
    # Method 1
    scatterlines(f[1, 1], data1); scatterlines!(f[1, 1], data2)
    # Method 2
    @test_nowarn tplot_panel(f[2, 1], [data1, data2]; plottype = ScatterLines)
    # Method 3
    @test_nowarn multiplot(f[3, 1], [data1, data2], plottype = ScatterLines)
    f
end

@testitem "Overlay series" setup = [DataShare] begin
    f = Figure()
    # Method 1
    plot(f[1, 1], data4); plot!(f[1, 1], data1); plot!(f[1, 1], data2)
    # Method 2
    @test_nowarn tplot_panel(f[2, 1], [data4, data1, data2])
    # Method 3
    @test_nowarn multiplot(f[3, 1], [data4, data1, data2])

    @test_nowarn multiaxisplot(f[4, 1], data4, data1)
    f
end

@testitem "tplot_panel dispatch" setup = [DataShare] begin
    f = Figure()
    # Multiple Series (same y-axis)
    @test_nowarn tplot_panel(f[1, 1], [data1, data2]; axis = (; title = "Multiple series"), plottype = ScatterLines)
    # Dual Y-Axes (different units)
    @test_nowarn tplot_panel(f[2, 1], (data1, data3); axis = (; title = "Dual y-axes"))
    # Overlay Series on Heatmap
    @test_nowarn tplot_panel(f[1, 2], [data4, data1, data2]; axis = (; title = "Heatmap with overlays"))
    # XY Plot (non-time series)
    @test_nowarn tplot_panel(f[2, 2], data2, data3; axis = (; title = "XY plot (fallback)"))
    f
end
