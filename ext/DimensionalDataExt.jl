import DimensionalData
import DimensionalData as DD
using DimensionalData: AbstractDimArray, AbstractDimVector, AbstractDimStack, TimeDim, Dimension, lookup, basetypeof

dims(x::AbstractDimArray, d) = DD.dims(x, d)
unwrap(x::Dimension) = parent(lookup(x))
times(x::AbstractDimArray, args...) = unwrap(timedim(x, args...))

dimtype_eltype(d) = (basetypeof(d), eltype(d))
dimtype_eltype(A, query) = dimtype_eltype(dims(A, something(query, TimeDim)))

function timedim(x, query=nothing)
    query = something(query, TimeDim)
    qdim = dims(x, query)
    isnothing(qdim) ? dims(x, 1) : qdim
end

function tview(da::AbstractDimArray, t0, t1; query=nothing)
    Dim, T = dimtype_eltype(da, query)
    return @view da[Dim(T(t0) .. T(t1))]
end

apply(A::AbstractDimStack, tmin, tmax) = tview(A, tmin, tmax)

_label(x::AbstractDimArray) = DD.label(x)
filter_by_fieldnames(::Type, ::DimensionalData.NoMetadata) = Dict()

plottype(x::AbstractDimArray) = isspectrogram(x) ? SpecPlot : LinesPlot

makie_x(da::AbstractDimArray) = makie_t2x(times(da))

"""Plot attributes for a time array (labels)"""
function plottype_attributes(ta::AbstractArray)
    attrs = Attributes()
    # handle spectrogram
    if !isspectrogram(ta)
        if ndims(ta) == 2
            attrs[:labels] = labels(ta)
        else
            attrs[:label] = label(ta)
        end
    else
        merge!(attrs, heatmap_attributes(ta))
    end
    return attrs
end

"""Plot attributes for a time array (axis + labels)"""
function plot_attributes(ta::AbstractDimArray; add_title = false, axis = (;))
    attrs = plottype_attributes(ta)
    attrs[:axis] = axis_attributes(ta; add_title, axis...)
    return attrs
end

plot2spec(ds::AbstractDimStack; kwargs...) =
    map(values(ds)) do ds
    plot2spec(ds; kwargs...)
end |> collect

Makie.convert_arguments(t::Type{<:LinesPlot}, da::AbstractDimVector{<:AbstractVector}) = convert_arguments(t, tstack(da))
