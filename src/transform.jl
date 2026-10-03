"""
    transform(args...; kwargs...)

Transform data into plottable format (e.g., `DimArray`).

Extend with `transform(x::MyType)` for custom types.
"""
transform(x, args...) = x

plottable(x, args...; transform = transform) = _normalize(transform(x, args...))

# A time series is read once into a `Materialized`, coordinates included, so recipes never go back to
# storage. Storage types decode on read; nothing is masked here.
function _normalize(x)
    hastimedim(x) || return x
    return Materialized(_inmemory(x), SDM.dims(x), tdimnum(x), getmeta(x), SDM.name(x), get_schema(x))
end

# A time series' parent is its values (DimArray, AbstractDataVariable); shared when already in memory.
function _inmemory(x)
    p = parent(x)
    return p isa Array && size(p) == size(x) ? p : Array(x)
end

struct Materialized{T, N, A <: AbstractArray{T, N}, D <: Tuple, M, Nm, S} <: AbstractDataVariable{T, N}
    data::A
    dims::D
    tdim::Int
    metadata::M
    name::Nm
    schema::S
end

_normalize(x::Materialized) = x
SDM.tdimnum(x::Materialized) = x.tdim
SDM.get_schema(x::Materialized) = x.schema
