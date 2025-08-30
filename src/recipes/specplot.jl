@recipe SpecPlot begin end


"""
    specplot(gp, ta)

Plot a spectrogram on a panel
"""
function specplot(gp, ta; axis = (;), add_colorbar = DEFAULTS.add_colorbar, add_title = DEFAULTS.add_title, position = DEFAULTS.position, kwargs...)
    ax = Axis(gp; axis_attributes(ta; add_title)..., axis...)
    plots = specplot!(ax, ta; kwargs...)
    add_colorbar && isspectrogram(ta) && Colorbar(gp[1, 1, position], plots; label = clabel(ta))
    return PanelAxesPlots(gp, AxisPlots(ax, plots))
end

"""
Plot heatmap of a time series on the same axis
"""
function specplot!(ax::Axis, A; labels = labels(A), verbose = true, kwargs...)
    A = resample(A; verbose)

    x = makie_x(A)
    y = spectrogram_y_values(A)
    attrs = heatmap_attributes(A; kwargs...)
    heatmap!(ax, x, y, parent(A); attrs...)
end

function plot2spec(::Type{<:SpecPlot}, da; kwargs...)
    x = makie_x(da)
    y = spectrogram_y_values(da)
    @info size(x), size(y), size(parent(da))
    attributes = heatmap_attributes(da; kwargs...)
    return S.Heatmap(x, y, parent(da); attributes...)
end

# https://github.com/MakieOrg/Makie.jl/issues/5193
using Makie: GridBased, RangeLike, Colorant, to_linspace
# function Makie.convert_arguments(P::GridBased, x::RangeLike, y::RangeLike, z::AbstractMatrix{<:Union{Real, Colorant}})
    # (to_linspace(x, size(z, 1)), to_linspace(y, size(z, 2)), z)
# end

# Makie.to_linspace(x::AbstractVector{DateTime}, N) = range(first(x), step=Millisecond(Millisecond(x[end]-x[begin]).value/(N-1) |> round), length=N)
# Makie.to_linspace(x::AbstractVector{DateTime}, N) = range(first(x), stop = last(x), length = N) 