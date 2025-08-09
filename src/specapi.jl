import Makie.SpecApi as S

# S.Colorbar(plots; label=clabel(ta))] # TODO: find a way to make SpecApi.Colorbar work on grid positions

function plot2spec(da; resample = (; verbose = true), kwargs...)
    da = SpacePhysicsMakie.resample(da; resample...)

    return if !isspectrogram(da)
        plot2spec(LinesPlot, da; kwargs...)
    else
        plot2spec(SpecPlot, da; kwargs...)
    end
end

plot2spec(T, da::AbstractArray, t0, t1; kw...) = plot2spec(T, tview(da, t0, t1); kw...)

plot2spec(nt::Union{NamedTuple, Tuple}; kwargs...) =
    map(collect(values(nt))) do da
    plot2spec(da; kwargs...)
end

"""
    tplot_panel_s!(ax::Axis, data; kwargs...)

Plot data on an axis.
"""
function tplot_panel_s!(ax::Axis, data; kwargs...)
    specs = plot2spec(data; kwargs...)
    return plotlist!(ax, specs)
end
