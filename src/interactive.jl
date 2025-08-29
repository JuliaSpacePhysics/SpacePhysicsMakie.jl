get_xrange(limit) = (limit.origin[1], limit.origin[1] + limit.widths[1])

"""
Interactive plotting functionality for time series.
This file contains functions for interactive plotting of time series data.
"""

# https://github.com/MakieOrg/Makie.jl/pull/4630

function iviz_api!(ax::Axis, f, trange; delay=DEFAULTS.delay, kw...)
    graph = ComputeGraph()
    add_input!(graph, :input1, trange)
    map!(tr -> f(tr...), graph, :input1, :output) # register_computation!
    pf! = plotfunc!(graph[:output][])
    plots = pf!(ax, graph[:output]; kw...)

    axislimits = ax.finallimits
    # Keep track of the previous range
    prev_xrange = collect(get_xrange(axislimits[]))

    function update(lims)
        xrange = get_xrange(lims)
        # Update if new range extends beyond previously loaded range
        prev_xmin, prev_xmax = prev_xrange
        needs_update = xrange[1] < prev_xmin || xrange[2] > prev_xmax

        if needs_update
            trange = x2t.(xrange)
            update!(graph, input1 = trange)
            graph[:output]
            prev_xrange .= xrange
        end
    end
    on(Debouncer(update, delay), axislimits)

    return plots
end

iviz_api(f, args...; kwargs...) = iviz_api!(current_axis(), f, args...; kwargs...)