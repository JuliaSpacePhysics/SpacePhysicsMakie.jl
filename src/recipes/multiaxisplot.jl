# Multi-axis plotting for N secondary y-axes
# Reference:
# https://discourse.julialang.org/t/makie-multiple-y-axes-align-yticks/116471
# https://matplotlib.org/stable/gallery/subplots_axes_and_figures/secondary_axis.html

# Plot type constant for dispatch
const dualplot = multiaxisplot
const MultiAxisPlot = Plot{multiaxisplot}

# Default colors for multiple axes (extending wong_colors)
const _multi_axis_colors = [
    Makie.wong_colors()[1],       # Primary (blue)
    Makie.wong_colors()[2],       # Secondary 1 (same as _dual_color2)
    Makie.wong_colors()[3],       # Secondary 2 (green)
    Makie.wong_colors()[4],       # Secondary 3 (orange)
    Makie.wong_colors()[5],       # Secondary 4 (purple)
    Makie.wong_colors()[6],       # Secondary 5
]

# Default plot styles for secondary axes
const _multi_axis_styles = [
    (;),                                           # Primary: solid
    (; linestyle = :dash, marker = :rect),         # Secondary 1
    (; linestyle = :dot, marker = :diamond),       # Secondary 2
    (; linestyle = :dashdot, marker = :utriangle), # Secondary 3
    (; linestyle = :dashdotdot, marker = :star5),  # Secondary 4
]

"Create and configure a secondary y-axis"
function make_secondary_axis(gp; color = Makie.wong_colors()[6], yaxisposition = :right, kwargs...)
    color = _to_color(color)
    ax2 = Axis(gp; yaxisposition, _axis_color(color)..., rightspinecolor = color, kwargs...)
    Makie.hidespines!(ax2)
    Makie.hidexdecorations!(ax2)
    return ax2
end

n_child_plot(ptype, x) = 1
n_child_plot(::Type{<:MultiPlot}, x) = length(x)

"""
    multiaxisplot(gp, primary, secondaries...; pad_increment = 50.0, [colors, styles, plottypes, axis], kwargs...)

Create a plot with one primary y-axis (left) for `primary` and multiple secondary y-axes (right) for `secondaries...`.

Each secondary axis is offset to the right with increasing padding of `pad_increment` to avoid overlap.

# Attributes
- `colors`: Vector of colors for each axis (default: Wong color palette)
- `styles`: Vector of NamedTuples with plot attributes for each secondary axis
- `plottypes`: Plot types to use, a single type would be broadcasted to all axes
"""
function multiaxisplot(
        gp::Drawable, data::MultiAxisData, args...;
        colors = _multi_axis_colors,
        styles = _multi_axis_styles,
        pad_increment = 50.0,
        plottypes = (),
        axis = (;),
        add_title = DEFAULTS.add_title,
        kwargs...
    )
    secondaries = data.secondaries
    n_axes = 1 + length(secondaries)
    ptypes = _plottypes(plottypes)

    # Ensure we have enough colors and styles
    if length(colors) < n_axes
        colors = vcat(colors, [Makie.wong_colors()[mod1(i, 7)] for i in (length(colors) + 1):n_axes])
    end
    if length(styles) < n_axes
        styles = vcat(styles, [_multi_axis_styles[end] for _ in (length(styles) + 1):n_axes])
    end

    axis_plots = AxisPlots[]

    ci = 0
    # Primary axis
    color1 = _to_color(colors[1])
    let primary = transform(data.primary, args...)
        ax1 = Axis(
            gp;
            leftspinecolor = color1,
            _axis_color(color1)...,
            axis_attributes(primary; add_title)...,
            axis...
        )
        ptype = get(ptypes, 1, plottype(primary))
        pf1 = plotfunc!(ptype)
        attrs1 = filter_by_keys!(ptype, _dict(; color = color1, style = styles[1], kwargs...))
        plots1 = pf1(ax1, primary, args...; attrs1...)
        push!(axis_plots, AxisPlots(ax1, plots1))
        ci += n_child_plot(ptype, primary)
    end

    # Secondary axes
    for (i, sec_data) in enumerate(secondaries)
        sec = transform(sec_data, args...)
        color = _to_color(colors[i + ci])
        style = i < length(styles) ? styles[i + 1] : styles[end]
        pad = (i - 1) * pad_increment
        ax = make_secondary_axis(
            gp;
            color,
            yticklabelpad = pad,
            axis_attributes(sec; add_title = false)...
        )

        ptype = get(ptypes, i + 1, plottype(sec))
        attrs = filter_by_keys!(ptype, _dict(; color, style..., kwargs...))
        plots = plotfunc!(ptype)(ax, sec, args...; attrs...)
        push!(axis_plots, AxisPlots(ax, plots))
        ci += n_child_plot(ptype, sec)
    end
    return PanelAxesPlots(gp, axis_plots)
end

multiaxisplot(gp::Drawable, args...; kwargs...) = multiaxisplot(gp, args; kwargs...)

function multiaxisplot(gp::Drawable, t::Tuple; kwargs...)
    i = findlast(x -> x isa AbstractArray || x isa Function, t)
    @assert i >= 2
    primary = t[1]
    secondaries = t[2:i]
    return multiaxisplot(gp, MultiAxisData(primary, secondaries), t[(i + 1):end]...; kwargs...)
end


"Create figure automatically"
function multiaxisplot(args...; figure = (;), kwargs...)
    fig = Figure(; figure...)
    multiaxisplot(fig[1, 1], args...; kwargs...)
    return fig
end
