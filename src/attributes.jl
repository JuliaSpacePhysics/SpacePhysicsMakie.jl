# Define functions that were previously imported from SPEDAS
using Statistics: mean
using DimensionalData
using SpaceDataModel: Product, AbstractDataVariable, AbstractProduct, AbstractDataSet

const xlabel_sources = (:xlabel, "xlabel")
const ylabel_sources = (:ylabel, :long_name, "long_name", :label, "LABLAXIS")
const labels_sources = (:labels, "labels", "LABL_PTR_1", "LABLAXIS")
const scale_sources = (:scale, "scale", "SCALETYP")
const yunit_sources = (:yunit, :units)
const colorrange_sources = (:colorrange, :z_range, "z_range")
const title_sources = (:title, "CATDESC")

function prioritized_get(c, keys, default=nothing)
    values = get.(Ref(c), keys, nothing)
    all(isnothing, values) ? default : something(values...)
end

issymbol(x) = false
issymbol(x::Symbol) = true

function prioritized_get(c::NamedTuple, keys, default=nothing)
    for k in filter(issymbol, keys)
        hasproperty(c, k) && return getfield(c, k)
    end
    return default
end

function ulabel(l, u; multiline=false)
    multiline ? "$(l)\n($(u))" : "$(l) ($(u))"
end

_label(x) = SpaceDataModel.name(x)

format_unit(u::Unitful.Unitlike) = string(u)
format_unit(ta) = prioritized_get(meta(ta), (:unit, :units, "UNITS", "units"), "")
format_unit(ta::AbstractArray{Q}) where {Q<:Quantity} = string(unit(Q))

title(ta, default="") = prioritized_get(meta(ta), title_sources, default)
title(ds::AbstractDataSet) = title(ds, ds.name)

xvalues(ta) = times(ta)
xlabel(ta) = ""

yvalues(x) = parent(get(meta(x), "y", dims(x, 2)))
function yvalues(::Type{Vector}, x)
    vals = yvalues(x)
    if isa(vals, AbstractMatrix)
        all(allequal, eachcol(vals)) || @warn "y values are not constant along time"
        vec(mean(vals; dims=1))
    else
        vals
    end
end

ylabel(ta) = ""
ylabel(x::AbstractVector) = format_unit(x)
function ylabel(da::Union{AbstractDimArray,AbstractDataVariable}; multiline=true)
    default_name = isspectrogram(da) ? _label(dims(da, 2)) : _label(da)
    m = meta(da)
    name = prioritized_get(m, ylabel_sources, default_name)
    ustr = isspectrogram(da) ? prioritized_get(m, yunit_sources, "") : format_unit(da)
    ustr == "" ? name : ulabel(name, ustr; multiline)
end

function clabel(ta::AbstractDimArray; multiline=true)
    name = get(ta.metadata, "LABLAXIS", DD.label(ta))
    units = format_unit(ta)
    units == "" ? name : ulabel(name, units; multiline)
end

function calc_colorrange(da; scale=10)
    cmid = nanmedian(da)
    cmax = cmid * scale
    cmin = cmid / scale
    return (cmin, cmax)
end

colorrange(x) = prioritized_get(meta(x), colorrange_sources)

label(ta) = prioritized_get(meta(ta), (:long_name, "long_name", :label, "label", "LABLAXIS"), _label(ta))
labels(x) = Nothing[]


_vec(x) = [x]
_vec(x::AbstractVector) = x

function labels(ta::Union{AbstractDimArray,AbstractDataVariable})
    lbls = prioritized_get(meta(ta), labels_sources, string.(dims(ta, 2).val))
    _vec(lbls)
end

set_colorrange(x, range) = modify_meta(x; colorrange=range)
set_colorrange(x; kwargs...) = set_colorrange(x, calc_colorrange(x; kwargs...))

function isspectrogram(ta::AbstractDimArray; threshold=5)
    m = prioritized_get(meta(ta), ("DISPLAY_TYPE", :DISPLAY_TYPE), nothing)
    if isnothing(m)
        size(ta, 2) >= threshold
    else
        m == "spectrogram" || m == "spectral"
    end
end
isspectrogram(ta) = false

function scale(x::String)
    if x == "linear"
        identity
    elseif x == "log10" || x == "log"
        log10
    end
