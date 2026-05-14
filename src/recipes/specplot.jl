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

const LOG_SCALE_THRESHOLD = 2.5

# Some educated guess about the color scale
function _colorscale(A)
    # If all values are positive (skipping NaNs) and span a large range, use log scale
    all(i -> !isfinite(i) || i > 0, A) && logspan(A) > LOG_SCALE_THRESHOLD && return log10
    return identity
end

function calc_colorrange(da; scale = 32)
    cmid = nanmedian(da)
    cmax = cmid * scale
    cmin = cmid / scale
    return (cmin, cmax)
end

set_colorrange!(x; kwargs...) = setmeta!(x; colorrange = calc_colorrange(x; kwargs...))

# A temporary solution until https://github.com/MakieOrg/Makie.jl/issues/5193 is fixed
# Related issue: https://github.com/MakieOrg/Makie.jl/issues/5460
# Some optimizations are possible here https://discourse.julialang.org/t/virtual-or-lazy-representation-of-a-repeated-array/124954
function _heatmap!(ax, x::Reactive, y::Reactive, matrix::Reactive; colorscale = nothing, kw...)
    colorscale = @something colorscale _colorscale(matrix[])
    mat = lift(matrix) do m
        m′ = ustrip.(m)
        colorscale in (log10, log) ? replace(m′, 0 => NaN) : m′
    end
    xx = lift((xv, m) -> repeat(xv, 1, size(m, 2)), x, matrix)
    yy = lift((yv, m) -> yv isa AbstractVector ? repeat(yv', size(m, 1), 1) : yv, y, matrix)
    z = lift(zero, mat)
    return surface!(ax, xx, yy, z; color = mat, shading = NoShading, colorscale, kw...)
end

"""
Plot heatmap of a time series on the same axis
"""
function specplot!(ax::Axis, A; kwargs...)
    A = _obs(A)
    attrs = heatmap_attributes(A[]; kwargs...)
    mat = lift(a -> tdimnum(a) == ndims(a) ? transpose(parent(a)) : parent(a), A)
    x = lift(makie_x, A)
    y = lift(depend_1, A)
    return _heatmap!(ax, x, y, mat; attrs...)
end
