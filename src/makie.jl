# hack as `Makie` does not support `NanoDate` directly
using NanoDates: NanoDate

_makie_t2x(x) = x
_makie_t2x(x::NanoDate) = DateTime(x)
makie_t2x(x) = _makie_t2x.(x)
makie_x(x) = 1:size(x, 1)