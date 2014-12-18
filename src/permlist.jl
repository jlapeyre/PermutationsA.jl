export PermList
export randpermlist, leastmoved, greatestmoved, supportsize, support, fixed
export pow2
export pivtopermlist

import DataStructures: list

immutable PermList{T<:Real} <: AbstractPerm{T}
    data::Vector{T}
end

setindex!(p::PermList, i::Int, k::Integer) = p.data[k] = i
getindex{T}(p::PermList{T}, k::Real) = k > length(p.data) ? convert(T,k) : (p.data)[k]
length(p::PermList) = length(p.data)

randcyclelist(n::Integer) = PermList(randcycle(n))

pivtopermlist{T<:Real}(piv::AbstractArray{T}) = PermList(PermPlain.ipiv2perm(piv))
pivtopermlist{T<:Real}(piv::AbstractArray{T},n) = PermPlain.ipiv2perm(piv,n)

## Apply permutation, and permutation operations ##

getindex{T}(v::Array{T,1},p::PermList{Bool}) = error("Silence compiler. You don't want Bool, anyway")
getindex(v::Array, p::PermList) = v[p.data] # How to define this for everything?
getindex(v::String, p::PermList) = v[p.data] # How to define this for everything?
*(p::PermList, k::Real) = k > length(p) ? k : p[k]
*{T}(p::PermList, a::AbstractVector{T}) = PermPlain.permapply(p.data,a)
# updating ops are "syntactic-operators". Don't know how to define method for them
# *=(p::PermList, q::PermList) = (permcompose!(p.data,q.data), p)
/(p::PermList, q::PermList) = PermList(PermPlain.permcompose(p.data,invperm(q.data)))
# preimage of k under p
/(k::Int, p::PermList) = PermPlain.preimage(p.data,k)

## Output ##


show(io::IO, p::PermList) = print(io,p)
show(p::PermList) = print(p)
# This is needed to avoid trying to print PermList with showarray and failing in 1000 ways
writemime(io::IO, ::MIME"text/plain", p::PermList) = print(io,p)
