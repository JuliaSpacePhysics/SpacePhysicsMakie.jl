@testitem "Axis attribute extraction" begin
    using SpacePhysicsMakie: axis_attributes
    using Unitful

    # Test end-to-end functionality
    data = [1.0, 2.0, 3.0] * u"m"
    attrs = axis_attributes(data)

    @test !haskey(attrs, :yunit)  # Should be processed and removed
    @test haskey(attrs, :dim2_conversion)  # Should have unit conversion

    # Test with non-unitful data
    simple_data = [1, 2, 3]
    simple_attrs = axis_attributes(simple_data)
    @test !haskey(simple_attrs, :dim2_conversion)  # No units, no conversion

    struct TestVariable{T, N, A <: AbstractArray{T, N}, D} <: AbstractArray{T, N}
        data::A
        meta::D
    end
    test_data = TestVariable([1, 2, 3], Dict(:ylabel => "right", "LABLAXIS" => "wrong", :nothing => nothing, :title => "title"))

    expected = Dict{Symbol, Any}(:ylabel => "right", :title => "title")

    @test axis_attributes(test_data; add_title = true) == expected
    @test axis_attributes(() -> test_data; add_title = true) == expected
    @test axis_attributes([() -> test_data, test_data]; add_title = true) == expected
end

@testitem "ISTP metadata to axis attributes" begin
    using SpacePhysicsMakie: axis_attributes, labels, isspectrogram, clabel
    using DimensionalData, Dates
    t = Ti(range(DateTime(2000), step = Hour(1), length = 4))
    meta = Dict(
        "CATDESC" => "Velocity", "LABLAXIS" => "V", "UNITS" => "km/s",
        "SCALETYP" => "log", "LABL_PTR_1" => ["x", "y", "z"],
    )
    A = rand(t, Y(1:3); metadata = meta)
    @test axis_attributes(A; add_title = true) ==
        Dict{Symbol, Any}(:title => "Velocity", :ylabel => "V\n(km/s)", :yscale => log10)
    @test labels(A) == ["x", "y", "z"]
    @test !isspectrogram(A)
    @test isspectrogram(rand(t, Y(1:3); metadata = Dict("CATDESC" => "", "DISPLAY_TYPE" => "spectrogram")))
    @test clabel(A) == "V\n(km/s)"
end
