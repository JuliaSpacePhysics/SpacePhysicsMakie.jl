struct DataViewer{D} <: Function
    data::D
end

(d::DataViewer)(tmin, tmax) = tview(d.data, tmin, tmax)

"""
    transform(args...; kwargs...)

Transform data into plottable format (e.g., `DimArray`).

Extend with `transform(x::MyType)` for custom types.
"""
transform(x, args...) = x
transform(x::AbstractArray{<:Number}, tmin, tmax) = DataViewer(x)
