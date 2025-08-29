import Makie.SpecApi as S

# S.Colorbar(plots; label=clabel(ta))] # TODO: find a way to make SpecApi.Colorbar work on grid positions
# function plot2spec(::Type{<:LinesPlot}, da::AbstractMatrix; labels=labels(da), kws...)
#     da = resample(da)
#     x = makie_x(da)
#     return map(enumerate(eachcol(parent(da)))) do (i, y)
#         S.Lines(x, y; label=get(labels, i, nothing), kws...)
#     end
# end

# function plot2spec(::Type{<:LinesPlot}, da::AbstractVector; labels=nothing, label=nothing, kws...)
#     label = @something label labels to_value(SpacePhysicsMakie.label(da))
#     return S.Lines(makie_x(da), parent(da); label, kws...)
# end


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
