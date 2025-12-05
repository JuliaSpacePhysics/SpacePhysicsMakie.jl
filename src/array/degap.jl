using Statistics: median
using DimensionalData
using Dates: AbstractTime

*ₜ(x, n) = x * n
*ₜ(x::AbstractTime, n) = Nanosecond(round(Int64, Dates.tons(x) * n))

_median(x) = median(x)

function _median(x::AbstractArray{T}) where {T <: Union{Date, DateTime, Period}}
    return T(round(Int, median(reinterpret(Int, x))))
end

"""
    degap(times; dt=nothing, margin=nothing, margin_ratio=0.1, ngap=nothing)

Fill gaps in `times` by inserting missing time stamps where time gaps exceed the cadence.

# Arguments
- `times`: Vector of time stamps (sorted)
- `dt`: Time cadence/resolution. Defaults to median time difference
- `margin`: Tolerance margin - gaps must be > `dt + margin` to trigger insertion

# Returns
Sorted vector of time stamps with NaN insertion points added for gaps
"""
function degap(times; dt = nothing, margin = nothing, margin_ratio = 0.1, ngap = nothing)
    dts = diff(times)
    dt = @something dt _median(dts)
    margin = @something margin dt *ₜ margin_ratio
    dt_allowed = +(promote(dt, margin)...) # Promote to avoid composite type
    idxs = findall(g -> g > dt_allowed, dts)
    @assert ngap in (1, 2, nothing)
    if isnothing(ngap)
        new_times = mapreduce(vcat, idxs; init = times) do i
            range(times[i] + dt, times[i + 1] - dt, step = dt)
        end
    elseif ngap == 1
        new_times = vcat(times, map(i -> times[i] + dt, idxs))
    else
        new_times = vcat(times, map(i -> times[i] + dt, idxs), map(i -> times[i + 1] - dt, idxs))
    end
    return sort!(unique!(new_times))
end


"""
    degap(A::AbstractDimArray; dt=cadence(A), margin_ratio=0.1, kw...)

Fill gaps in time series data `A` with NaN.

Additional keyword arguments passed to `reindex` include `method`, `fill_value`

# Arguments
- `dt`: Cadence (time step) for the regular grid. Default uses `cadence(A)` from SpaceDataModel
- `margin_ratio`: Tolerance ratio for matching existing points (default 0.1 = 10% of dt)

# Examples
```julia
using DimensionalData, Dates

# Create data with gaps
times = [DateTime(2020,1,1), DateTime(2020,1,2), DateTime(2020,1,5)]  # gap on days 3-4
da = DimArray([1.0, 2.0, 3.0], Ti(times))

# Fill gaps with NaN at daily cadence
degapped = degap(da; dt=Day(1))  # Creates entries for all days, fills gaps with NaN
```

See also: [`reindex`](@ref), [degap - pyspedas](https://pyspedas.readthedocs.io/en/latest/_modules/pytplot/tplot_math/degap.html)
"""
function degap(A::AbstractDimArray; dim = nothing, dt = nothing, margin_ratio = 0.1, ngap = 2, kw...)
    dim = @something dim tdimnum(A)
    tdim = dims(A, dim)
    old_coords = unwrap(tdim)
    new_coords = degap(old_coords; dt, margin_ratio, ngap)
    new_dim = rebuild(tdim, new_coords)
    fill_value = eltype(A)(NaN)
    return reindex(A, new_dim; fill_value, tolerance = Millisecond(0), kw...)
end
