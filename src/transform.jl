"""
    transform(args...; kwargs...)

Transform data into plottable format (e.g., `DimArray`).

Extend with `transform(x::MyType)` for custom types.
"""
transform(x, args...) = x

plottable(x, args...; transform = transform) = _normalize(transform(x, args...))

# A time series that `SpaceDataModel.sanitize` masks or reads from storage becomes a `Materialized`
# copy, coordinates included, so recipes never go back to the disk.
function _normalize(x)
    hastimedim(x) || return x
    A = SDM.sanitize(x)
    A === x && return x
    dims = ntuple(i -> SDM.dim(x, i), ndims(x))
    return Materialized(parent(A), dims, tdimnum(x), getmeta(x), SDM.name(x), get_schema(x))
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
