"""
    MadrigalSchema <: MetadataSchema

Schema for Madrigal database metadata.
"""
struct MadrigalSchema <: MetadataSchema end


metadata_keys(::MadrigalSchema) = (
    desc = "description",
    name = "name",
    unit = "units",
    labels = "label",
)
