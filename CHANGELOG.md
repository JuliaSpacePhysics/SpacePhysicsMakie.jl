# Changelog

## [Unreleased]

### Removed

- **Breaking**: `degap` and `reindex`.

### Changed

- **Breaking**: time series are detected by `hastimedim` instead of `.time`/`.times`/`.dims` properties; a `DimArray` without a `Ti` or `:time` dimension now plots through Makie's default recipe.
- **Breaking**: metadata schemas (`MetadataSchema`, `get_schema`, `validate_schema`, …) moved to SpaceDataModel; the HAPIClient extension is gone.
- **Breaking**: lazy sources (plain functions, `Product`, `Transformed`) are fetched through `SpaceDataModel.getdata(x, t0, t1)` (SpaceDataModel 0.3).

## [0.2.0] - 2025-11-19

### Changed

- **Breaking**: plotting system has been rewritten to use Makie's (0.24) compute graph API. Support for older Makie versions has been dropped.