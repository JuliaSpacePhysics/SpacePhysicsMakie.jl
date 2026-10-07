@testitem "specplot reactive on Computed" begin
    # Plotting a `Computed` should re-render when the graph input changes.
    # Pre-fix `specplot!` silently unwrapped the Computed via `_to_value`, so
    # `plt.color` stayed pinned to the initial materialized matrix.
    using SpacePhysicsMakie
    using Makie, Dates, DimensionalData, Random
    using Makie.ComputePipeline

    g = Makie.ComputePipeline.ComputeGraph()
    Makie.ComputePipeline.add_input!(g, :seed, 1)
    Makie.ComputePipeline.map!(g, :seed, :out) do s
        t = Ti(range(DateTime(2000); step = Hour(1), length = 4))
        rand(MersenneTwister(s), t, Y(11:18))
    end

    f = Figure()
    ax = Axis(f[1, 1])
    plt = specplot!(ax, g[:out])

    v1 = copy(plt.color[])
    Makie.ComputePipeline.update!(g, seed = 2)
    g[:out][]
    v2 = copy(plt.color[])
    @test v1 != v2
end

@testitem "multiplot reactive on Computed" begin
    # Pre-fix `multiplot!(::Computed)` unwrapped to plain data and lost reactivity
    # for heterogeneous lists (e.g. a spectrogram alongside line series).
    using SpacePhysicsMakie
    using Makie, Dates, DimensionalData, Random
    using Makie.ComputePipeline

    g = Makie.ComputePipeline.ComputeGraph()
    Makie.ComputePipeline.add_input!(g, :seed, 1)
    Makie.ComputePipeline.map!(g, :seed, :out) do s
        t = Ti(range(DateTime(2000); step = Hour(1), length = 4))
        a = rand(MersenneTwister(s), t, Y(11:18))
        b = rand(MersenneTwister(s + 100), t, Y(1:2))
        [a, b]
    end

    f = Figure()
    ax = Axis(f[1, 1])
    plots = SpacePhysicsMakie.multiplot!(ax, g[:out])  # multiplot! not exported

    # The first child is a spectrogram → `surface!`; its color is the lifted matrix.
    surf = plots[1]
    v1 = copy(surf.color[])
    Makie.ComputePipeline.update!(g, seed = 2)
    g[:out][]
    v2 = copy(surf.color[])
    @test v1 != v2
end

@testitem "colorscale detection" begin
    using SpacePhysicsMakie: _colorscale
    @test _colorscale([1, 10, 1000]) == log10  # Large positive range
    @test _colorscale([1, 2, 3]) == identity   # Small range
    @test _colorscale([NaN, 1, 2]) == identity # With NaN values
    @test _colorscale([-1, 0, 1000]) == identity  # Mixed signs
end

@testitem "channel_edges" begin
    using SpacePhysicsMakie: channel_edges
    using SpacePhysicsMakie.Unitful
    @test channel_edges([1.0, 3.0, 6.0], identity) == [0.0, 2.0, 4.5, 7.5]
    @test channel_edges([1.0, 10.0, 100.0], log10) ≈ 10.0 .^ (-0.5:2.5)
    @test channel_edges([1.0 10.0; 10.0 100.0] * u"eV", log10) ≈ exp10.([-0.5 0.5 1.5; 0.5 1.5 2.5]) * u"eV"
end

@testitem "specplot! with a time-varying depend_1" begin
    using Makie, Dates
    using SpacePhysicsMakie: Materialized, channel_edges
    using SpaceDataModel: DefaultSchema
    t = DateTime(2000) .+ Hour.(0:3)
    E = [10.0i + j for i in 1:5, j in 1:4]  # energy × time, like the data
    A = Materialized(rand(5, 4), (E, t), 2, Dict(), "flux", DefaultSchema())
    yy = specplot!(Axis(Figure()[1, 1]), A; bin = nothing)[2][]
    @test yy[1, 1:2:end] == channel_edges(E[:, 1], identity)[1:(end - 1)]
    @test yy[end, 2:2:end] == channel_edges(E[:, 4], identity)[2:end]
end

