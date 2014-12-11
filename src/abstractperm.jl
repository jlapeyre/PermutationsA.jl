#abstract AbstractPerm{T} 
abstract AbstractPerm{T} <: AbstractMatrix{T}

export plength, isid

import Base: rank, sign, det, logdet, trace, ishermitian, issym, istriu,
       istril, isposdef, null, getindex, size, transpose, ctranspose, inv, map

size(m::AbstractPerm) = (s = plength(m); (s,s))

# this one is not called for some reason
getindex{T}(m::AbstractPerm{T}, i::Real, j::Real) =  map(m,j) == i ? one(T) : zero(T)
# this one is called
getindex(m::AbstractPerm, i::Real, j::Real) =  map(m,j) == i ? one(eltype(m)) : zero(eltype(m))

function mkerrf()
    for sym in (:plength, :isid, :map, :sign )
        @eval begin
            ($sym)(p::AbstractPerm) = error("AbstractPerm: `", $sym , "' not defined for ", typeof(p))
        end
    end
end

mkerrf()

ctranspose(m::AbstractPerm) = inv(m)
transpose(m::AbstractPerm) = inv(m)
inv(m::AbstractPerm) = m^-1

rank(p::AbstractPerm) = plength(p)
det(p::AbstractPerm) = sign(p)
logdet(p::AbstractPerm) = sign(p) > 0 ? 0 : error("AbstractPerm: DomainError: determinant is -1")
trace(p::AbstractPerm) = plength(p) - supportsize(p)
ishermitian(p::AbstractPerm) = isid(p)
issym(p::AbstractPerm) = isid(p)
istriu(p::AbstractPerm) = isid(p)
istril(p::AbstractPerm) = isid(p)
isposdef(p::AbstractPerm) = isid(p)
# can't use {T} in these or they are not found.
null(p::AbstractPerm) = zeros(Float64,plength(p),0) # for consistency