end

scale(::Any) = nothing
scale(f::Function) = f
function scale(x::AbstractArray; sources=scale_sources)
    m = meta(x)
    isnothing(m) ? nothing : scale(prioritized_get(m, sources, nothing))
end

function yscale(x)
    !isspectrogram(x) ? scale(x) : scale(x; sources=(:yscale,))
end

import SpaceDataModel: NoMetadata
import DimensionalData

uunit(x) = unit(x)
uunit(::String) = nothing
uunit(x::AbstractArray{Q}) where {Q <: Number} = unit(Q)

"""Format datetime ticks with time on top and date on bottom."""
format_datetime(dt) = Dates.format(dt, "HH:MM:SS\nyyyy-mm-dd")

label_func(labels) = latexify.(labels)

filterkeys(f, d::Dict) = filter(f ∘ first, d)
filterkeys(f, nt) = NamedTuple{filter(f, keys(nt))}(nt)
filter_by_fieldnames(T::Type, d::Dict) = filterkeys(∈(fieldnames(T)), d)

filterkeys(f, ::NoMetadata) = Dict()
filter_by_fieldnames(T::Type, ::NoMetadata) = Dict()
filter_by_fieldnames(T::Type, ::DimensionalData.NoMetadata) = Dict()


function set_axis_attributes!(attrs, x; add_title = false)
    set_if_valid!(attrs,
        :xlabel => xlabel(x),
        :yscale => yscale(x), :ylabel => ylabel(x)
    )
    add_title && (attrs[:title] = title(x))
    return attrs
end

function _axis_attributes(T, ta, args...; add_title = false, kwargs...)
    attrs = Dict()
    attrs[:yunit] = uunit(ta)
    set_axis_attributes!(attrs, ta; add_title)
    return merge!(attrs, kwargs)
end

function _axis_attributes(::Type{LinesPlot}, ta, args...; add_title = false, kwargs...)
    attrs = Dict()
    attrs[:yunit] = uunit(ta)
    set_axis_attributes!(attrs, ta; add_title)
    return merge!(attrs, kwargs)
end

function _axis_attributes(::Type{SpecPlot}, ta, args...; add_title = false, kwargs...)
    attrs = Dict()
    y_values = spectrogram_y_values(ta)
    attrs[:yunit] = uunit(y_values)
    set_axis_attributes!(attrs, ta; add_title)
    return merge!(attrs, kwargs)
end


function _axis_attributes(::Type{FunctionPlot}, f, args...; data = nothing, kw...)
    data = @something data apply(f, args...)
    return merge!(
        _axis_attributes(plottype(data), data; kw...),
        filter_by_fieldnames(Axis, meta(f)),
    )
end

function _axis_attributes(::Type{MultiPlot}, fs, args...; kw...)
    attr_dicts = _axis_attributes.(plottype.(values(fs)), values(fs), args...; kw...)
    return merge!(
        intersect_dicts(attr_dicts),
        filter_by_fieldnames(Axis, meta(fs)),
    )
end

# Process axis attributes before makie
function process_axis_attributes!(attrs)
    yunit = get(attrs, :yunit, nothing)
    if !isnothing(yunit) && yunit != Unitful.NoUnits
        attrs[:dim2_conversion] = Makie.UnitfulConversion(yunit; units_in_label = false)
        # Use unit as ylabel if no ylabel exists
        haskey(attrs, :ylabel) || (attrs[:ylabel] = format_unit(yunit))
    end
    delete!(attrs, :yunit)
    return attrs
end


function axis_attributes(fs, args...; kw...)
    return process_axis_attributes!(
        _axis_attributes(plottype(fs), fs, args...; kw...)
    )
end

function heatmap_attributes(ta; kwargs...)
    attrs = Attributes(; kwargs...)
    set_if_valid!(
        attrs,
        :colorscale => scale(ta), :colorrange => colorrange(ta)
    )
    return attrs
end

function plottype_attributes(meta; allowed = (:labels, :label))
    return filterkeys(∈(allowed), meta)
end

plot_attributes(ta; add_title = false) = Attributes(; axis = axis_attributes(ta; add_title))
plot_attributes(f::Function, args...; kwargs...) = plot_attributes(f(args...); kwargs...)

axes(ta) = meta(ta)["axes"]
