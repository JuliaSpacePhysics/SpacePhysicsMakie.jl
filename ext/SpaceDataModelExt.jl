using SpaceDataModel: AbstractDataVariable

plottype(x::AbstractDataVariable) = isspectrogram(x) ? SpecPlot : LinesPlot
makie_x(da::AbstractDataVariable) = makie_t2x(times(da))
