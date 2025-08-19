# https://github.com/MakieOrg/Makie.jl/blob/master/src/basic_recipes/series.jl
# https://github.com/rafaqz/DimensionalData.jl/blob/main/ext/DimensionalDataMakie.jl

@recipe LinesPlot begin
    labels = nothing
    plottype = Lines
    predicate = nothing
    # resample = 10000
end

function plot2spec(::Type{<:LinesPlot}, da::AbstractMatrix; labels = labels(da), kws...)
    da = resample(da)
    x = makie_x(da)
    return map(enumerate(eachcol(parent(da)))) do (i, y)
        S.Lines(x, y; label = get(labels, i, nothing), kws...)
    end
end

function plot2spec(::Type{<:LinesPlot}, da::AbstractVector; labels = nothing, label = nothing, kws...)
    label = @something label labels to_value(SpacePhysicsMakie.label(da))
    return S.Lines(makie_x(da), parent(da); label, kws...)
end

function Makie.convert_arguments(::Type{<:LinesPlot}, x::AbstractVector, ys::AbstractMatrix)
    A = parent(ys)
    curves = map(i -> (x, view(A, :, i)), 1:size(A, 2))
    return (curves,)
end

function Makie.plot!(plot::LinesPlot{<:Tuple{AbstractArray}})
    curves = plot[1]
    return map(eachindex(curves[])) do i
        positions = lift(c -> c[i], plot, curves)
        x = lift(x -> x[1], positions)
        y = lift(x -> x[2], positions)
        lines!(plot, x, y)
    end
end

_predicate(::Nothing, i) = true
_predicate(pred, i) = pred(i)

function Makie.plot!(plot::LinesPlot{<:Tuple{AbstractArray{<:Number}}})
    A = resample(plot[1][])
    x = makie_x(A)
    lbs = something(plot.labels[], Some(labels(A)))
    pf = plotfunc!(plot.plottype[])
    for (i, col) in enumerate(eachcol(parent(A)))
        _predicate(plot.predicate[], i) || continue
        label = get(lbs, i, nothing)
        pf(plot, x, col; label)
    end
    return plot
end

Makie.get_plots(plot::LinesPlot) = plot.plots

"""
    linesplot(gp, ta)

Plot a multivariate time series on a panel
"""
function linesplot(gp::Drawable, ta; axis = (;), add_title = DEFAULTS.add_title, plot = (;), kwargs...)
    ax = Axis(gp; axis_attributes(ta; add_title)..., axis...)
    plots = linesplot!(ax, ta; plot..., kwargs...)
    return PanelAxesPlots(gp, AxisPlots(ax, plots))
end
