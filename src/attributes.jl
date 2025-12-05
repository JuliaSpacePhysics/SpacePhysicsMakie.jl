_string(x) = string(x)
_string(::Nothing) = ""

ulabel(::Nothing, ::Nothing; kw...) = ""
ulabel(l::Nothing, u; kw...) = string(u)
ulabel(l, u::Nothing; kw...) = string(l)
function ulabel(l, u; multiline = false)
    l == "" && return string(u)
    u == "" && return string(l)
    return multiline ? "$(l)\n($(u))" : "$(l) ($(u))"
end

# Like `eltype`, but recursively applies to arrays to get the innermost element type
function numtype(x)
    T = eltype(x)
    return T <: AbstractArray ? numtype(T) : T
end

# Return the unit of the data:
# If A is a Unitful object, return the unit of A
# Otherwise, return the unit from the metadata schema
function _unit(A; schema = get_schema(A))
    u = Unitful.unit(numtype(A))
    return u == NoUnits ? schema(A)[:unit] : u
end

"""
    labels(x; schema=get_schema(x))

Get the labels for `data` using the metadata `schema`.
"""
labels(x; schema = get_schema(x)) = _labels(
    @something(
        schema(x, :labels),
        schema(depend_1(x), :labels),
        Some(nothing)
    )
)

labels(x::AbstractVector; schema = get_schema(x)) =
    _labels(schema(x, :labels))

labels(x::Computed; kw...) = labels(x[]; kw...)

_labels(::Nothing) = NoMetadata()
_labels(x::AbstractVector) = x
_labels(x) = (x,)

const meta_labels = labels

_scale_func(x) = (@warn "Unknown scale: $x"; identity)
_scale_func(f::Function) = f
function _scale_func(s::String)
    return if s == "linear" || s == "LINEAR"
        identity
    elseif s == "log10" || s == "log"
        log10
    else
        @warn "Unknown scale: $s"
        identity
    end
end

function scale(x, sources)
    return _scale_func(
        prioritized_get(meta(x), sources, identity)
    )
end

filter_by_keys(f, d) = length(d) == 0 ? Dict{Symbol, Any}() : filter(f ∘ first, pairs(d))
filter_by_keys!(f, d) = filter!(f ∘ first, pairs(d))
function filter_by_keys!(T::Type{<:AbstractPlot}, d)
    atts = Makie.attribute_names(T)
    return isnothing(atts) ? Dict{Symbol, Any}() : filter_by_keys!(∈(atts), d)
end

function plottype_attributes(A; schema = get_schema(A))
    attrs = Dict{Symbol, Any}()
    lookup = SchemaLookup(schema, A)
    set_if_valid!(attrs; labels = lookup[:labels])
    return attrs
end

function plot_attributes(A; schema = get_schema(A), kw...)
    return Dict(
        :axis => axis_attributes(A; schema, kw...),
        :plot => plottype_attributes(A; schema)
    )
end
plot_attributes(f::Function, args...; kwargs...) = plot_attributes(f(args...); kwargs...)
