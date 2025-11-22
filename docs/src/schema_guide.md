# Metadata Schema Architecture Guide

## Overview

The metadata schema architecture provides a flexible, mapping-based approach for converting metadata from different data formats (ISTP, HAPI, Madrigal) to plot attributes.

First we map the metadata to a standard dictionary using the `MetadataSchema` type. Then depending on the plot type, we map the dictionary to the axis attributes and plot attributes that `Makie` needs.

## Architecture Components

### 1. MetadataSchema Types

Abstract type `MetadataSchema` with concrete implementations:

- `ISTPSchema` - For ISTP-compliant metadata (currently implemented)
- `HAPISchema` - For HAPI interface
- `MadrigalSchema` - For Madrigal data
- `PySPEDASSchema` - For PySPEDAS tplot variable metadata

### 2. Key Mapping System

Each schema defines a mapping from plot attributes to metadata keys:

```julia
metadata_keys(::HAPISchema) = (
    desc = "description",
    name = "name",
    unit = "units",
)
```

## Usage Examples

### Extract Multiple Attributes

```julia
using SpacePhysicsMakie

schema = ISTPSchema()
attrs = schema(data)
```

## Extending for New Metadata Formats

Below are the codes for defining a new metadata schema for a new data format.

```julia
struct NewSchema <: MetadataSchema end

metadata_keys(::NewSchema) = (
    desc = "description",
    name = "name",
    unit = "units",
)
```
