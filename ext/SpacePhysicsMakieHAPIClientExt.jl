module SpacePhysicsMakieHAPIClientExt
using HAPIClient: HAPIVariable, HAPIVariables
using SpacePhysicsMakie: HAPISchema
import SpacePhysicsMakie: get_schema
get_schema(::HAPIVariable) = HAPISchema()
get_schema(::HAPIVariables) = HAPISchema()
end
