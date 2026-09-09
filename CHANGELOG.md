# Changelog

## [Unreleased]

### Removed

- **Breaking**: `degap` and `reindex`.

### Added

- `DEFAULTS` settings can be overridden through the `SpacePhysicsMakie` theme key, e.g. `with_theme(SpacePhysicsMakie = (; add_title = true))`.

### Changed

- Interactive panels show exactly the requested time range, fetch their source once at creation, and refetch only when the view leaves the loaded range.
- **Breaking**: DimensionalData is a weak dependency; `SpacePhysicsMakie.DimArray` is no longer available.
- **Breaking**: time series are detected by `hastimedim` instead of `.time`/`.times`/`.dims` properties; a `DimArray` without a `Ti` or `:time` dimension now plots through Makie's default recipe.
- **Breaking**: metadata schemas (`MetadataSchema`, `get_schema`, `validate_schema`, …) moved to SpaceDataModel; the HAPIClient extension is gone.
- **Breaking**: lazy sources (plain functions, `Product`, `Transformed`) are fetched through `SpaceDataModel.getdata(x, t0, t1)` (SpaceDataModel 0.3).

## [0.2.0] - 2025-11-19

### Changed

- **Breaking**: plotting system has been rewritten to use Makie's (0.24) compute graph API. Support for older Makie versions has been dropped.