"""
Schema for PySPEDAS Tplot Variable metadata.
"""
struct PySPEDASSchema <: MetadataSchema end

cdf(x) = get(meta(x), "CDF", NoMetadata())
vatt(x) = get(cdf(x), "VATT", NoMetadata())

function metadata_keys(::PySPEDASSchema)
    return (
        desc = vatt => "CATDESC",
        name = (vatt => "LABLAXIS", SpaceDataModel.name),
        long_name = vatt => "FIELDNAM",
        unit = vatt => "UNITS",
        scale = vatt => "SCALETYP",
        labels = cdf => "LABELS",
        display_type = vatt => "DISPLAY_TYPE",
        depend_1_name = depend_1 => ("LABLAXIS", "FIELDNAM"),
        depend_1_unit = depend_1 => "UNITS",
        depend_1_scale = depend_1 => "SCALETYP",
    )
end
