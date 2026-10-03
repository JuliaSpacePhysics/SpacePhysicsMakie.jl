# Changelog

## [Unreleased]

### Added

- Time series in storage (e.g. CDFDatasets variables) plot without conversion: each fetch is read into memory once, coordinates included. `transform` remains an optional hook.

### Changed

- **Breaking**: time series are detected by SpaceDataModel's `hastimedim`, i.e. a `tdimnum` method; an `AbstractDataVariable` without one is no longer plotted as a time series. The DimensionalData extension is gone: SpaceDataModel provides `tdimnum` for `DimArray`s (SpaceDataModel 0.4).

### Fixed

- `tplot(ds::Dataset, t0, t1)` skips ISTP data variables without a time dimension instead of drawing them against an index axis.
- Spectrograms with a time-varying `depend_1` (a matrix laid out like the data) transpose it along with the data.

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