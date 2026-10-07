@recipe SpecPlot begin end


"""
    specplot(gp, ta)

Plot a spectrogram on a panel
"""
function specplot(gp, ta; axis = (;), add_colorbar = setting(:add_colorbar), add_title = setting(:add_title), position = setting(:position), alignmode = Outside(), kwargs...)
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

"""
    specplot!(ax, A; bin = setting(:bin), kwargs...)

Plot the spectrogram `A` on `ax`, one flat cell per sample and channel. Samples narrower than a pixel
are merged with `bin` (applied to their non-NaN values; `nothing` draws every sample), and re-merged as the view changes.
"""
function specplot!(ax::Axis, A; bin = setting(:bin), kwargs...)
    A = _obs(A)
    attrs = heatmap_attributes(A[]; kwargs...)
    colorscale = @something pop!(attrs, :colorscale, nothing) _colorscale(_time_first(A[], parent(A[])))
    cells = lift(A) do a
        x = makie_x(a)
        M = float.(ustrip.(_time_first(a, parent(a))))
        colorscale in (log10, log) && replace!(M, 0 => NaN)
        lo, hi = sample_cells(_num.(x))
        Y = channel_edges(_time_first(a, unwrap(depend_1(a))), ax.yscale[])
        (; lo, hi, M, Y, T = eltype(x))
    end
    grid = lift(cells, ax.finallimits, ax.scene.viewport) do c, limits, viewport
        lo, hi, M, Y = isnothing(bin) ? (c.lo, c.hi, c.M, c.Y) :
            merge_cells(c.lo, c.hi, c.M, c.Y, pixel_stop(c.lo, c.hi, limits, viewport), bin)
        xx, yy, C = cell_grid(lo, hi, M, Y)
        return (_fromnum.(c.T, xx), yy, C)
    end
    return surface!(
        ax, lift(g -> g[1], grid), lift(g -> g[2], grid), lift(g -> zeros(size(g[3])), grid);
        color = lift(g -> g[3], grid), shading = NoShading, colorscale, attrs...
    )
end

# A time-varying `depend_1` is laid out like the data, so it is transposed with it.
_time_first(a, m::AbstractMatrix) = timedimnum(a) == ndims(a) ? transpose(m) : m
_time_first(a, v) = v
