using SpaceDataModel
using SpaceDataModel: Product, AbstractDataVariable, AbstractProduct, AbstractDataSet

mappable(x::Product) = (x,)
plottype(x::AbstractDataVariable) = isspectrogram(x) ? SpecPlot : LinesPlot
plottype(::AbstractProduct) = FunctionPlot
plottype(::AbstractDataSet) = MultiPlot

makie_x(da::AbstractDataVariable) = makie_t2x(times(da))


transform(x::AbstractProduct, args...) = DimArray ∘ x
transform(x::AbstractDataSet, args...) = x