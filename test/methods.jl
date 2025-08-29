@testitem "Methods" begin
    # https://github.com/MakieOrg/Makie.jl/issues/4412

    using CairoMakie
    using Dates

    # Test plotting into Float64 axis
    f = Figure()
    ax1 = Axis(f[1, 1])
    xs = [DateTime(2020, 1, 1), DateTime(2020, 1, 2), DateTime(2020, 1, 3)]
    @test_throws "MethodError: Cannot `convert` an object of type DateTime to an object of type Float64" vlines!(ax1, xs)
    ax2 = Axis(f[2, 1])
    @test_nowarn tlines!(ax2, xs)

    # vspan!
    x1 = [DateTime(2020, 1, 1), DateTime(2020, 1, 5), DateTime(2020, 1, 11)]
    x2 = [DateTime(2020, 1, 2), DateTime(2020, 1, 7), DateTime(2020, 1, 12)]
    @test_throws "MethodError: Cannot `convert` an object of type DateTime to an object of type Float64" vspan!(ax1, x1, x2)
    @test_nowarn tvspan!(ax2, x1, x2)

    # Test plotting into DateTime axis
    xs = [DateTime(2020, 1, 1), DateTime(2020, 1, 2), DateTime(2020, 1, 3)]
    f = scatter(xs, 1:3)
    @test_throws "MethodError: Cannot `convert` an object of type DateTime to an object of type Float64" vlines!(xs)
    @test_nowarn tlines!(xs)

    # vspan!
    x1 = [DateTime(2020, 1, 1), DateTime(2020, 1, 5), DateTime(2020, 1, 11)]
    x2 = [DateTime(2020, 1, 2), DateTime(2020, 1, 7), DateTime(2020, 1, 12)]
    @test_throws "ArgumentError: Cannot change dim conversion for dimension 2, since it already is set to a conversion: Makie.NoDimConversion()." vspan!(x1, x2)
    @test_throws "Plotting unit Int64 into axis with type DateTime not supported." tvspan!(x1, x2)
end
