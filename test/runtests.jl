using TestItemRunner

@run_package_tests

@testsnippet DataShare begin
    using Unitful
    # Create sample data
    n = 24
    data1 = rand(n) * 4u"km/s"  # Vector with units
    data2 = rand(n) * 4u"km/s"  # Same units
    data3 = rand(n) * 1u"eV"    # Different units
    data4 = rand(n, 4)           # Matrix (for heatmap)
end

# "Multiple series"
@testitem "Multiple series" setup = [DataShare] begin
    using Makie
    f = Figure()
    # Method 1
    scatterlines(f[1, 1], data1); scatterlines!(f[1, 1], data2)
    # Method 2
    tplot_panel(f[2, 1], [data1, data2])
    # Method 3
    multiplot(f[3, 1], [data1, data2], plottype = ScatterLines)
    # Method 3.5
    multiplot(f[4, 1], ScatterLines, [data1, data2])
    f
end

@testitem "Overlay series" setup = [DataShare] begin
    using Makie
    f = Figure()
    # Method 1
    plot(f[1, 1], data4); plot!(f[1, 1], data1); plot!(f[1, 1], data2)
    # Method 2
    tplot_panel(f[2, 1], [data4, data1, data2])
    # Method 3
    multiplot(f[3, 1], [data4, data1, data2])
    f
end

@testitem "Dual y-axes" setup = [DataShare] begin
    using Makie
    f = Figure()
    axis=(;title="Dual y-axes")
    tplot_panel(f[1, 1], ([data1, data2], data3); axis, plottype = ScatterLines)
    f
end

@testitem "tplot_panel dispatch" setup = [DataShare] begin
    f = Figure()
    # Multiple Series (same y-axis)
    tplot_panel(f[1, 1], [data1, data2]; axis = (; title = "Multiple series"), plottype = ScatterLines)

    # Dual Y-Axes (different units)
    tplot_panel(f[2, 1], (data1, data3); axis=(;title="Dual y-axes"), plottype = ScatterLines)

    # Overlay Series on Heatmap
    tplot_panel(f[1, 2], [data4, data1, data2]; axis = (; title = "Heatmap with overlays"))

    # XY Plot (non-time series)
    tplot_panel(f[2, 2], data2, data3; axis = (; title = "XY plot (fallback)"))
    f
end
