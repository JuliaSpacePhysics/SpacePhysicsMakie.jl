@testitem "specplot! with DimArray" begin
    using CairoMakie, Dates, DimensionalData

    t = Ti(range(DateTime(2000), step = Hour(1), length = 4))
    A = rand(t, Y(11:18))
    f = Figure()
    @test_nowarn specplot!(Axis(f[1, 1]), A)
    @test_nowarn specplot!(Axis(f[2, 1]), A')
    colorbuffer(f)
    @test f.content[1].yaxis.tickvalues[] == [12.5, 15.0, 17.5]
end

@testitem "specplot reactive on Computed" begin
    # Plotting a `Computed` should re-render when the graph input changes.
    # Pre-fix `specplot!` silently unwrapped the Computed via `_to_value`, so
    # `plt.color` stayed pinned to the initial materialized matrix.
    using SpacePhysicsMakie
    using CairoMakie, Dates, DimensionalData, Random
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
    using CairoMakie, Dates, DimensionalData, Random
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

@testitem "binedges tests" begin
    using SpacePhysicsMakie: binedges
    using SpacePhysicsMakie.Unitful
    @testset "Linear spacing" begin
        # Basic linear case
        centers = [1.0, 2.0, 3.0]
        @test binedges(centers) == [0.5, 1.5, 2.5, 3.5]

        # Non-uniform spacing
        centers = [1.0, 3.0, 6.0]
        @test binedges(centers) == [0.0, 2.0, 4.5, 7.5]

        # Two points only
        @test binedges([1.0, 3.0]) == [0.0, 2.0, 4.0]
    end

    @testset "Transformed spacing" begin
        # Logarithmic transform
        centers = [1.0, 10.0, 100.0]
        edges = binedges(centers, transform = log)
        @test edges ≈ 10.0 .^ (-0.5:2.5)
    end

    @testset "Units support" begin
        # Test with Unitful quantities
        centers = [1.0, 2.0, 3.0] * u"m"
        edges = binedges(centers)
        expected = [0.5, 1.5, 2.5, 3.5] * u"m"
        @test edges ≈ expected

        # Test units are preserved with transforms
        edges_log = binedges(centers, transform = log)
        @test unit(edges_log[1]) == u"m"
    end
end
