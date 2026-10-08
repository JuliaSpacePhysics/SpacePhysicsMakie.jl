"""
    tplot([f,] ds::AbstractDataset, t0, t1; vars = data_variables(getdata(ds, t0, t1)), kwargs...)

One panel per variable of `ds`; the panels share each fetch.
"""
tplot(f::Drawable, ds::AbstractDataset, t0, t1; vars = nothing, kwargs...) =
    tplot(f, _variable_sources(ds, t0, t1, vars), t0, t1; kwargs...)
tplot(ds::AbstractDataset, t0, t1; vars = nothing, kwargs...) =
    tplot(_variable_sources(ds, t0, t1, vars), t0, t1; kwargs...)

function _variable_sources(ds, t0, t1, vars)
    src = SharedFetch(ds)
    vars = @something vars data_variables(getdata(src, _compat(t0), _compat(t1)))
    isempty(vars) && throw(ArgumentError("$ds has no time-series data variables in [$t0, $t1)"))
    return [Product(src, var) for var in vars]
end

"""
    data_variables(data)

Keys of `data` worth a panel: time series of rank ≤ 2, excluding ISTP support data and metadata.
"""
data_variables(data) = [k for k in keys(data) if _is_data_variable(data[k])]

# ISTP variables skip `transform`, a user hook that may read data. `DEPEND_0` excludes
# non-record-varying variables, which as `DimArray`s carry a length-1 `Ti`.
function _is_data_variable(v)
    ndims(v) <= 2 || return false
    vartype = getmeta(v, "VAR_TYPE")
    isnothing(vartype) && return hastimedim(transform(v))
    return vartype == "data" && !isnothing(getmeta(v, "DEPEND_0")) && hastimedim(v)
end

# Linked panels request the same range at once on zoom; the lock makes one of them fetch.
mutable struct SharedFetch{S}
    const source::S
    const lock::ReentrantLock
    trange::Any
    data::Any
end

SharedFetch(source) = SharedFetch(source, ReentrantLock(), nothing, nothing)

function SDM.getdata(s::SharedFetch, t0, t1)
    return @lock s.lock begin
        if s.trange != (t0, t1)
            s.data = getdata(s.source, t0, t1)
            s.trange = (t0, t1)
        end
        s.data
    end
end
