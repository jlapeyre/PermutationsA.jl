#abstract AbstractPerm{T} 
abstract AbstractPerm{T} <: AbstractMatrix{T}

export AbstractPerm
export plength, isid, idperm, sparse

import Base: rank, sign, det, logdet, trace, ishermitian, issym, istriu,
       istril, isposdef, null, getindex,  transpose, ctranspose, inv, map,
       isperm, one, full, sparse, size

size(m::AbstractPerm) = (s = plength(m); (s,s))

# this one is not called for some reason
getindex{T}(m::AbstractPerm{T}, i::Real, j::Real) =  map(m,j) == i ? one(T) : zero(T)
# this one is called
getindex(m::AbstractPerm, i::Real, j::Real) =  map(m,j) == i ? one(eltype(m)) : zero(eltype(m))
\(p::AbstractPerm, k::Integer) = k / p

function mkerrf()
    for sym in (:plength, :isid, :isperm, :map, :sign, :idperm )
        @eval begin
            ($sym)(p::AbstractPerm) = error("AbstractPerm: `", $sym , "' not defined for ", typeof(p))
        end
    end
end

mkerrf()

# dense matrix
full(p::AbstractPerm) = [p[i,j] for i=1:plength(p), j=1:plength(p)]

# sparse matrix
function sparse{T}(m::AbstractPerm{T})
    n = plength(m)
    I = [1:n]
    J = T[ map(m,i) for i in 1:n] # should call a routine for this, so that PermCyc is efficient
#    J = (m.data)[I]
    V = ones(T,n)
    sparse(J,I,V)
end

one(m::AbstractPerm) = idperm(m)
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