@testitem "sample cells follow the local cadence" begin
    using SpacePhysicsMakie: sample_cells
    # Sparse then dense: the sparse cell keeps half its own cadence instead of reaching into the dense run.
    lo, hi = sample_cells([0.0, 10, 20, 21, 22])
    @test (hi[1], hi[2], lo[3], hi[3]) == (5, 15, 19.5, 20.5)
    lo, hi = sample_cells([0.0, 1, 2, 10, 11, 12])
    @test (hi[3], lo[4]) == (2.5, 9.5)
    # Isolated samples take their neighbours' cadence, not half the gap.
    lo, hi = sample_cells([0.0, 1, 2, 10, 18, 19, 20])
    @test (lo[4], hi[4]) == (9.5, 10.5)
    lo, hi = sample_cells([0.0, 10, 11, 12])
    @test (lo[1], hi[1]) == (-0.5, 0.5)
end

@testitem "merge_cells bins by time span and skips NaN" begin
    using SpacePhysicsMakie: merge_cells, mean
    lo, hi = [0.0, 1, 2, 3, 10, 20], [1.0, 2, 3, 4, 11, 30]
    M = reshape([1.0, 3, NaN, 5, 7, 9], :, 1)
    lo′, hi′, M′, _ = merge_cells(lo, hi, M, [0.0, 1.0], x -> x + 4, mean)
    @test (lo′, hi′, vec(M′)) == ([0, 10, 20], [4, 11, 30], [3, 7, 9])
end

@testitem "spectrogram cells: log channel edges and gaps" begin
    using Makie, Dates, DimensionalData
    t = DateTime(2000) .+ Minute.([1:10; 21:30])
    A = rand(Ti(t), Y(exp10.(1:4)))
    p = specplot!(Axis(Figure()[1, 1]; yscale = log10), A; bin = nothing)
    @test p[2][][1, 1:2:end] ≈ exp10.(0.5:1:3.5)
    @test count(r -> all(isnan, r), eachrow(p.color[])) == 2
end

@testitem "specplot! merges sub-pixel samples of the view" begin
    using Makie, Dates, DimensionalData
    t = DateTime(2000) .+ Second.(1:100_000)
    f = Figure(size = (400, 300))
    ax = Axis(f[1, 1])
    p = specplot!(ax, rand(Ti(t), Y(1:4)))
    ms(x) = Dates.value(x)  # `p[1]` holds the axis' converted values
    Makie.update_state_before_display!(f)
    @test size(p[1][], 1) < 2000
    @test extrema(p[1][]) == (ms(t[1]) - 500, ms(t[end]) + 500)
    xlims!(ax, t[50_000], t[50_100])
    Makie.update_state_before_display!(f)
    @test count(x -> ms(t[50_000]) <= x <= ms(t[50_100]), p[1][][:, 1]) >= 200
end

@testitem "spectrogram cells: inferred, allocations independent of length" begin
    using SpacePhysicsMakie: sample_cells, merge_cells, cell_grid, channel_edges, pixel_stop, mean
    using Makie: Rect2d, Rect2i
    # `@allocations` is process-wide on Julia 1.10, so concurrent test items inflate it; noise only adds.
    macro minallocs(ex)
        return :(minimum(_ -> @allocations($(esc(ex))), 1:5))
    end
    n, m = 100_000, 32
    x = cumsum(rand(n) .+ 0.5)
    E = exp10.(range(1, 4, length = m))
    Et = repeat(E', n)
    @inferred channel_edges(Et, log10)
    @test @minallocs(channel_edges(Et, log10)) <= 50
    for M in (rand(n, m), rand(Float32, n, m)), Y in (channel_edges(E, log10), channel_edges(Et, log10))
        lo, hi = @inferred sample_cells(x)
        stop = pixel_stop(lo, hi, Rect2d(x[1], 0, x[end] - x[1], 1), Rect2i(0, 0, 1000, 1))
        cells = @inferred merge_cells(lo, hi, M, Y, stop, mean)
        @test eltype(cells[3]) == eltype(M)
        @inferred cell_grid(cells...)
        @test @minallocs(sample_cells(x)) <= 20
        @test @minallocs(merge_cells(lo, hi, M, Y, stop, mean)) <= 50
        @test @minallocs(cell_grid(cells...)) <= 50
    end
end
