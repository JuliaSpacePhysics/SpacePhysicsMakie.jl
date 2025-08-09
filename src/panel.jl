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

# default fallback
_plot(args...; plottype = Plot{plot}, kw...) = plotfunc(plottype)(args...; kw...)
_plot!(args...; plottype = Plot{plot}, kw...) = plotfunc!(plottype)(args...; kw...)

plottype(::Any) = Plot{_plot}
plottype(x::AbstractVector{<:Number}) = Plot{_plot}

plottype(::AbstractVector) = MultiPlot
plottype(::NamedTuple) = MultiPlot
plottype(::Tuple) = MultiPlot
plottype(::DualAxisData) = DualPlot
plottype(::NTuple{2, Any}) = DualPlot
plottype(::Function) = FunctionPlot
plottype(args...) = plottype(args[1])

plotfunc(args...) = Makie.MakieCore.plotfunc(plottype(args...))
plotfunc(T::Type{<:AbstractPlot}) = Makie.MakieCore.plotfunc(T)
plotfunc!(args...) = Makie.MakieCore.plotfunc!(plottype(args...))
plotfunc!(T::Type{<:AbstractPlot}) = Makie.MakieCore.plotfunc!(T)

plotfunc(::NTuple{2, Any}) = dualplot
plotfunc(::Type{Plot{_plot}}) = _plot
plotfunc!(::Type{Plot{_plot}}) = _plot!

"""
    tplot_panel(gp, args...; kwargs...)

Generic entry point for plotting different types of data on a grid position `gp`.

Transforms the arguments to appropriate types and calls the plotting function.
Dispatches to appropriate implementation based on the plotting trait of the transformed arguments.
"""
function tplot_panel(gp, data, args...; transform = transform_pipeline, verbose = false, kwargs...)
    transformed = transform(data, args...)
    verbose && @info "Plotting $(typeof(transformed))"
    pf = plotfunc(transformed)
    return pf(gp, transformed, args...; kwargs...)
end

"""
    tplot_panel!(ax, args...; kwargs...)

Generic entry point for adding plots to an existing axis `ax`.

Transforms the arguments to appropriate types and calls the plotting function.
Dispatches to appropriate implementation based on the plotting trait of the transformed arguments.
"""
function tplot_panel!(ax::Axis, data, args...; kwargs...)
    transformed = transform_pipeline(data, args...)
    pf! = plotfunc!(transformed)
    return pf!(ax, transformed, args...; kwargs...)
end

tplot_panel!(args...; kwargs...) = tplot_panel!(current_axis(), args...; kwargs...)
