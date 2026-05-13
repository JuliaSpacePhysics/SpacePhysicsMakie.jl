# CachedFunction is a wrapper for a function and its data
struct CachedFunction{F, D} <: Function
    f::F
    data::D
end

(f::CachedFunction)(args...) = f.f(args...)
data(f::CachedFunction, args...) = f.data
data(f, tmin, tmax) = tview(f, tmin, tmax)
data(f) = f()
meta(f::CachedFunction) = meta(f.f)

"""
    transform(args...; kwargs...)

Transform data into plottable format (e.g., `DimArray`).

Extend with `transform(x::MyType)` for custom types.
"""
transform(x, args...) = x
transform(f::Function, args...) = CachedFunction(f, data(f, args...))
