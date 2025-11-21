isspectrogram(A) = false

"""
    isspectrogram(A::AbstractMatrix; threshold=5, schema=get_schema(A))

Determine if data should be plotted as a spectrogram using the metadata schema.
"""
function isspectrogram(A::AbstractMatrix; threshold = 5, schema = get_schema(A))
    m = schema(A)[:display_type]
    return if isnothing(m)
        size(A, 2) >= threshold
    else
        m == "spectrogram" || m == "spectral"
    end
end

"""
    clabel(A; multiline=true, schema=get_schema(A))

Get the colorbar label for `data` using the metadata schema.
"""
function clabel(A; multiline = true, schema = get_schema(A))
    sl = schema(A)
    name = get(sl, :name, "")
    units = get(sl, :unit, "")
    return ulabel(name, units; multiline)
end

"""
    heatmap_attributes(A; kwargs...)

Extract heatmap attributes from metadata using the schema-based approach.
"""
function heatmap_attributes(A; schema = get_schema(A), kwargs...)
    attrs = Dict{Symbol, Any}(kwargs)
    sl = schema(A)
    set_if_valid!(attrs; colorscale = sl[:scale])
    modify!(_scale_func, attrs, :colorscale)
    heatmap_keys = Makie.attribute_names(Heatmap)
    for (k, v) in pairs(meta(A))
        if k in heatmap_keys
            attrs[k] = v
        end
    end
    return attrs
end

safe_div(x, y) = x / y
safe_div(x::Union{Integer, Dates.TimePeriod}, y) = div(x, y)

"""
    _linear_binedges(centers)

Calculate bin edges assuming linear spacing.
"""
function _linear_binedges(centers)
    N = length(centers)
    edges = similar(centers, N + 1)
    # Calculate internal edges
    for i in 2:N
        edges[i] = centers[i - 1] + safe_div(centers[i] - centers[i - 1], 2)
    end

    # Calculate first and last edges using the same spacing as adjacent bins
    edges[1] = centers[1] - (edges[2] - centers[1])
    edges[end] = centers[end] + (centers[end] - edges[end - 1])

    return edges
end

"""
    binedges(centers; transform=identity)

Calculate bin edges from bin centers. 
- For linear spacing, edges are placed halfway between centers.
- For transformed spacing, edges are placed halfway between transformed centers.

# Arguments
- `transform`: Function to transform the space (e.g., log for logarithmic spacing)

# Example
```julia
centers = [1.0, 2.0, 3.0]
edges = binedges(centers)               # Returns [0.5, 1.5, 2.5, 3.5]
edges = binedges(centers, transform=log)  # Returns edges in log space
```
"""
function binedges(centers; transform = identity)
    N = length(centers)
    N < 2 && throw(ArgumentError("Need at least 2 bin centers to calculate edges"))
    if transform === identity
        return _linear_binedges(centers)
    else
        # Work in transformed space
        transformed = transform.(centers)
        transformed_edges = _linear_binedges(transformed)
        return inverse(transform).(transformed_edges)
    end
end

function binedges(centers::AbstractVector{Q}; kwargs...) where {Q <: Quantity}
    return binedges(ustrip(centers); kwargs...) * Unitful.unit(Q)
end
