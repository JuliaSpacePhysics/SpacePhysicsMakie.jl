import DimensionalData
import DimensionalData as DD
using DimensionalData: AbstractDimArray, AbstractDimStack, TimeDim, Dimension, basetypeof, hasdim, dimnum, dims, Dim

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


# A no-error version of `dimnum`
_dimnum(x, dim) = hasdim(x, dim) ? dimnum(x, dim) : nothing
function timedimnum(A::AbstractDimArray) 
    return @something _dimnum(A, TimeDim) _dimnum(A, Dim{:time}) (@info "Could not find time dimension, assuming 1"; 1)
end
