using Test
using SpacePhysicsMakie

# Mock data structure for testing
@testsnippet MetadataTest begin
    using SpacePhysicsMakie.SpaceDataModel
    using SpacePhysicsMakie: get_schema, labels
    using SpacePhysicsMakie: ISTPSchema, HAPISchema, MadrigalSchema

    struct MockData{T, M}
        data::T
        metadata::M
    end

    SpaceDataModel.meta(d::MockData) = d.metadata
    Base.eltype(::Type{MockData{T, M}}) where {T, M} = eltype(T)
end

@testitem "Schema Types" begin
    using SpacePhysicsMakie: ISTPSchema, HAPISchema
    @test_nowarn validate_schema(ISTPSchema())
    @test_nowarn validate_schema(HAPISchema())
end

@testitem "Schema Selection" setup = [MetadataTest] begin
    metadata = Dict("CATDESC" => "Test")
    data = MockData([1.0, 2.0], metadata)

    # Should default to ISTP schema
    @test get_schema(data) isa ISTPSchema
    @test get_schema(() -> data) isa ISTPSchema
end

@testitem "Extract Attributes" setup = [MetadataTest] begin
    schema = ISTPSchema()
    metadata = Dict(
        "CATDESC" => "Velocity Data",
        "LABLAXIS" => "V",
        "UNITS" => "km/s"
    )
    data = MockData([1.0, 2.0, 3.0], metadata)

    attrs = schema(data)
    @test attrs[:desc] == "Velocity Data"
    @test attrs[:name] == "V"
    @test attrs[:unit] == "km/s"
end


@testitem "Empty Metadata Handling" setup = [MetadataTest] begin
    schema = ISTPSchema()
    metadata = Dict{String, Any}()
    data = MockData([1.0, 2.0], metadata)
    sl = schema(data)
    @test isnothing(sl[:title])
    @test get(sl, :title, "default") == "default"
end

@testitem "resolve_metadata Patterns" begin
    using SpacePhysicsMakie: resolve_metadata

    # Test data
    metadata = Dict(
        "UNITS" => "km/s",
        "units" => "m/s",
        "LABLAXIS" => "Velocity",
        "DEPEND_0" => Dict("UNITS" => "seconds")
    )

    @testset "Direct lookup" begin
        @test resolve_metadata(metadata, "UNITS") == "km/s"
        @test resolve_metadata(metadata, :UNITS) === nothing
        @test resolve_metadata(metadata, "MISSING") === nothing
    end

    @testset "Priority lookup" begin
        @test resolve_metadata(metadata, ("UNITS", "units")) == "km/s"
        @test resolve_metadata(metadata, ("missing", "units")) == "m/s"
        @test isnothing(resolve_metadata(metadata, ("missing1", "missing2")))
    end

    @testset "Accessor pattern" begin
        accessor = data -> data["DEPEND_0"]
        @test resolve_metadata(metadata, accessor => "UNITS") == "seconds"
        @test isnothing(resolve_metadata(metadata, accessor => "MISSING"))
    end

    @testset "Default value pattern" begin
        @test resolve_metadata(metadata, "UNITS" => "default") == "km/s"
        @test resolve_metadata(metadata, "MISSING" => "default") == "default"
        @test resolve_metadata(metadata, ("UNITS", "units") => "default") == "km/s"
    end

    @testset "Computed default pattern" begin
        compute_default = data -> get(data, "LABLAXIS", "computed")
        @test resolve_metadata(metadata, "UNITS" => compute_default) == "km/s"
        @test resolve_metadata(metadata, "MISSING" => compute_default) == "Velocity"
    end

    @testset "Chained patterns" begin
        accessor = data -> data["DEPEND_0"]
        # Accessor with default
        @test resolve_metadata(metadata, accessor => ("UNITS" => "default")) == "seconds"
        @test resolve_metadata(metadata, accessor => ("MISSING" => "default")) == "default"

        # Accessor with priority lookup
        @test resolve_metadata(metadata, accessor => ("UNITS", "units")) == "seconds"
    end
end
