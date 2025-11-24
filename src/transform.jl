apply(f, args...) = f(args...)
apply(A::AbstractArray, tmin, tmax) = tview(A, tmin, tmax)

data(f, args...) = apply(f, args...)

struct DataViewer{D} <: Function
    data::D
end
data(d::DataViewer, args...) = d.data
(d::DataViewer)(tmin, tmax) = tview(d.data, tmin, tmax)

# CachedFunction is a wrapper for a function and its data
struct CachedFunction{F, D} <: Function
    f::F
    data::D
end

(f::CachedFunction)(args...) = f.f(args...)
data(f::CachedFunction, args...) = f.data
meta(f::CachedFunction) = meta(f.f)

"""
    transform(args...; kwargs...)

Transform data into plottable format (e.g., `DimArray`).

Extend with `transform(x::MyType)` for custom types.
"""
transform(x, args...) = x
transform(x::AbstractArray{<:Number}, tmin, tmax) = DataViewer(x)
transform(f::Function, args...) = CachedFunction(f, data(f, args...))
