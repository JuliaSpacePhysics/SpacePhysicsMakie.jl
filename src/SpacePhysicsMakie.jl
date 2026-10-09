module SpacePhysicsMakie
using Makie
using Dates
using Unitful
using SpaceDataModel: SpaceDataModel, getdata, getmeta, times, unwrap, NoMetadata, tdimnum, hastimedim
using SpaceDataModel: Dataset, Product, AbstractDataVariable, get_schema, depend_1
import SpaceDataModel as SDM
using InverseFunctions: inverse
using NaNStatistics: nanextrema
using Statistics: mean

using Makie: ComputeGraph, Interval
using Makie.ComputePipeline

export tplot!, tplot, tplot_panel, tplot_panel!
export LinesPlot, linesplot, linesplot!
export multiplot
export MultiAxisData, MultiAxisPlot, multiaxisplot
export tlims!, tlines!, tvspan!, add_labels!
export axis_attributes, plot_attributes
export isspectrogram

function tplot end
function multiaxisplot end

include("types.jl")
include("transform.jl")
include("core.jl")
include("dataset.jl")
include("panel.jl")
include("utils.jl")
include("spectrogram.jl")
include("interactive.jl")
include("recipes/funcplot.jl")
include("recipes/linesplot.jl")
include("recipes/specplot.jl")
include("recipes/multiplot.jl")
include("recipes/multiaxisplot.jl")
include("attributes.jl")
include("axis.jl")
include("methods.jl")
include("makie.jl")
end
