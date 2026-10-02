"""
    transform(args...; kwargs...)

Transform data into plottable format (e.g., `DimArray`).

Extend with `transform(x::MyType)` for custom types.
"""
transform(x, args...) = x

# Recipes query a time series repeatedly (values, `times`, `depend_1`), so one in storage is
# read into memory once per fetch; in-memory values are shared, not copied.
plottable(x, args...; transform = transform) = materialize(transform(x, args...))

function materialize(x)
    hastimedim(x) || return x
    t = tdimnum(x)
    # `times` unwraps the time dimension, reading one in storage into memory.
    dims = Base.setindex(SDM.dims(x), times(x), t)
    return Materialized(_inmemory(x), dims, t, getmeta(x), SDM.name(x), get_schema(x))
end

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

materialize(x::Materialized) = x
SDM.tdimnum(x::Materialized) = x.tdim
SDM.get_schema(x::Materialized) = x.schema
