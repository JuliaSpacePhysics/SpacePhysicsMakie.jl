get_xrange(limit) = (limit.origin[1], limit.origin[1] + limit.widths[1])

# Reactive value carriers. `Computed` comes from Makie's ComputePipeline (used by
# `iviz_api!`); `Observable` is what `lift` produces. They are not in a common
# supertype, so we union them for dispatch.
const Reactive = Union{ComputePipeline.Computed, Observable}

# Normalize a recipe input to a reactive
_obs(A::Reactive) = A
_obs(A) = Observable(A)

"Plot `f` over `trange` on `ax`, refetching when the view leaves the loaded range."
function iviz_api!(ax::Axis, f, trange; data = plottable(getdata(f, trange...)), delay = setting(:delay), kw...)
    graph = ComputeGraph()
    add_input!(graph, :trange, trange)
    add_input!(graph, :data, data)
    plots = plotfunc!(data)(ax, graph[:data]; kw...)
    tlims!(ax, trange...)

    function update(lims)
        t0, t1 = x2t.(get_xrange(lims))
        loaded0, loaded1 = graph[:trange][]
        (t0 < loaded0 || t1 > loaded1) || return
        update!(graph; trange = (t0, t1), data = plottable(getdata(f, t0, t1)))
        return
    end
    on(Debouncer(update, delay), ax.finallimits)
    return plots
end

iviz_api(f, args...; kwargs...) = iviz_api!(current_axis(), f, args...; kwargs...)
