"""
Panel plotting functionality for time series.
This module contains the `tplot_panel` function and its variants.
"""

pfdoc = """
Determine the plotting function for a given data type.
Extend this for custom data types to integrate with the plotting system.
"""

@doc pfdoc function plotfunc end
@doc pfdoc function plotfunc! end

# default fallback; like `Makie.plot` and handles `plottype` keyword argument
_plot(args...; plottype = Plot{plot}, kw...) = plotfunc(plottype)(args...; kw...)
_plot!(args...; plottype = Plot{plot}, kw...) = plotfunc!(plottype)(args...; kw...)

plottype(x) = eltype(x) <: Number ? Makie.plottype(x) : MultiPlot
plottype(::MultiAxisData) = MultiAxisPlot
plottype(::Function) = FunctionPlot
plottype(args...) = plottype(args[1])

plotfunc(args...) = Makie.plotfunc(plottype(args...))
plotfunc(T::Type{<:AbstractPlot}) = Makie.plotfunc(T)
plotfunc!(args...) = Makie.plotfunc!(plottype(args...))
plotfunc!(T::Type{<:AbstractPlot}) = Makie.plotfunc!(T)

plotfunc(::Tuple) = multiaxisplot
plotfunc(::Type{Plot{_plot}}) = _plot
plotfunc!(::Type{Plot{_plot}}) = _plot!

"""
    tplot_panel(gp, args...; kwargs...)

Generic entry point for plotting different types of data on a grid position `gp`.

Transforms the arguments to appropriate types and calls the plotting function.
Dispatches to appropriate implementation based on the plotting trait of the transformed arguments.
"""
function tplot_panel(gp, data, args...; transform = transform, verbose = false, kwargs...)
    transformed = transform(data, args...)
    pf = plotfunc(transformed)
    verbose && @info "$(pf) data of type $(typeof(transformed))"
    return pf(gp, transformed, args...; kwargs...)
end

"""
    tplot_panel!(ax, args...; kwargs...)

Generic entry point for adding plots to an existing axis `ax`.

Transforms the arguments to appropriate types and calls the plotting function.
Dispatches to appropriate implementation based on the plotting trait of the transformed arguments.
"""
function tplot_panel!(ax::Axis, data, args...; kwargs...)
    transformed = transform(data, args...)
    pf! = plotfunc!(transformed)
    return pf!(ax, transformed, args...; kwargs...)
end

tplot_panel!(args...; kwargs...) = tplot_panel!(current_axis(), args...; kwargs...)
