_axis_attributes(x, args...) = _axis_attributes(plottype(x), x, args...)

# This is much faster than `∈(fieldnames(T))` as `fieldnames(Axis)` is pretty slow due to nospecialization
_has_field(T, x) = x isa Symbol && hasfield(T, x)
_hasfield(T) = x -> _has_field(T, x)

function merge_axis_attributes!(attrs, d)
    for (k, v) in pairs(d)
        _has_field(Axis, k) && setindex!(attrs, v, k)
    end
    return attrs
end

function _axis_attributes(::Type, A, args...)
    attrs = Dict{Symbol, Any}()
    flag = isspectrogram(A)
    set_if_valid!(
        attrs,
        :yunit => yunit(A; flag), :yscale => yscale(A; flag), :ylabel => ylabel(A; flag),
        :title => title(A),
    )
    return merge_axis_attributes!(attrs, meta(A))
end

function _axis_attributes(::Type{FunctionPlot}, f, args...; data = nothing)
    attrs = _axis_attributes(@something data apply(f, args...))
    return merge_axis_attributes!(attrs, meta(f))
end

function _axis_attributes(::Type{MultiPlot}, fs, args...)
    attrs = _intersect!(_axis_attributes.(values(fs), args...)...)
    return merge_axis_attributes!(attrs, meta(fs))
end

# Process axis attributes before makie
function process_axis_attributes!(attrs; add_title = false, kw...)
    u = get(attrs, :yunit, NoUnits)
    if u != NoUnits
        attrs[:dim2_conversion] = Makie.UnitfulConversion(u; units_in_label = false)
        # Use unit as ylabel if no ylabel exists
        haskey(attrs, :ylabel) || (attrs[:ylabel] = string(u))
    end
    add_title || delete!(attrs, :title)
    haskey(attrs, :yscale) && (attrs[:yscale] = _scale_func(attrs[:yscale]))
    return filter!(_hasfield(Axis) ∘ first, merge!(attrs, kw))
end

"""
Get axis attributes for `x`
"""
function axis_attributes(x, args...; kw...)
    return process_axis_attributes!(
        _axis_attributes(plottype(x), x, args...); kw...
    )
end
