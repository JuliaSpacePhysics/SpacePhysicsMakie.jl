import DimensionalData
import DimensionalData as DD
using DimensionalData: AbstractDimArray, AbstractDimVector, AbstractDimMatrix, AbstractDimStack, TimeDim, Dimension, lookup, basetypeof, dimnum, dims

dimtype_eltype(d) = (basetypeof(d), eltype(d))
dimtype_eltype(A, query) = dimtype_eltype(dims(A, something(query, TimeDim)))

tview(x, t0, t1) = x
function tview(da::AbstractDimArray, t0, t1; query = nothing)
    Dim, T = dimtype_eltype(da, query)
    return @view da[Dim(T(t0) .. T(t1))]
end

apply(A::AbstractDimStack, tmin, tmax) = tview(A, tmin, tmax)

plottype(x::AbstractDimArray) = isspectrogram(x) ? SpecPlot : LinesPlot

makie_x(da::AbstractDimArray) = makie_t2x(times(da))

plot2spec(ds::AbstractDimStack; kwargs...) =
    map(values(ds)) do ds
    plot2spec(ds; kwargs...)
end |> collect

timedimnum(A::AbstractDimArray) = @something dimnum(A, TimeDim) 1

# Makie.convert_arguments(t::Type{<:LinesPlot}, da::AbstractDimVector{<:AbstractVector}) = convert_arguments(t, tstack(da))
