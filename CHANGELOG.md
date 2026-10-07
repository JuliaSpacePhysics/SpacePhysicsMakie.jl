# Changelog

## [Unreleased]

### Added

- `DEFAULTS.bin` (and `specplot!(ax, A; bin)`): how merged spectrogram samples combine, `mean` by default; e.g. `maximum` keeps short bursts visible, `nothing` draws every sample.
- Time series in storage (e.g. CDFDatasets variables) plot without `transform`: each fetch is read into memory once, coordinates included.

### Changed

- **Breaking**: requires SpaceDataModel 0.4. Time series are those with a `tdimnum` (SpaceDataModel's `hastimedim`). The DimensionalData extension is removed, as SpaceDataModel implements `tdimnum` for `DimArray`s.

### Fixed

- Spectrograms draw each sample and channel as one flat cell, with channel edges at geometric midpoints on a log axis, instead of blending colors between samples and cutting the outer half-cells. A sample spans half its local cadence on each side, so dense (burst) periods do not overlap their neighbours and data gaps stay empty.
- Long spectrograms render: samples narrower than a pixel are merged as the view changes (GLMakie drew nothing past ~32k samples; CairoMakie took a minute for a day at 1 s).
- `tplot(ds::Dataset, t0, t1)` skips ISTP data variables without a time dimension instead of drawing them against an index axis.

### Removed

- `DEFAULTS.resample`, which no plot read.

## [0.3.0] - 2026-10-01

### Added

- `tplot(ds::Dataset, t0, t1; vars)` plots one panel per data variable; the panels share each fetch.
- `DEFAULTS` settings can be overridden through the `SpacePhysicsMakie` theme key, e.g. `with_theme(SpacePhysicsMakie = (; add_title = true))`.

### Removed

- **Breaking**: `degap` and `reindex`.

### Changed

- Interactive panels show exactly the requested time range, fetch their source once at creation, and refetch only when the view leaves the loaded range.
- **Breaking**: DimensionalData is a weak dependency; `SpacePhysicsMakie.DimArray` is no longer available.
- **Breaking**: time series are detected by `hastimedim` instead of `.time`/`.times`/`.dims` properties; a `DimArray` without a `Ti` or `:time` dimension now plots through Makie's default recipe.
- **Breaking**: metadata schemas (`MetadataSchema`, `get_schema`, `validate_schema`, …) moved to SpaceDataModel; the HAPIClient extension is gone.
- **Breaking**: lazy sources (plain functions, `Product`, `Transformed`) are fetched through `SpaceDataModel.getdata(x, t0, t1)` (SpaceDataModel 0.3).

## [0.2.0] - 2025-11-19

### Changed

- **Breaking**: plotting system has been rewritten to use Makie's (0.24) compute graph API. Support for older Makie versions has been dropped.