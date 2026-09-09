module SpacePhysicsMakieDimensionalDataExt

using DimensionalData: AbstractDimArray, TimeDim, Dim, hasdim
import SpacePhysicsMakie: hastimedim

hastimedim(x::AbstractDimArray) = hasdim(x, TimeDim) || hasdim(x, Dim{:time})

end
