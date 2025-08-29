module SpacePhysicsMakie
using Makie
using Dates
using Unitful
using InverseFunctions: inverse
using SpaceDataModel: meta, NoMetadata
using DimensionalData: DimArray
using Statistics: mean

import Makie: convert_arguments, plot!, conversion_trait, get_plots

export tplot!, tplot, tplot_panel, tplot_panel!
export LinesPlot, linesplot, linesplot!
export tlims!, tlines!, tvspan!, add_labels!
export axis_attributes, plot_attributes

include("types.jl")
include("transform.jl")
include("core.jl")
include("panel.jl")
include("spectrogram.jl")
include("specapi.jl")
include("recipes/dualplot.jl")
include("recipes/funcplot.jl")
include("recipes/linesplot.jl")
include("recipes/multiplot.jl")
include("recipes/specplot.jl")
include("interactive.jl")
include("attributes.jl")
include("axis.jl")
include("methods.jl")
include("utils.jl")
include("../ext/DimensionalDataExt.jl")
include("../ext/SpaceDataModelExt.jl")
end
