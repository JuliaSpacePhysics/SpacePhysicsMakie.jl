_axis_meta(x::AbstractDict) = filter_by_fieldnames(Axis, x)
_axis_meta(x::NamedTuple) = Dict(pairs(filter_by_fieldnames(Axis, x)))
_axis_meta(::NoMetadata) = Dict{Symbol, Any}()
_axis_meta(x) = _axis_meta(meta(x))

_axis_attributes(x, args...) = _axis_attributes(plottype(x), x, args...)

function _axis_attributes(::Type, A, args...)
    attrs = Dict{Symbol, Any}()
    flag = isspectrogram(A)
    set_if_valid!(
        attrs,
        :yunit => yunit(A; flag), :yscale => yscale(A; flag), :ylabel => ylabel(A; flag),
        :title => title(A),
    )
    return merge!(attrs, _axis_meta(A))
end

function _axis_attributes(::Type{FunctionPlot}, f, args...; data = nothing)
    attrs = _axis_attributes(@something data apply(f, args...))
    return merge!(attrs, _axis_meta(f))
end

function _axis_attributes(::Type{MultiPlot}, fs, args...)
    attrs = _intersect!(_axis_attributes.(values(fs), args...)...)
    return merge!(attrs, _axis_meta(fs))
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
    return filter_by_fieldnames!(Axis, merge!(attrs, kw))
end

"""
Get axis attributes for `x`
"""
function axis_attributes(x, args...; kw...)
    return process_axis_attributes!(
        _axis_attributes(plottype(x), x, args...); kw...
    )
end
