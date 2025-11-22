module SpacePhysicsMakie
using Makie
using Dates
using Unitful
using InverseFunctions: inverse
using SpaceDataModel: SpaceDataModel, times, unwrap, NoMetadata
using DimensionalData: DimArray
using Statistics: mean

import Makie: convert_arguments, plot!, conversion_trait, get_plots
using Makie: ComputeGraph
using Makie.ComputePipeline

export tplot!, tplot, tplot_panel, tplot_panel!
export LinesPlot, linesplot, linesplot!
export multiplot
export MultiAxisData, MultiAxisPlot, multiaxisplot
export tlims!, tlines!, add_labels!
export axis_attributes, plot_attributes
export isspectrogram
export get_schema, validate_schema, MetadataSchema

function tplot end
function multiaxisplot end

include("types.jl")
include("transform.jl")
include("core.jl")
include("panel.jl")
include("utils.jl")
include("schemas/schema.jl")
include("spectrogram.jl")
include("specapi.jl")
include("recipes/funcplot.jl")
include("recipes/linesplot.jl")
include("recipes/specplot.jl")
include("recipes/multiplot.jl")
include("recipes/multiaxisplot.jl")
include("interactive.jl")
include("attributes.jl")
include("axis.jl")
include("methods.jl")
include("makie.jl")
include("../ext/DimensionalDataExt.jl")
include("../ext/SpaceDataModelExt.jl")
end
