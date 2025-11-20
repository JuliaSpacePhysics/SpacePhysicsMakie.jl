const COLORRANGE_SOURCES = (:colorrange, :z_range, "z_range")

isspectrogram(A) = false

function isspectrogram(A::AbstractMatrix; threshold = 5)
    m = mget(A, "DISPLAY_TYPE")
    return if isnothing(m)
        size(A, 2) >= threshold
    else
        m == "spectrogram" || m == "spectral"
    end
end

function clabel(A; multiline = true)
    name = mget(A, "LABLAXIS", SpaceDataModel.name(A))
    units = unit_str(A)
    return ulabel(name, units; multiline)
end

colorrange(x) = prioritized_get(meta(x), COLORRANGE_SOURCES)

function heatmap_attributes(A; kwargs...)
    attrs = Attributes(; kwargs...)
    set_if_valid!(
        attrs,
        :colorscale => _scale_func(mget(A, "SCALETYP")),
        :colorrange => colorrange(A)
    )
    heatmap_keys = Makie.attribute_names(Heatmap)
    for (k, v) in meta(A)
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
    return binedges(ustrip(centers); kwargs...) * unit(Q)
end
