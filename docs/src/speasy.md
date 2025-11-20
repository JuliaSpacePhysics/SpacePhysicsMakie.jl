# Demo: Plotting with `Speasy`

```@example speasy
using Dates
using Speasy
spz = speasy
using CairoMakie, SpacePhysicsMakie
```

## Complex requests and flexible layout

Visualize multiple time series in a customized layout.

```@example speasy
data = let intervals = ["2019-01-02T15", "2019-01-02T16"]
    products = [
        spz.inventories.tree.cda.MMS.MMS1.FGM.MMS1_FGM_SRVY_L2.mms1_fgm_b_gse_srvy_l2_clean,
        spz.inventories.tree.cda.MMS.MMS1.SCM.MMS1_SCM_SRVY_L2_SCSRVY.mms1_scm_acb_gse_scsrvy_srvy_l2,
        spz.inventories.tree.cda.MMS.MMS1.DES.MMS1_FPI_FAST_L2_DES_MOMS.mms1_des_bulkv_gse_fast,
        spz.inventories.tree.cda.MMS.MMS1.DES.MMS1_FPI_FAST_L2_DES_MOMS.mms1_des_temppara_fast,
        spz.inventories.tree.cda.MMS.MMS1.DES.MMS1_FPI_FAST_L2_DES_MOMS.mms1_des_tempperp_fast,
        spz.inventories.tree.cda.MMS.MMS1.DES.MMS1_FPI_FAST_L2_DES_MOMS.mms1_des_energyspectr_omni_fast,
        spz.inventories.tree.cda.MMS.MMS1.DIS.MMS1_FPI_FAST_L2_DIS_MOMS.mms1_dis_energyspectr_omni_fast
    ]
    Speasy.get_data(products, intervals)
end
```

Plotting multiple time series on a single figure

```@example speasy
let figure = (; size=(1200, 1200)), add_title = true
    f = Figure(; figure...)
    tplot(f[1, 1], data[1:3]; add_title)
    tplot(f[1, 2], [data[4:5], data[6:7]...]; add_title)
    f
end
```

## Interactive tplot with Speasy

Visual exploration of OMNI data

```@example speasy
t0 = DateTime("2008-09-05T10:00:00")
t1 = DateTime("2008-09-05T22:00:00")
tvars = spz"cda/OMNI_HRO_1MIN/flow_speed,E,Pressure"
f, axes = tplot(tvars, t0, t1)
```

Here we simulate a user interacting with the plot by progressively zooming out in time with `tlims!`.
Note: For real-time interactivity, consider using the `GLMakie` backend instead of `CairoMakie`.

```@example speasy
dt = Hour(12)

record(f, "speasy.mp4", 1:5; framerate=1) do n
    tlims!(t0 - n * dt, t1 + n * dt)
    sleep(1)
end
```

```@raw html
<video autoplay loop muted playsinline controls src="./speasy.mp4" />
```