@recipe FunctionPlot begin
    plotfunc = tplot_panel!
end

"""
    functionplot(gp, f, tmin, tmax; kwargs...)

Interactively plot a source `f` (see `DataSource`) over a time range on a grid position
"""
function functionplot(gp, f, tmin, tmax; axis = (;), add_title = setting(:add_title), add_colorbar = setting(:add_colorbar), plot = (;), kwargs...)
    # get a sample data to determine the attributes and plot types
    tmin, tmax = _compat(tmin), _compat(tmax)
    data = transform(getdata(f, tmin, tmax))
    attrs = process_axis_attributes!(_source_axis_attributes(f, data; add_title))
    ax = Axis(gp; attrs..., axis...)
    plot = _merge(plottype_attributes(getmeta(f)), plot)
    p = functionplot!(ax, f, tmin, tmax; plot, kwargs...)
    isspectrogram(data) && add_colorbar && Colorbar(gp[1, 2], p; label = clabel(data))
    return PanelAxesPlots(gp, AxisPlots(ax, p))
end

# Need to convert string to DateTime for ComputePipeline
_compat(x::String) = DateTime(x)
_compat(x) = x

"""
    functionplot!(ax, f, tmin, tmax; kwargs...)

Interactive plot of a function `f` on `ax` for a time range from `tmin` to `tmax`
"""
function functionplot!(ax, f, tmin, tmax; plot = (;), kwargs...)
    return iviz_api!(ax, f, (tmin, tmax); plot..., kwargs...)
end

"""
    multiplot!(ax, fs, tmin, tmax; kwargs...)

Overlay several sources on `ax`, fetched together so they refetch together on zoom.
"""
function multiplot!(ax, fs, tmin, tmax; kwargs...)
    tmin, tmax = _compat(tmin), _compat(tmax)
    func = (t0, t1) -> map(fs) do f
        transform(getdata(f, t0, t1))
    end
    return iviz_api!(ax, func, (tmin, tmax); kwargs...)
end
