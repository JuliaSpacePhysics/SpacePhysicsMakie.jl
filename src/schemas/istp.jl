"""
    ISTPSchema <: MetadataSchema

Schema for ISTP-compliant metadata.

# References
- [ISTP Global Attributes](https://spdf.gsfc.nasa.gov/istp_guide/gattributes.html)
- [ISTP Variables](https://spdf.gsfc.nasa.gov/istp_guide/variables.html)
"""
@kwdef struct ISTPSchema <: MetadataSchema
    default_name = SpaceDataModel.name
end

const _ISTP_SCHEMA = (
    desc = "CATDESC",
    name = "LABLAXIS" => SpaceDataModel.name,
    long_name = "FIELDNAM",
    unit = "UNITS",
    scale = "SCALETYP",
    labels = "LABL_PTR_1",
    display_type = "DISPLAY_TYPE",
    depend_1_name = depend_1 => ("LABLAXIS", "FIELDNAM"),
    depend_1_unit = depend_1 => "UNITS",
    depend_1_scale = depend_1 => "SCALETYP",
)

"""
Metadata key mappings for ISTP schema.
Returns a NamedTuple with keys corresponding to plot attributes.
"""
function metadata_keys(schema::ISTPSchema)
    return _ISTP_SCHEMA
end
