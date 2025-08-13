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
        edges = binedges(centers, transform=log)
        @test edges ≈ 10. .^ (-0.5:2.5)
    end
    
    @testset "Units support" begin
        # Test with Unitful quantities
        centers = [1.0, 2.0, 3.0] * u"m"
        edges = binedges(centers)
        expected = [0.5, 1.5, 2.5, 3.5] * u"m"
        @test edges ≈ expected
        
        # Test units are preserved with transforms
        edges_log = binedges(centers, transform=log)
        @test unit(edges_log[1]) == u"m"
    end
end