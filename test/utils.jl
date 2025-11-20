@testset "filter" begin
    using SpacePhysicsMakie: filter_by_keys
    d = Dict{Symbol, Any}(:a => 1, :b => 2, :c => 3)
    @test filter_by_keys(∈((:a, :b)), d) == Dict{Symbol, Any}(:a => 1, :b => 2)
    @test d == Dict{Symbol, Any}(:a => 1, :b => 2)
    nt = (a = 1, b = 2, c = 3)
    @test filter_by_keys(∈((:a, :b)), nt) == (a = 1, b = 2)
end

@testset "set_if_valid!" begin
    using SpacePhysicsMakie: set_if_valid!

    d = Dict{Symbol, Any}()

    # Test with valid value
    set_if_valid!(d, "valid", :key1)
    @test d[:key1] == "valid"

    # Test with empty string (should not set)
    set_if_valid!(d, "", :key2)
    @test !haskey(d, :key2)

    # Test with empty array (should not set)
    set_if_valid!(d, Int[], :key3)
    @test !haskey(d, :key3)

    # Test with nothing (should not set)
    set_if_valid!(d, nothing, :key4)
    @test !haskey(d, :key4)

    # Test with multiple pairs
    d2 = Dict{Symbol, Any}()
    set_if_valid!(d2, :key1 => "value1", :key2 => nothing, :key3 => "value3")
    @test d2[:key1] == "value1"
    @test !haskey(d2, :key2)
    @test d2[:key3] == "value3"
end

@testitem "resample" begin
    using SpacePhysicsMakie: resample
    # Test basic resampling
    arr = collect(1:100)
    resampled = resample(arr; n = 10)
    @test length(resampled) == 10
    @test resampled[1] == 1
    @test resampled[end] == 100

    # Test no resampling needed
    small_arr = [1, 2, 3]
    result = resample(small_arr; n = 10)
    @test result === small_arr  # Should return original array

    # Test 2D array resampling along different dimensions
    arr_2d = reshape(1:20, 4, 5)
    resampled_2d = resample(arr_2d; n = 2, dim = 1)
    @test size(resampled_2d) == (2, 5)

    resampled_2d_dim2 = resample(arr_2d; n = 3, dim = 2)
    @test size(resampled_2d_dim2) == (4, 3)
end
