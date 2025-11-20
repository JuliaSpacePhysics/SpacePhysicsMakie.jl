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
