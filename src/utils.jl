struct Fill
    x
end

Base.get(f::Fill, _, _) = f.x

_plottypes(x) = x
_plottypes(x::Type{<:AbstractPlot}) = Fill(x)

_dict(; kwargs...) = Dict(kwargs)


"""
    resample(arr, n=DEFAULTS.resample; dim=1, verbose=false)

Resample an array along the dimension `dim` to `n` points.
If the original length is less than or equal to `n`, the original array is returned unchanged.
"""
function resample(arr; n = DEFAULTS.resample, dim = 1, verbose = false)
    sz = size(arr, dim)
    return if sz > n
        # verbose && @info "Resampling array of size $(size(arr)) along dimension $dim from $sz to $n points"
        verbose && @info "Resampling $(summary(arr)) along dimension $dim from $sz to $n points"
        indices = round.(Int, range(1, sz, length = n))
        selectdim(arr, dim, indices)
    else
        arr
    end
end

# like get, but handles NamedTuple
_get(x, key, default) = get(x, key, default)
_get(::NamedTuple, ::String, default) = default

mget(x, key, default = nothing) = _get(meta(x), key, default)
mget(x, keys::Tuple, default = nothing) = prioritized_get(meta(x), keys, default)

"""
    prioritized_get(container, keys, default=nothing)

Extract a value from a `container` using a prioritized list of `keys`.
Returns the first non-nothing value found, or `default` if none found.
"""
function prioritized_get(c, keys, default = nothing)
    for k in keys
        v = _get(c, k, nothing)
        !isnothing(v) && return v
    end
    return default
end

function prioritized_get(nt::NamedTuple, keys, default = nothing)
    for k in keys
        k_sym = Symbol(k)
        hasproperty(nt, k_sym) && return getfield(nt, k_sym)
    end
    return default
end

# filter out invalid values (nothing, or empty string, or empty array)
_is_valid(x) = true
_is_valid(::Nothing) = false
_is_valid(x::AbstractString) = !isempty(x)
_is_valid(x::AbstractArray) = !isempty(x)
function _set_if_valid!(d, val, key)
    _is_valid(val) && setindex!(d, val, key)
    return d
end
function set_if_valid!(d, pairs::Pair...)
    for (key, value) in pairs
        _set_if_valid!(d, value, key)
    end
    return d
end

function _intersect(nt::NamedTuple, itr...)
    ntkeys = filter(keys(nt)) do key
        res = true
        val = getfield(nt, key)
        for i in itr
            if (!hasproperty(i, key)) || (getfield(i, key) != val)
                res = false
            end
        end
        res
    end
    return NamedTuple{ntkeys}(nt)
end

"""
    _intersect(d, itr...)

Find common key-value pairs across multiple dictionaries `dicts`.
Only includes pairs where the key exists in all dictionaries with the same value.
"""
_intersect(d::AbstractDict, itr...) = _intersect!(copy(d), itr...)

function _intersect!(d, itr...)
    for i in itr
        for (key, value) in pairs(d)
            if !haskey(i, key) || i[key] != value
                delete!(d, key)
            end
        end
    end
    return d
end


_merge(x, args...) = merge(x, args...)
_merge(x::Dict, y::NamedTuple) = merge(x, Dict(pairs(y)))

"""
Convert x to DateTime

Reference:
- https://docs.makie.org/dev/explanations/dim-converts#Makie.DateTimeConversion
- https://github.com/MakieOrg/Makie.jl/issues/442
- https://github.com/MakieOrg/Makie.jl/blob/master/src/dim-converts/dates-integration.jl
"""
x2t(x::Millisecond) = DateTime(Dates.UTM(x))
x2t(x::Float64) = DateTime(Dates.UTM(round(Int64, x)))


"""
    spectrogram_y_values(ta; check=false, center=false, transform=identity)

Get y-axis values from a spectrogram array.
Can return either bin centers or edges. By default, return bin edges for better compatibility.

# Arguments
- `check`: If true, check if values are constant along time
- `center`: If true, return bin centers instead of edges
- `transform`: Optional transform function for edge calculation (e.g., log for logarithmic bins)

Reference: Makie.edges
"""
function spectrogram_y_values(ta; check = false, center = true, transform = yscale(ta))
    transform = _scale_func(transform)
    centers = yvalues(Vector, ta)
    if center && transform == log10
        edges = binedges(centers)
        if first(edges) < zero(eltype(edges)) || last(edges) < zero(eltype(edges))
            @warn "Automatically using edge for Makie because transform == $transform and the first edge is negative"
            center = false
        end
    end

    return !center ? binedges(centers; transform) : centers
end

_makie_t2x(x) = x
_makie_t2x(x::Dates.AbstractDateTime) = DateTime(x)
makie_t2x(x) = _makie_t2x.(x)
makie_x(x) = 1:size(x, 1)

function donothing(args...; kwargs...) end
