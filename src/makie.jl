_to_color(x::ComputePipeline.Computed) = to_color(x[])
_to_color(x) = x
_axis_color(color) = (; yticklabelcolor = color, ylabelcolor = color, ytickcolor = color)

function gridposition(ax)
    gc = ax.layoutobservables.gridcontent[]
    return gc.parent[gc.span.rows, gc.span.cols]
end