# Examples

## Demo: Plotting with [`HAPIClient`](https://github.com/JuliaSpacePhysics/HAPIClient.jl)

Visualize Heliophysics Application Programmer's Interface (HAPI) compliant data using `HAPIClient`.

```@example hapi
using HAPIClient: get_data

da = get_data("CDAWeb/AC_H0_MFI/Magnitude,BGSEc", "2001-1-2", "2001-1-2T6")
```

### Plot the data

```@example hapi
using CairoMakie, SpacePhysicsMakie

tplot(da; add_title=true)
```

## Demo: Plotting with [`PySPEDAS`](https://github.com/JuliaSpacePhysics/PySPEDAS.jl)

```@example pyspedas
using PySPEDAS.Projects
using CairoMakie, SpacePhysicsMakie
```

```@example pyspedas
da = themis.fgm(["2020-04-20/06:00", "2020-04-20/08:00"], time_clip=true, probe="d");
tplot((da.thd_fgs_gsm, da.thd_fgs_btotal))
```
