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

_has_timedim(x) = hasproperty(x, :time) || hasproperty(x, :times) || hasproperty(x, :dims)

function plottype(x)
    return if _has_timedim(x)
        isspectrogram(x) ? SpecPlot : LinesPlot
    elseif eltype(x) <: Number
        # Makie default plottype for AbstractVector is Scatter
        # We change it to Lines
        x isa AbstractVector ? vector_plottype() : Makie.plottype(x)
    else
        MultiPlot
    end
end
plottype(::MultiAxisData) = MultiAxisPlot
plottype(::Function) = FunctionPlot
plottype(args...) = plottype(args[1])

plotfunc(args...) = Makie.plotfunc(plottype(args...))
plotfunc(T::Type{<:AbstractPlot}) = Makie.plotfunc(T)
plotfunc!(args...) = Makie.plotfunc!(plottype(args...))
plotfunc!(T::Type{<:AbstractPlot}) = Makie.plotfunc!(T)
plotfunc(::Tuple) = multiaxisplot

"""
    tplot_panel(gp, args...; kwargs...)

Generic entry point for plotting different types of data on a grid position `gp`.

Transforms the arguments to appropriate types and calls the plotting function.
Dispatches to appropriate implementation based on the plotting trait of the transformed arguments.
"""
function tplot_panel(gp, data, args...; transform = transform, verbose = false, kwargs...)
    transformed = transform(data, args...)
    pf = plotfunc(transformed)
    @debug "$(pf) data of type $(typeof(transformed))"
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
