import DimensionalData
import DimensionalData as DD
using DimensionalData: AbstractDimArray, TimeDim, Dim, hasdim

hastimedim(x::AbstractDimArray) = hasdim(x, TimeDim) || hasdim(x, Dim{:time})
