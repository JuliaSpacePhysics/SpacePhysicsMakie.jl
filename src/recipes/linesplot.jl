# https://github.com/MakieOrg/Makie.jl/blob/master/src/basic_recipes/series.jl
# https://github.com/rafaqz/DimensionalData.jl/blob/main/ext/DimensionalDataMakie.jl

# @recipe LinesPlot begin
#     cycle = [:color]
#     color = @inherit color
#     labels = nothing
#     plottype = Lines
#     predicate = nothing
#     # resample = 10000
# end

# function Makie.convert_arguments(::Type{<:LinesPlot}, x::AbstractVector, ys::AbstractMatrix)
#     A = parent(ys)
#     curves = map(i -> (x, view(A, :, i)), 1:size(A, 2))
#     return (curves,)
# end

# function Makie.plot!(plot::LinesPlot{<:Tuple{AbstractArray}})
#     curves = plot[1]
#     return map(eachindex(curves[])) do i
#         positions = lift(c -> c[i], plot, curves)
#         x = lift(x -> x[1], positions)
#         y = lift(x -> x[2], positions)
#         lines!(plot, x, y)
#     end
# end

# function Makie.plot!(plot::LinesPlot{<:Tuple{AbstractArray{<:Number}}})
#     A = resample(plot[1][])
#     x = makie_x(A)
#     lbs = something(plot.labels[], Some(labels(A)))
#     pf = plotfunc!(plot.plottype[])
#     for (i, col) in enumerate(eachcol(parent(A)))
#         _predicate(plot.predicate[], i) || continue
#         label = get(lbs, i, nothing)
#         pf(plot, plot.attributes, x, col; label)
#     end
#     return plot
# end

# Makie.get_plots(plot::LinesPlot) = plot.plots
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
    lbs = something(labels, Some(meta_labels(A)))
    pf = plotfunc!(plottype)
    N = size(A, 2)
    return map(1:N) do i
        y = @views parent(A)[:, i]
        pf(ax, x, y; label = get(lbs, i, nothing), kwargs...)
    end
end

linesplot!(ax::Axis, A; labels = nothing, plottype = Lines, kwargs...) =
    linesplot!(ax, makie_x(A), A; labels, plottype, kwargs...)

# Create plots that automatically update when compute graph changes
function linesplot!(ax::Axis, A::Computed; labels = nothing, plottype = Lines, kwargs...)
    x_obs = lift(makie_x, A)
    lbs = something(labels, Some(meta_labels(A[])))
    pf = plotfunc!(plottype)
    N = size(A[], 2)
    return map(1:N) do i
        y_obs = lift(A) do data
            @views parent(data)[:, i]
        end
        pf(ax, x_obs, y_obs; label = get(lbs, i, nothing), kwargs...)
    end
end

linesplot!(args; kwargs...) = linesplot!(current_axis(), args; kwargs...)

function linesplot(A; kwargs...)
    f = Figure()
    ap = linesplot(f[1, 1], A; kwargs...)
    return FigureAxes(f, ap.axis)
end
