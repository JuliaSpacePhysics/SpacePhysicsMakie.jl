@recipe SpecPlot begin end


"""
    specplot(gp, ta)

Plot a spectrogram on a panel
"""
function specplot(gp, ta; axis = (;), add_colorbar = DEFAULTS.add_colorbar, add_title = DEFAULTS.add_title, position = DEFAULTS.position, alignmode = Outside(), kwargs...)
    ax = Axis(gp[1, 1]; axis_attributes(ta; add_title)..., axis...)
    plots = specplot!(ax, ta; kwargs...)
    add_colorbar && isspectrogram(ta) && Colorbar(gp[1, 1, position], plots; label = clabel(ta), alignmode)
    return PanelAxesPlots(gp, AxisPlots(ax, plots))
end

# A temporary solution until https://github.com/MakieOrg/Makie.jl/issues/5193 is fixed
# Some optimizations are possible here https://discourse.julialang.org/t/virtual-or-lazy-representation-of-a-repeated-array/124954
function _heatmap!(ax, x, y, matrix; colorscale = log10, kw...)
    xx = repeat(x, 1, size(y, 1))
    yy = repeat(y', size(x, 1), 1)
    z = zero(matrix)
    return surface!(ax, xx, yy, z; color = matrix, shading = NoShading, colorscale, kw...)
end

"""
Plot heatmap of a time series on the same axis
"""
function specplot!(ax::Axis, A; labels = labels(A), verbose = true, kwargs...)
    A = resample(A; verbose)
    x = makie_x(A)
    y = spectrogram_y_values(A)
    attrs = heatmap_attributes(A; kwargs...)
    return _heatmap!(ax, x, y, parent(A); attrs...)
end

function plot2spec(::Type{<:SpecPlot}, da; kwargs...)
    x = makie_x(da)
    y = spectrogram_y_values(da)
    attributes = heatmap_attributes(da; kwargs...)
    return S.Heatmap(x, y, parent(da); attributes...)
end
