# Reference
# [ISTP Metadata Guidelines: Global Attributes](https://spdf.gsfc.nasa.gov/istp_guide/gattributes.html)
# [ISTP Metadata Guidelines: Variables](https://spdf.gsfc.nasa.gov/istp_guide/variables.html)
function ulabel(l, u; multiline = false)
    l == "" && return u
    u == "" && return l
    return multiline ? "$(l)\n($(u))" : "$(l) ($(u))"
end

_label(x) = SpaceDataModel.name(x)

function unit_str(A)
    u = unit(eltype(A))
    return u == NoUnits ? mget(A, (:unit, :units, "UNITS"), "") : string(u)
end

title(A) = mget(A, "CATDESC")

function yvalues(::Type{Vector}, x)
    vals = depend_1(x)
    return if isa(vals, AbstractMatrix)
        all(allequal, eachcol(vals)) || @warn "y values are not constant along time"
        vec(mean(vals; dims = 1))
    else
        vals
    end
end

depend_1(x) = unwrap(SpaceDataModel.dim(x, 2))
depend_1_name(x) = mget(depend_1(x), ("LABLAXIS", "FIELDNAM"))
depend_1_unit(x) = mget(depend_1(x), "UNITS", "")
get_depend_1_scale(x) = mget(depend_1(x), "SCALETYP", identity)

function ylabel(x; flag = isspectrogram(x), multiline = true)
    name = flag ? depend_1_name(x) : mget(x, "LABLAXIS", SpaceDataModel.name(x))
    ustr = flag ? depend_1_unit(x) : unit_str(x)
    name = string(something(name, ""))
    return ulabel(name, ustr; multiline)
end

label(ta) = prioritized_get(meta(ta), (:label, "LABLAXIS"), _label(ta))

_iter(x) = (x,)
_iter(x::AbstractVector) = x

function labels(x)
    lbls = @something mget(x, (:labels, "LABL_PTR_1")) mget(depend_1(x), "LABL_PTR_1") mget(x, "LABLAXIS") Some(nothing)
    return isnothing(lbls) ? NoMetadata() : _iter(lbls)
end

const meta_labels = labels

_scale_func(x) = (@warn "Unknown scale: $x"; identity)
_scale_func(f::Function) = f
function _scale_func(s::String)
    return if s == "linear"
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

yunit(x; flag = isspectrogram(x)) = flag ? unit(eltype(depend_1(x))) : unit(eltype(x))
yscale(x; flag = isspectrogram(x)) = flag ? get_depend_1_scale(x) : mget(x, "SCALETYP")

filter_by_keys(f, d) = length(d) == 0 ? Dict{Symbol, Any}() : filter(f ∘ first, pairs(d))
filter_by_keys!(f, d) = filter!(f ∘ first, pairs(d))
function filter_by_keys!(T::Type{<:AbstractPlot}, d)
    atts = Makie.attribute_names(T)
    return isnothing(atts) ? Dict{Symbol, Any}() : filter_by_keys!(∈(atts), d)
end

# This is slow for NamedTuple `NamedTuple{filter(f, keys(nt))}(nt)`
plottype_attributes(meta; allowed = (:labels, :label)) =
    filter_by_keys(∈(allowed), meta)

plot_attributes(ta; add_title = false) = Attributes(; axis = axis_attributes(ta; add_title))
plot_attributes(f::Function, args...; kwargs...) = plot_attributes(f(args...); kwargs...)
