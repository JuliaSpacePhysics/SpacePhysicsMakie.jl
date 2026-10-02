function merge_axis_attributes!(attrs, d)
    ks = filter(_hasfield(Axis), keys(d)) # filter first instead of iterating all keys to avoid reading the values unnecessarily
    for k in ks
        attrs[k] = d[k]
    end
    return attrs
end

_axis_attributes(x, args...; kw...) = _axis_attributes(plottype(x), x, args...; kw...)

function _axis_attributes(::Type, A, args...; add_title = false, schema = get_schema(A), multiline = true)
    axis = Dict{Symbol, Any}()
    attrs = schema(A)
    add_title && set_if_valid!(axis; title = attrs[:desc])
    if isspectrogram(A)
        ylabel = ulabel(attrs[:depend_1_name], attrs[:depend_1_unit]; multiline)
        yscale = attrs[:depend_1_scale]
    else
        unit = _unit(A)
        ylabel = ulabel(attrs[:name], unit; multiline)
        yscale = attrs[:scale]
        set_if_valid!(axis; _yunit = unit)
    end
    set_if_valid!(axis; yscale, ylabel)
    return merge_axis_attributes!(axis, getmeta(A))
end

function _axis_attributes(::Type{FunctionPlot}, f, args...; kw...)
    return _source_axis_attributes(f, plottable(getdata(f, args...)); kw...)
end
_source_axis_attributes(f, data; kw...) = merge_axis_attributes!(_axis_attributes(data; kw...), getmeta(f))

function _axis_attributes(::Type{MultiPlot}, fs, args...; kw...)
    attrs = _intersect!(_axis_attributes.(values(fs), args...; kw...)...)
    return merge_axis_attributes!(attrs, getmeta(fs))
end

# Process axis attributes before makie
function process_axis_attributes!(attrs)
    u = get(attrs, :_yunit, nothing)
    u isa Unitful.FreeUnits && begin
        attrs[:dim2_conversion] = Makie.UnitfulConversion(u; units_in_label = false)
    end
    haskey(attrs, :ylabel) || (attrs[:ylabel] = _string(u)) # Use unit as ylabel if no ylabel exists
    modify!(_scale_func, attrs, :yscale)
    return filter!(_hasfield(Axis) ∘ first, attrs)
end

"""
Get axis attributes for `x`
"""
axis_attributes(x, args...; kw...) = process_axis_attributes!(_axis_attributes(x, args...; kw...))
