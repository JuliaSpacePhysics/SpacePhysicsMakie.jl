# Metadata Schema Architecture
# This module defines a mapping-based approach for converting metadata
# from different data formats (ISTP, HAPI, Madrigal) to plot attributes.

"""
    MetadataSchema

Abstract type for defining how metadata keys map to plot attributes.
Each concrete schema defines the mapping rules for a specific metadata standard.
"""
abstract type MetadataSchema end

Base.keys(schema::MetadataSchema) = keys(metadata_keys(schema))
Base.get(schema::MetadataSchema, key, default) = get(metadata_keys(schema), key, default)
(s::MetadataSchema)(data) = SchemaLookup(s, data)
(s::MetadataSchema)(data, key) = SchemaLookup(s, data)[key]

"""
    get_schema(data)

Get the appropriate metadata schema for the data.
"""
get_schema(data) = _get_schema(meta(data))
_get_schema(::Any) = DefaultSchema()
function _get_schema(meta::AbstractDict)
    haskey(meta, "CATDESC") && return ISTPSchema()
    haskey(meta, "hapi_version") && return HAPISchema()
    haskey(meta, "plot_options") && return PySPEDASSchema()
    return DefaultSchema()
end

# Helper struct for lookup without materializing a dictionary
struct SchemaLookup{S, D}
    schema::S
    data::D
end


@inline Base.getindex(sl::SchemaLookup, key) = get(sl, key)
@inline function Base.get(sl::SchemaLookup, key, default = nothing)
    lookup = get(sl.schema, key, nothing)
    return isnothing(lookup) ? default :
        @something(resolve_metadata(sl.data, lookup), Some(default))
end

Base.keys(sl::SchemaLookup) = keys(sl.schema)

struct DefaultSchema <: MetadataSchema end
Base.get(::DefaultSchema, key, _) = get(_DEFAULT_MAPPING, key, key)

const _DEFAULT_MAPPING = (
    name = "name" => SpaceDataModel.name,
    unit = "unit",
)

include("istp.jl")
include("hapi.jl")
include("pyspedas.jl")
include("madrigal.jl")

function validate_schema(schema)
    return @assert (:name, :unit) ⊆ keys(schema)
end


"""
    resolve_metadata(data, lookup)

Resolve metadata value from `data` using a `lookup` pattern.

# Lookup Patterns
- `"key"` or `:key`: Direct lookup
- `("key1", "key2", ...)`: Priority lookup (first found)
- `accessor => sublookup`: Apply accessor function, then resolve sublookup
- `lookup => default_value`: Use default if lookup returns nothing
- `lookup => f::Function`: Compute default from `f(data)` if needed

# Examples
```julia
resolve_metadata(data, "UNITS")                    # Direct
resolve_metadata(data, ("UNITS", "units"))             # Priority
resolve_metadata(data, depend_1 => "UNITS")       # Accessor
resolve_metadata(data, "UNITS" => "dimensionless") # Default value
resolve_metadata(data, depend_1 => ("UNITS" => "")) # Chained
```
"""
# 1. Base case: String or Symbol -> Direct lookup
resolve_metadata(data, lookup::Union{String, Symbol}) = mget(data, lookup)
# 2. Tuple case: Priority lookup pattern ("Key1", "Key2", ...)
function resolve_metadata(data, lookup::Tuple)
    for key in lookup
        val = resolve_metadata(data, key)
        isnothing(val) || return val
    end
    return nothing
end
resolve_metadata(data, lookup::Function) = lookup(data)

# 3. Pair case with `=>`: Can be (Accessor => sublookup) or (Definition => DefaultValue/DefaultFunction)
function resolve_metadata(data, lookup::Pair)
    # Check for Accessor pattern: Accessor => sublookup
    return if lookup.first isa Function
        accessor = lookup.first
        target_data = accessor(data)
        # Recursive call with sublookup definition
        resolve_metadata(target_data, lookup.second)
    else
        # Definition => DefaultValue/DefaultFunction pattern
        val = resolve_metadata(data, lookup.first)
        isnothing(val) ? _second(lookup.second, data) : val
    end
end

_second(x, _) = x
_second(f::Function, data) = f(data)
