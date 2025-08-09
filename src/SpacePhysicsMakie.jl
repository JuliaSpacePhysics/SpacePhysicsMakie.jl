module SpacePhysicsMakie
using Makie
using Dates
using Unitful, Latexify, UnitfulLatexify
using SpaceDataModel: meta, AbstractDataVariable
using DimensionalData: DimArray
using Accessors: @set

import Makie: convert_arguments, plot!, conversion_trait, get_plots

export tplot!, tplot, tplot_panel, tplot_panel!
export LinesPlot, linesplot, linesplot!
export tlims!, tlines!, add_labels!
export transform, transform_speasy
export plot_attributes

include("makie.jl")
include("types.jl")
include("transform.jl")
include("core.jl")
include("panel.jl")
include("specapi.jl")
include("recipes/dualplot.jl")
include("recipes/funcplot.jl")
include("recipes/linesplot.jl")
include("recipes/multiplot.jl")
include("recipes/panelplot.jl")
include("recipes/specplot.jl")
include("interactive.jl")
include("attributes.jl")
include("methods.jl")
include("utils.jl")
include("../ext/DimensionalDataExt.jl")
include("../ext/SpaceDataModelExt.jl")
end
