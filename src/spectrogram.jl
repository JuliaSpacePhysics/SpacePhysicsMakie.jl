isspectrogram(A) = false

# Determine if data should be plotted as a spectrogram using the metadata schema.
function isspectrogram(A::AbstractMatrix; threshold = 8, schema = get_schema(A))
    m = schema(A)[:display_type]
    return if isnothing(m)
        size(A, otherdimnum(A)) >= threshold
    else
        occursin("spect", m)
    end
end


# colorbar label
function clabel(A; multiline = true, schema = get_schema(A))
    sl = schema(A)
    name = sl[:name]
    units = sl[:unit]
    return ulabel(name, units; multiline)
end

function heatmap_attributes(A; schema = get_schema(A), kwargs...)
    attrs = Dict{Symbol, Any}(kwargs)
    sl = schema(A)
    set_if_valid!(attrs; colorscale = sl[:scale])
    modify!(_scale_func, attrs, :colorscale)
    heatmap_keys = Makie.attribute_names(Heatmap)
    for (k, v) in pairs(getmeta(A))
        if k in heatmap_keys
            attrs[k] = v
        end
    end
    return attrs
end

# Sample `i` covers half its local cadence (its smaller spacing to a neighbour) on each side, so cells
# never overlap where the cadence changes. Neighbours closer than `gap` times their mean cadence share an
# edge, split in proportion to their cadences; wider spacings stay empty. A sample cut off on both sides
# has only gaps for spacings, so it takes its neighbours' cadence instead.
function sample_cells(x::AbstractVector{<:Real}; gap = 1.5)
    n = length(x)
    n < 2 && return float.(x), float.(x)
    d = diff(x)
    c₀ = [min(d[max(i - 1, 1)], d[min(i, n - 1)]) for i in 1:n]
    touches(c, i) = (w = c[i] + c[i + 1]; w > 0 && d[i] <= gap * w / 2)
    cut(i) = (i == 1 || !touches(c₀, i - 1)) && (i == n || !touches(c₀, i))
    c = [cut(i) ? min(c₀[max(i - 1, 1)], c₀[min(i + 1, n)]) : c₀[i] for i in 1:n]
    lo = x .- c ./ 2
    hi = x .+ c ./ 2
    for i in 1:(n - 1)
        touches(c, i) && (hi[i] = lo[i + 1] = x[i] + d[i] * c[i] / (c[i] + c[i + 1]))
    end
    return lo, hi
end

# Merge runs of touching cells while a run ends before `stop(lo)`; each merged value is `bin` of the
# members' non-NaN values. `Y` is a vector of channel edges, or one row of edges per cell.
function merge_cells(lo, hi, M, Y, stop, bin)
    groups = UnitRange{Int}[]
    i = 1
    while i <= length(lo)
        j = i
        s = stop(lo[i])
        while j < length(lo) && lo[j + 1] == hi[j] && hi[j + 1] <= s
            j += 1
        end
        push!(groups, i:j)
        i = j + 1
    end
    length(groups) == length(lo) && return lo, hi, M, Y
    T = float(eltype(M))
    M′ = similar(M, T, length(groups), size(M, 2))
    buf = Vector{T}(undef, maximum(length, groups))
    for (gi, g) in enumerate(groups), k in axes(M, 2)
        nv = 0
        for r in g
            v = M[r, k]
            isnan(v) || (buf[nv += 1] = v)
        end
        M′[gi, k] = nv == 0 ? T(NaN) : bin(view(buf, 1:nv))
    end
    Y′ = Y isa AbstractVector ? Y : [mean(view(Y, g, k)) for g in groups, k in axes(Y, 2)]
    return lo[first.(groups)], hi[last.(groups)], M′, Y′
end

# `heatmap` cannot take a DateTime x (Makie#5193) or per-sample channels, so cells are a `surface` where
# every cell owns its 4 vertices: one flat color on every backend (CairoMakie ignores `interpolate = false`).
# A gap between cells becomes a NaN cell.
function cell_grid(lo, hi, M, Y)
    cols = Int[]
    xs = eltype(lo)[]
    for i in eachindex(lo)
        if i > 1 && lo[i] > hi[i - 1]
            push!(cols, 0)
            push!(xs, hi[i - 1], lo[i])
        end
        push!(cols, i)
        push!(xs, lo[i], hi[i])
    end
    m = size(M, 2)
    C = Matrix{float(eltype(M))}(undef, length(xs), 2m)
    yy = Matrix{eltype(Y)}(undef, length(xs), 2m)
    for (j, i) in enumerate(cols), r in (2j - 1, 2j)
        e = Y isa AbstractVector ? Y : view(Y, i == 0 ? cols[j - 1] : i, :)
        for k in 1:m
            C[r, 2k - 1] = C[r, 2k] = i == 0 ? NaN : M[i, k]
            yy[r, 2k - 1] = e[k]
            yy[r, 2k] = e[k + 1]
        end
    end
    return repeat(xs, 1, 2m), yy, C
end

# Inside the view a run may span one pixel; outside it, one pixel of the whole range, and never into the
# view. This bounds the cell count (GLMakie draws nothing past ~32k columns) and keeps the data extent.
function pixel_stop(lo, hi, limits, viewport)
    px = max(viewport.widths[1], 1)
    x0 = limits.origin[1]
    x1 = x0 + limits.widths[1]
    near = (x1 - x0) / px
    far = max((hi[end] - lo[1]) / px, near)
    return x -> x0 <= x <= x1 ? x + near : x < x0 ? min(x + far, x0) : x + far
end

# Channel edges sit halfway between centers in the y scale's space (geometric midpoints on log10); the outer
# edges mirror their neighbours. A matrix holds one row of centers per sample.
_edge_transform(scale) = scale in (log10, log, log2) ? scale : identity
channel_edges(y, scale) = _channel_edges(y, _edge_transform(scale))
channel_edges(y::AbstractArray{<:Quantity}, scale) = channel_edges(ustrip(y), scale) * Unitful.unit(eltype(y))

_channel_edges(y::AbstractVector, f::F) where {F} = _edges!(similar(y, float(eltype(y)), length(y) + 1), y, f)
function _channel_edges(y::AbstractMatrix, f::F) where {F}
    e = similar(y, float(eltype(y)), size(y, 1), size(y, 2) + 1)
    for i in axes(y, 1)
        _edges!(view(e, i, :), view(y, i, :), f)
    end
    return e
end

function _edges!(e, c, f)
    N = length(c)
    N < 2 && throw(ArgumentError("need at least 2 channels to place cell edges, got $N"))
    g = inverse(f)
    for i in 2:N
        e[i] = g((f(c[i - 1]) + f(c[i])) / 2)
    end
    e[1] = g((3f(c[1]) - f(c[2])) / 2)
    e[N + 1] = g((3f(c[N]) - f(c[N - 1])) / 2)
    return e
end

_num(x::Real) = x
_num(x::DateTime) = Float64(Dates.value(x))
_fromnum(::Type{<:Real}, v) = v
_fromnum(::Type{DateTime}, v) = DateTime(Dates.UTM(round(Int64, v)))
