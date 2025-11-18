# SpacePhysicsMakie.jl

[![Build Status](https://github.com/JuliaSpacePhysics/SpacePhysicsMakie.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaSpacePhysics/SpacePhysicsMakie.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![Coverage](https://codecov.io/gh/JuliaSpacePhysics/SpacePhysicsMakie.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaSpacePhysics/SpacePhysicsMakie.jl)

Space physics plotting utilities built on [`Makie.jl`](https://makie.juliaplots.org/).  

Designed for fast, interactive plotting of multiple time series with automatic handling of ISTP metadata. While tailored for space physics, it supports any time series data via extensible `transform` function.

**Installation**: at the Julia REPL, run `using Pkg; Pkg.add("SpacePhysicsMakie")`

## Features

- **Versatile**: Unified API (`tplot`) for various time series representations including dimensional arrays, functions, or product IDs (strings).
- **Flexible Layouts**: Separate panels (`tplot_panel`), overlaid plots (`multiplot`), or dual-axis (`dualplot`) panels.
- **Interactive Exploration**: Efficient data retrieval and rendering during zoom/pan operations.

## Examples

- [Basic multi-panel plot](https://juliaspacephysics.github.io/SPEDAS.jl/dev/examples/tplot/) — tplot_panel and tplot.
- [Advanced plotting](https://juliaspacephysics.github.io/SPEDAS.jl/dev/examples/speasy/) — combining multiple data types.
- [Interactive plots](https://juliaspacephysics.github.io/SPEDAS.jl/dev/examples/interactive/) — basic usage.
- [Interactive with data retrieval](https://juliaspacephysics.github.io/SPEDAS.jl/dev/examples/interactive_speasy/) — using Speasy.jl.