@testitem "tlines! and tvspan! on time axes" begin
    using Makie, Dates, DimensionalData
    t = DateTime(2020) .+ Hour.(0:9)
    ms = Dates.value.(t)
    faxes = tplot([rand(Ti(t)), rand(Ti(t))])
    ax = faxes.axes[1]
    @test ax.dim1_conversion[] isa Makie.DateTimeConversion

    @test only(tlines!(ax, t[2]).converted[][1]) == ms[2]
    rects = tvspan!(ax, t[[2, 5]], t[[3, 6]]).rects[]
    @test [r.origin[1] for r in rects] == ms[[2, 5]]
    @test [r.widths[1] for r in rects] == ms[[3, 6]] .- ms[[2, 5]]

    tvspan!(faxes, t[7], t[8])
    @test all(ax -> count(p -> p isa VSpan, ax.scene.plots) == 1 + (ax === faxes.axes[1]), faxes.axes)
end
