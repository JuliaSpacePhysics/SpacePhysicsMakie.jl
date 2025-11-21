```@meta
CurrentModule = SpacePhysicsMakie
```

# SpacePhysicsMakie.jl

[SpacePhysicsMakie.jl](https://github.com/JuliaSpacePhysics/SpacePhysicsMakie.jl) provides a set of utilities for visualizing space physics data:

- [`tplot_panel`](@ref): Creates single panel plots with support for multiple data types
- [`tplot`](@ref): Combines multiple panels into a figure

`tplot_panel` handles various time series formats including vectors, matrices, functions. It renders data as line plots, series plots, spectrograms and overlaid plots.

`tplot` offers flexible visualization options, allowing you to display multiple time series either across separate panels.

`SpacePhysicsMakie` integrates with many packages in the space physics ecosystem through a common API defined in [SpaceDataModel.jl](https://juliaspacephysics.github.io/SpaceDataModel.jl/dev/). See [real world example](./speasy.md) of using [`Speasy.jl`](https://github.com/SciQLop/Speasy.jl) to retrieve and visualize data. More demos are available in the [Examples](./examples.md) page.

Built on `Makie`'s [complex layouts](https://makie.juliaplots.org/stable/plotting/complex-layouts/) capabilities, `tplot` provides both interactive exploration capabilities and publication-quality output. It features dynamic data loading during zoom/pan operations, efficiently retrieving and rendering data on demand.

```@docs
tplot
tplot_panel
tplot_panel!
```

## Installation

```julia
using Pkg
Pkg.add("SpacePhysicsMakie")
```

## Flexible `tplot_panel`

```@example tplot
using Unitful
using CairoMakie, SpacePhysicsMakie

# Create sample data
n = 24
data1 = rand(n) * 4u"km/s"  # Vector with units
data2 = rand(n) * 4u"km/s"  # Same units
data3 = rand(n) * 1u"eV"    # Different units
data4 = rand(n,4)           # Matrix (for heatmap)

f = Figure()

# Basic Plotting
tplot_panel(f[1, 1], data1; axis=(;title="Single time series"))

# Multiple Series (same y-axis)
tplot_panel(f[2, 1], [data1, data2]; axis=(;title="Multiple series"), plottypes=Lines)

# Secondary Y-Axes for different units with different plot types
tplot_panel(f[3, 1], (data1, data3); axis=(;title="Secondary y-axes"), plottypes=(Lines, ScatterLines))

# Combine with plain `Makie` plots to plot matrix as `series`
series(f[1, 2], data4'; axis=(;title="Series"))

# Overlay Series on Heatmap
tplot_panel(f[2, 2], [data4, data1, data2]; axis=(;title="Heatmap with overlays"))

# XY Plot (non-time series)
tplot_panel(f[3, 2], sort(data2), data3; axis=(;title="XY plot (fallback)"))

f
```

## Composable `tplot`

You can also combine multiple panels into a single figure using `tplot`. By default, it links the x-axis of each panel and layouts the panels in a single column.

```@example tplot
tvars = [
    data1,                  
    [data1, data2],        
    (data1, data3),
]
tplot(tvars)
```

`tplot` also supports plotting on `GridPosition` and `GridSubposition` objects

## Function as `tplot` argument for interactive exploration

`tplot` can handle functions that accept time intervals as arguments.
This allows for creating interactive plots where data is dynamically fetched. So instead of the two-step process:

1. Fetch data: `da = f(t0, t1)`
2. Plot data: `tplot(da)`

We can combine these steps into a single command:

`tplot(f, t0, t1)`

This approach enables efficient interactive exploration of time series.

!!! note
    
    For real-time interactivity, consider using the `GLMakie` backend instead of `CairoMakie` although it is possible to use `tlims!` or `xlims!` to update the plot dynamically.

## Data Transformation

Before plotting, data goes through a transformation pipeline to ensure it's in a plottable format (e.g., `DimArray`).

```@docs
SpacePhysicsMakie.transform
```

You can extend the transformation system by defining methods for your types:

```julia
transform(x::MyType) = DimArray(x.data)
```

## Related packages

- [AlgebraOfGraphics](https://aog.makie.org/stable/): An algebraic spin on grammar-of-graphics data visualization
- [PyTplot](https://pyspedas.readthedocs.io/en/latest/pytplot.html)
- [InteractiveViz.jl](https://github.com/org-arl/InteractiveViz.jl)
- [SciQLop](https://github.com/SciQLop/SciQLop) : A python application built on top of `Qt` to explore multivariate time series effortlessly,

## API

```@index
```

```@autodocs
Modules = [SpacePhysicsMakie]
```
