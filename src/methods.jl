function gridposition(ax)
    gc = ax.layoutobservables.gridcontent[]
    gc.parent[gc.span.rows, gc.span.cols]
end

function tlims!(ax, tmin, tmax)
    dim_conversion = ax.dim1_conversion[]
    if dim_conversion isa Makie.DateTimeConversion
        xlims!(ax, DateTime(tmin), DateTime(tmax))
    elseif dim_conversion isa Makie.UnitfulConversion
        xlims!(ax, tmin, tmax)
    else
        xlims!(ax, Dates.value(tmin), Dates.value(tmax))
    end
    return current_figure()
end
tlims!(tmin, tmax) = tlims!(current_axis(), tmin, tmax)
tlims!(trange) = tlims!(trange...)

"""Add vertical lines to a plot"""
tlines!(ax, time; kwargs...) = vlines!(ax, Dates.value.(DateTime.(time)); kwargs...)
tlines!(time; kwargs...) = tlines!(current_axis(), time; kwargs...)
tlines!(faxes::FigureAxes, time; kwargs...) =
    foreach(faxes.axes) do ax
        tlines!(ax, time; kwargs...)
    end

"""
Get the default orientation for a legend based on the position
"""
function default_orientation(position)
    position in [Top(), Bottom()] ? :horizontal : :vertical
end

"""
Only add legend when the axis contains multiple labels
"""
function add_legend!(gp, ax; min=2, position=Right(), orientation=default_orientation(position), kwargs...)
    plots, labels = Makie.get_labeled_plots(ax; merge=false, unique=false)
    length(plots) < min && return
    Legend(gp[1, 1, position], ax; orientation, kwargs...)
end

"""
Only add legend when the axis contains multiple labels
"""
function add_legend!(ap::Makie.AxisPlot; kwargs...)
    ax = ap.axis
    gp = gridposition(ax)
    add_legend!(gp, ax; kwargs...)
end


# TODO: support legend merge for secondary axes
function add_legend!(p::PanelAxesPlots; kwargs...)
    ax = p.axisPlots[1].axis
    add_legend!(p.pos, ax; kwargs...)
end

"""
Add labels to a grid of layouts

# Notes
- See `tag_facet` in `egg` for reference
"""
function add_labels!(layouts::AbstractArray; labels='a':'z', open="(", close=")", position=TopLeft(), font=:bold, halign=:left, valign=:bottom, padding=(-5, 0, 5, 0), kwargs...)
    for (label, layout) in zip(labels, layouts)
        tag = open * label * close
        Label(
            layout[1, 1, position], tag;
            font, halign, valign, padding,
            kwargs...
        )
    end
end

_content(f) = contents(content(f))
_content(f::Figure) = f.content

"""
Add labels to a figure, automatically searching for blocks to label.

# Notes
- https://github.com/brendanjohnharris/Foresight.jl/blob/main/src/Layouts.jl#L2
"""
function add_labels!(f=current_figure(); allowedblocks=Union{Axis,Axis3,PolarAxis}, kwargs...)
    axs = filter(x -> x isa allowedblocks, _content(f))
    layouts = gridposition.(axs)
    add_labels!(unique(layouts); kwargs...)
end
