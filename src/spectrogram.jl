const COLORRANGE_SOURCES = (:colorrange, :z_range, "z_range")

isspectrogram(A) = false

function isspectrogram(A::AbstractMatrix; threshold = 5)
    m = prioritized_get(meta(A), ("DISPLAY_TYPE",))
    return if isnothing(m)
        size(A, 2) >= threshold
    else
        m == "spectrogram" || m == "spectral"
    end
end

function clabel(A; multiline = true)
    name = get(meta(A), "LABLAXIS", DD.label(A))
    units = unit_str(A)
    return units == "" ? name : ulabel(name, units; multiline)
end

colorrange(x) = prioritized_get(meta(x), COLORRANGE_SOURCES)

function heatmap_attributes(A; kwargs...)
    attrs = Attributes(; kwargs...)
    set_if_valid!(
        attrs,
        :colorscale => scale(A, (:scale, "SCALETYP")), :colorrange => colorrange(A)
    )
    return attrs
end

set_colorrange(x, range) = modify_meta(x; colorrange = range)
