struct Fill
    x
end

Base.get(f::Fill, _, _) = f.x

_plottypes(x) = x
_plottypes(x::Type{<:AbstractPlot}) = Fill(x)

_dict(; kwargs...) = Dict(kwargs)

# This is much faster than `∈(fieldnames(T))` as `fieldnames(Axis)` is pretty slow due to nospecialization
# A not-erring version of `hasfield` when `x` is not a Symbol
_hasfield(T, x) = x isa Symbol && hasfield(T, x)
_hasfield(T) = x -> _hasfield(T, x)

# filter out invalid values (nothing, or empty string, or empty array)
_is_valid(x) = true
_is_valid(::Nothing) = false
_is_valid(x::AbstractString) = !isempty(x)
_is_valid(x::AbstractArray) = !isempty(x)

# like `get!`:  get!(f::Function, collection, key)
# modify the value if the key exists, otherwise return the collection
function modify!(f, collection, key)
    haskey(collection, key) && (collection[key] = f(collection[key]))
    return collection
end

@inline function set_if_valid!(d, pairs...)
    for (key, val) in pairs
        _is_valid(val) && setindex!(d, val, key)
    end
    return d
end

@inline function set_if_valid!(d; kwargs...)
    for (key, val) in kwargs
        _is_valid(val) && setindex!(d, val, key)
    end
    return d
end

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
x2t(x::Float64) = DateTime(Dates.UTM(round(Int64, x)))


_makie_t2x(x) = x
_makie_t2x(x::Dates.AbstractDateTime) = DateTime(x)
makie_t2x(x) = _makie_t2x.(x)
makie_x(x) = hastimedim(x) ? makie_t2x(times(x)) : 1:size(x, 1)

# Without a time dimension, the first axis is drawn as an index.
timedimnum(x) = something(tdimnum(x), 1)
otherdimnum(x) = timedimnum(x) == 1 ? 2 : 1

function donothing(args...; kwargs...) end

function logspan(x)
    min, max = nanextrema(x)
    return log10(max) - log10(min)
end
