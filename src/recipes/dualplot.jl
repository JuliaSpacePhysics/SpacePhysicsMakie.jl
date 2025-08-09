# https://github.com/MakieOrg/Makie.jl/blob/master/src/basic_recipes/ablines.jl

const _dual_color2 = Makie.wong_colors()[end - 3]
const _dual_plot2 = (; linestyle = :dash, marker = :rect)

@recipe DualPlot begin
    plottype = ScatterLines
    color2 = _dual_color2  # Default color for second axis
    plot2 = _dual_plot2 # Default linestyle for second axis and marker for second axis
end

"Setup the panel with both primary and secondary y-axes"
function dualplot(
        gp::Drawable, ax1tas, ax2tas, args...;  
        color2 = _dual_color2, plot2 = _dual_plot2,
        plottype = ScatterLines, axis = (;), add_title = DEFAULTS.add_title, kwargs...
    )
    # Primary axis
    ax1 = Axis(gp; axis_attributes(ax1tas, args...; add_title)..., axis...)
    pf1 = plotfunc!(ax1tas)
    plots1 = pf1(ax1, ax1tas, args...; plottype, kwargs...)

    # Secondary axis
    ax2 = make_secondary_axis(gp; color = color2, axis_attributes(ax2tas, args...; add_title = false)...)
    pf2 = plotfunc!(ax2tas)
    plots2 = pf2(ax2, ax2tas, args...; color = color2, plottype, plot2..., kwargs...)

    return PanelAxesPlots(gp, [AxisPlots(ax1, plots1), AxisPlots(ax2, plots2)])
end

dualplot(gp::Drawable, data, args...; kwargs...) = dualplot(gp, data[1], data[2], args...; kwargs...)

"Create and configure a secondary y-axis"
function make_secondary_axis(gp; color = Makie.wong_colors()[6], kwargs...)
    ax2 = Axis(
        gp;
        yaxisposition = :right,
        yticklabelcolor = color,
        ylabelcolor = color,
        rightspinecolor = color,
        ytickcolor = color,
        kwargs...
    )
    hidespines!(ax2)
    hidexdecorations!(ax2)
    return ax2
end


function Makie.plot!(p::DualPlot)
    data1 = p[1][]
    pt1 = pt2 = p.plottype[]
    pf1 = plotfunc!(data1)
    pf1(p, data1; plottype = pt1)

    # Plot on the second axis with distinctive styling
    data2 = p[2][]
    gp = gridposition(current_axis())
    ax2 = make_secondary_axis(gp; color = p.color2, axis_attributes(data2; add_title = false)...)
    pf2 = plotfunc!(data2)
    return pf2(ax2, data2; plottype = pt2, color = p.color2, p.plot2[]...)
end
