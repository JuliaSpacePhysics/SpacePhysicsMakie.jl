# Reference
# - https://docs.makie.org/dev/explanations/recipes
# - https://github.com/MakieOrg/Makie.jl/blob/master/src/basic_recipes/scatterlines.jl


@recipe PanelPlot begin
    cycle = [:color]
    plotfunc = plot!
    # Makie.mixin_generic_plot_attributes()...
end

# default fallback
function Makie.plot!(p::PanelPlot{<:NTuple{N,Any}}) where {N}
    plotfunc = p.plotfunc[]
    plotfunc(p, p[1:N]...)
end

function Makie.plot!(p::PanelPlot{<:Tuple{AbstractMatrix}})
    plotfunc = p.plotfunc[]
    plotfunc(p, p[1])
end

function Makie.plot!(p::PanelPlot{<:Tuple{AbstractVector{<:AbstractArray}}})
    vecofvec = p[1]
    plotfunc = p.plotfunc[]
    plotfunc.(p, vecofvec[])
end