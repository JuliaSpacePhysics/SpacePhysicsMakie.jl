# https://github.com/MakieOrg/Makie.jl/blob/master/src/basic_recipes/series.jl
# https://github.com/rafaqz/DimensionalData.jl/blob/main/ext/DimensionalDataMakie.jl

function linesplot end
const LinesPlot = Plot{linesplot}

"""
    linesplot(gp, ta)

Plot a multivariate time series on a panel
"""
function linesplot(gp::Drawable, A; axis = (;), add_title = DEFAULTS.add_title, legend = (;), plot = (;), kwargs...)
    ax = Axis(gp; axis_attributes(A; add_title)..., axis...)
    plots = linesplot!(ax, A; plot..., kwargs...)
    !isnothing(legend) && add_legend!(gp, ax; legend...)
    return AxisPlots(ax, plots)
end

function linesplot!(ax::Axis, x, A; labels = nothing, plottype = Lines, kwargs...)
    Av = _value(A)
    lbs = something(labels, Some(meta_labels(Av)))
    pf = plotfunc!(plottype)
    odim = otherdimnum(Av)
    N = size(Av, odim)
    return map(1:N) do i
        y = _lift(a -> selectdim(parent(a), odim, i), A)
        pf(ax, x, y; label = get(lbs, i, nothing), kwargs...)
    end
end

linesplot!(ax::Axis, A; labels = nothing, plottype = Lines, kwargs...) =
    linesplot!(ax, _lift(makie_x, A), A; labels, plottype, kwargs...)

linesplot!(args; kwargs...) = linesplot!(current_axis(), args; kwargs...)

function linesplot(A; kwargs...)
    f = Figure()
    ap = linesplot(f[1, 1], A; kwargs...)
    return FigureAxes(f, ap.axis)
end

timedimnum(A) = 1
otherdimnum(A) = if timedimnum(A) == 1
    2
else
    1
end
