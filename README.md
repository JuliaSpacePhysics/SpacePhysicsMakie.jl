# SpacePhysicsMakie.jl

[![Build Status](https://github.com/JuliaSpacePhysics/SpacePhysicsMakie.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaSpacePhysics/SpacePhysicsMakie.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![Coverage](https://codecov.io/gh/JuliaSpacePhysics/SpacePhysicsMakie.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaSpacePhysics/SpacePhysicsMakie.jl)

Space physics plotting utilities built on [`Makie.jl`](https://makie.juliaplots.org/).  

Designed for fast, interactive plotting of multiple time series with automatic handling of ISTP metadata. While tailored for space physics, it supports any time series data via extensible `transform` function.

**Installation**: at the Julia REPL, run `using Pkg; Pkg.add("SpacePhysicsMakie")`

## Features

- **Versatile**: Unified API (`tplot`) for various time series representations including dimensional arrays, functions, or product IDs (strings).
- **Flexible Layouts**: Separate panels (`tplot_panel`), overlaid plots (`multiplot`), or secondary-y-axis (`multiaxisplot`) panels.
- **Interactive Exploration**: Efficient data retrieval and rendering during zoom/pan operations.

## Roadmap

- [ ] Add marking tools such as vertical lines across panels, horizontal bars, and rectangular shadings. The marking tools are often used to indicate interesting time periods for event analysis.
- [ ] Geospatial plotting support

## Development

- To support other data types, the simplest way is to extend the `transform` function and `transform` the data to a supported type like `DimArray`.
- A better approach would be to extend `getmeta` and `dim` methods in [`SpaceDataModel`][SpaceDataModel] for your custom data structures so that we can extract the dimension data with its metadata (label and unit) automatically.

## Elsewhere

- Makie.jl and its ecosystem
    - [GeoMakie.jl](https://github.com/JuliaPlots/GeoMakie.jl): plotting geospatial data on a given map projection
    - [UnfoldMakie.jl](https://github.com/JuliaNeuroscience/UnfoldMakie.jl): visualizations of EEG/ERP data and Unfold.jl models.
    - [AlgebraOfGraphics](https://aog.makie.org/stable/): An algebraic spin on grammar-of-graphics data visualization
- [PyTplot](https://pyspedas.readthedocs.io/en/latest/pytplot.html)
- [InteractiveViz.jl](https://github.com/org-arl/InteractiveViz.jl)
- [SciQLop](https://github.com/SciQLop/SciQLop): A python application built on top of `Qt` to explore multivariate time series effortlessly,

[SpaceDataModel]: https://juliaspacephysics.github.io/SpaceDataModel.jl