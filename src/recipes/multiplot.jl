# Like `series` in https://github.com/MakieOrg/Makie.jl/blob/master/Makie/src/basic_recipes/series.jl
# Also handle spectrogram

function multiplot!(ax, tas, args...; plottypes = (), kwargs...)
    c = _obs(tas)
    ptypes = _plottypes(plottypes)
    return map(eachindex(c[])) do i
        x = lift(cur -> transform(cur[i]), c)
        ptype = get(ptypes, i, plottype(x[]))
        pf = plotfunc!(ptype)
        pf(ax, x; kwargs...)
    end
end

"""
    multiplot(gp, tas::MultiPlottable, args...; axis=(;), kwargs...)

Setup the panel on a position and plot multiple time series on it
"""
function multiplot(gp, tas, args...; axis = (;), add_title = DEFAULTS.add_title, legend = (;), kwargs...)
    ax = Axis(gp; axis_attributes(tas, args...; add_title)..., axis...)
    plots = multiplot!(ax, values(tas), args...; kwargs...)
    !isnothing(legend) && add_legend!(gp, ax; legend...)
    return PanelAxesPlots(gp, AxisPlots(ax, plots))
end

function multiplot(gp, plottype::Type{<:AbstractPlot}, tas, args...; kwargs...)
    return multiplot(gp, tas, args...; plottype, kwargs...)
end

const MultiPlot = Plot{multiplot}
