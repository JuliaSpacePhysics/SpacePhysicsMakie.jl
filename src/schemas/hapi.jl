"""
    HAPISchema <: MetadataSchema

Schema for HAPI (Heliophysics Application Programmer's Interface) metadata.

# References
- [HAPI Data Access Specification](https://github.com/hapi-server/data-specification)
"""
struct HAPISchema <: MetadataSchema end

metadata_keys(::HAPISchema) = (
    desc = "description",
    name = "name",
    unit = "units",
    labels = "label",
    coord = "coordinateSystemName",
)
