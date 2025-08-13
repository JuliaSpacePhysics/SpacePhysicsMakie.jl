using SpaceDataModel
using SpaceDataModel: Product, AbstractDataVariable, AbstractProduct, AbstractDataSet

mappable(x::Product) = (x,)
plottype(x::AbstractDataVariable) = isspectrogram(x) ? SpecPlot : LinesPlot
plottype(::AbstractProduct) = FunctionPlot
plottype(::AbstractDataSet) = MultiPlot

makie_x(da::AbstractDataVariable) = makie_t2x(parent(times(da)))

Makie.convert_arguments(::Type{<:LinesPlot}, da::AbstractDataVariable; kwargs...) = plot2spec(LinesPlot, da; kwargs...)

transform(x::AbstractDataVariable) = DimArray(x) # TODO: remove this; we need this mainly to resample data
transform(x::AbstractProduct, args...) = DimArray ∘ x
transform(x::AbstractDataSet, args...) = x
transform(p::AbstractArray{<:AbstractDataVariable}; kwargs...) = DimArray.(p; kwargs...)