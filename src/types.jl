# Type aliases for better code readability and maintainability
"""Union type for drawable containers that can hold plots"""
const Drawable = Union{Figure, GridPosition, GridSubposition}

"""Union type for data types supported by the plotting system"""
const SupportTypes = Union{AbstractArray{<:Number}, Function, String}

"""Union type for data that can be plotted as multiple series"""
const MultiPlottable = Union{AbstractVector{<:SupportTypes}, NamedTuple, Tuple}


@kwdef mutable struct Defaults
    add_title::Bool
    add_colorbar::Bool
    delay::Float64
    resample::Int
    position
end

"""
    DEFAULTS

A global constant that holds default parameters:

- `add_title::Bool` defaults to `false`.
- `add_colorbar::Bool` defaults to `true`.
- `delay` : in seconds, the time interval between updates. Default is 0.25.
- `resample::Int` : the number of points to resample to. Default is 6070.
"""
const DEFAULTS = Defaults(;
    add_title = false,
    add_colorbar = true,
    delay = 0.25,
    resample = 6070,
    position = Right()
)

# https://github.com/MakieOrg/AlgebraOfGraphics.jl/blob/master/src/entries.jl
struct FigureAxes
    figure::Figure
    axes::AbstractArray{Axis}
end

FigureAxes(gp::GridPosition, axes) = FigureAxes(gp.layout.parent, axes)
FigureAxes(gp::GridSubposition, axes) = FigureAxes(gp.parent, axes)

for f in (:hideydecorations!, :hidexdecorations!, :hidedecorations!, :hidespines!)
    @eval import Makie: $f
    @eval $f(fa::FigureAxes, args...; kwargs...) =
        foreach(fa.axes) do ax
        $f(ax, args...; kwargs...)
    end
end

struct AxisPlots
    axis::Axis
    plots
end

struct PanelAxesPlots
    pos
    axisPlots::Vector{AxisPlots}
end

PanelAxesPlots(pos, ap::AxisPlots) = PanelAxesPlots(pos, [ap])

"""
    DualAxisData(data1, data2; meta=nothing)

A type for handling dual-axis data where each field represents data for a different axis.
The first field is plotted against the left y-axis and the second field against the right y-axis.

# Fields
- `data1`: Data for the left y-axis
- `data2`: Data for the right y-axis
- `metadata`: Metadata for the data (e.g., title)
"""
struct DualAxisData{T1, T2, M}
    data1::T1
    data2::T2
    metadata::M
end

DualAxisData(data1, data2) = DualAxisData(data1, data2, nothing)

function Base.getindex(obj::DualAxisData, i::Int)
    i == 1 && return obj.data1
    i == 2 && return obj.data2
    throw(BoundsError(obj, i))
end

# Add length and iteration support for DualAxisData
Base.length(::DualAxisData) = 2
Base.iterate(obj::DualAxisData, state = 1) = state > 2 ? nothing : (obj[state], state + 1)


function Base.getproperty(obj::PanelAxesPlots, sym::Symbol)
    sym in fieldnames(PanelAxesPlots) && return getfield(obj, sym)
    return getproperty.(obj.axisPlots, sym)
end

Base.display(fg::FigureAxes) = display(fg.figure)
Base.show(io::IO, fg::FigureAxes) = show(io, fg.figure)
Base.show(io::IO, m::MIME, fg::FigureAxes) = show(io, m, fg.figure)
Base.show(io::IO, ::MIME"text/plain", fg::FigureAxes) = print(io, "FigureAxes()")
Base.showable(mime::MIME{M}, fg::FigureAxes) where {M} = showable(mime, fg.figure)

Base.iterate(fg::FigureAxes) = iterate((fg.figure, fg.axes))
Base.iterate(fg::FigureAxes, i) = iterate((fg.figure, fg.axes), i)

get_axes(f::Makie.AxisPlot) = [f.axis]
get_axes(f::AxisPlots) = [f.axis]
get_axes(f::PanelAxesPlots) = reduce(vcat, get_axes.(f.axisPlots))

"""
    Debouncer

A struct that creates a debounced version of a function `f`.

The debounced function will only execute after a specified `delay` (in seconds) of inactivity.
If called again before the delay expires, the `timer` resets.
"""
mutable struct Debouncer
    f::Function
    delay::Float64
    timer::Timer
end

Debouncer(f, delay) = Debouncer(f, delay, Timer(donothing, delay))

function (d::Debouncer)(args...; kwargs...)
    # Cancel any existing timer
    d.timer isa Timer && close(d.timer)

    # Create a new timer
    return d.timer = Timer(d.delay) do _
        d.f(args...; kwargs...)
    end
end
