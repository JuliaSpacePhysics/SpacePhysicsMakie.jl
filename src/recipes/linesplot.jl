# https://github.com/MakieOrg/Makie.jl/blob/master/src/basic_recipes/series.jl
# https://github.com/rafaqz/DimensionalData.jl/blob/main/ext/DimensionalDataMakie.jl

# function Makie.plot!(plot::LinesPlot{<:Tuple{AbstractArray}})
#     curves = plot[1]
#     return map(eachindex(curves[])) do i
#         positions = lift(c -> c[i], plot, curves)
#         x = lift(x -> x[1], positions)
#         y = lift(x -> x[2], positions)
#         lines!(plot, x, y)
#     end
# end

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
    odim = otherdimnum(A)
    N = size(A, odim)
    return map(1:N) do i
        y = selectdim(parent(A), odim, i)
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
    odim = otherdimnum(A[])
    N = size(A[], odim)
    return map(1:N) do i
        y_obs = lift(A) do data
            selectdim(parent(data), odim, i)
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

timedimnum(A) = 1
otherdimnum(A) = if timedimnum(A) == 1
    2
else
    1
end
