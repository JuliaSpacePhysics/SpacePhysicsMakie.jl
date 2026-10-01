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


@testitem "tplot_panel dispatch" begin
    using CairoMakie
    using Unitful
    n = 24
    v1, v2 = rand(n) * 4u"km/s", rand(n) * 4u"km/s"
    e = rand(n) * 1u"eV"
    m = rand(n, 6)
    f = Figure()
    @test_nowarn tplot_panel(f[1, 1], [v1, v2]; plottypes = ScatterLines)
    @test_nowarn multiplot(f[2, 1], [v1, v2], plottypes = ScatterLines)
    @test_nowarn tplot_panel(f[3, 1], (v1, e))
    @test_nowarn tplot_panel(f[1, 2], [m, v1, v2])
    @test_nowarn multiaxisplot(f[2, 2], m, v1)
    @test_nowarn tplot_panel(f[3, 2], v2, e)
end
