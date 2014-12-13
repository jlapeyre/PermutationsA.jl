export PermList
export randpermlist, leastmoved, greatestmoved, supportsize, support, fixed
export pow2

import DataStructures: list

immutable PermList{T<:Real} <: AbstractPerm{T}
    data::Vector{T}
end

PermList() = PermList(Int[])

## Construct PermList objects ##

# maybe check validity, make less generic methods for efficiency
# Allow different element types ?
permlist(plist...) = PermList(collect(plist))
permlist{T<:Integer}(a::Vector{T}) = PermList(a)
permlist() = PermList(Array(Int,0))

## Copying, indexing, ... ##

copy(p::PermList) = PermList(copy(p.data))
length(p::PermList) = length(p.data)
plength(p::PermList) = length(p.data)

# Single dimensional index means different things in different
# contexts. We need to choose one meaning.
# This is for accessing the matrix elements as a 'virtual' 1d array.
#function getindex{T}(m::PermList{T}, k::Integer)
#    i,j = divrem(k-1,plength(m))
#    return m.data[j+1] == i+1 ? one(T) : zero(T)
#end
#getindex{T}(m::PermMat{T}, k::Integer) = k > length(m.data) ? convert(T,k) : (m.data)[k]

setindex!(p::PermList, i::Int, k::Integer) = p.data[k] = i
getindex{T}(p::PermList{T}, k::Real) = k > length(p.data) ? convert(T,k) : (p.data)[k]
map{T}(p::PermList{T}, k::Real) = k > length(p.data) ? convert(T,k) : (p.data)[k]

## Compare, test, and/or return properties ##

==(p::PermList, q::PermList) = PermPlain.permlistisequal(p.data,q.data) # agrees with gap
<(p::PermList, q::PermList) =  PermPlain.ltpermlist(p.data,q.data) # agrees with pari (or was it gap?)
<=(p::PermList, q::PermList) = PermPlain.lepermlist(p.data,q.data) # agrees with pari (or was it gap?)

## Generate, transform  PermList objects ##

randcyclelist(n::Integer) = PermList(randcycle(n))
idpermlist(n::Integer) = PermList([1:n])
idpermlist(T::DataType, n::Integer) = PermList([one(T):convert(T,n)])
idpermlist(p::PermList) = PermList([1:length(p.data)])
idperm{T}(p::PermList{T}) = PermList([one(T):convert(T,length(p.data))])
inv(p::PermList) = PermList(invperm(p.data))

## Apply permutation, and permutation operations ##

getindex{T}(v::Array{T,1},p::PermList{Bool}) = error("Silence compiler. You don't want Bool, anyway")
getindex(v::Array, p::PermList) = v[p.data] # How to define this for everything?
getindex(v::String, p::PermList) = v[p.data] # How to define this for everything?
*(p::PermList, k::Real) = k > length(p) ? k : p[k]
# Following is a bit inconsistent. Should we permute the elements based on
# their position, or on their value ? Should we grow array if necessary ?
*{T<:String}(p::PermList, v::T) = PermPlain.permapply(p.data,v)
*{T}(p::PermList, a::AbstractVector{T}) = PermPlain.permapply(p.data,a)
*(p::PermList, q::PermList) = PermList(PermPlain.permcompose(p.data,q.data))
# updating ops are "syntactic-operators". Don't know how to define method for them
# *=(p::PermList, q::PermList) = (permcompose!(p.data,q.data), p)
compose!(p::PermList, q::PermList) = PermPlain.permcompose!(p.data,q.data)

# see pari,gap for more efficient algorithm
/(p::PermList, q::PermList) = PermList(PermPlain.permcompose(p.data,invperm(q.data)))
^(p::PermList, k::Integer) = PermList(PermPlain.permpower(p.data,k))
pow2(p::PermList, k::Real) = PermList(PermPlain.cyc_pow_perm(cycles(p).data,k))

# preimage of k under p
/(k::Int, p::PermList) = PermPlain.preimage(p.data,k)

## Output ##

 # How to use keyword arguments?
function aprint(io::IO, p::PermList)
    PermPlain.permarrprint(io,p.data)
    println(io)
    PermPlain.permarrprint(io,[1:length(p.data)])
end

aprint(p::PermList) = aprint(STDOUT,p)
print(io::IO, p::PermList) = PermPlain.permarrprint(io,p.data)
lprint(io::IO, p::PermList) = print(io,p)
lprint(p::PermList) = lprint(STDOUT,p)
show(io::IO, p::PermList) = print(io,p)
show(p::PermList) = print(p)
# This is needed to avoid trying to print PermList with showarray and failing in 1000 ways
writemime(io::IO, ::MIME"text/plain", p::PermList) = print(io,p)

## tests and properties

for (f1,f2) in ((:order, :permorder) , (:sign, :permsgn),
                (:cyclelengths, :cyclelengths), (:cycletype, :cycletype),
                (:isid, :isid), (:leastmoved, :leastmoved),
                (:greatestmoved,:greatestmoved), (:supportsize, :supportsize),
                (:support,:support), (:fixed,:fixed), (:isperm, :isperm))
    @eval begin
        ($f1)(m::PermList) = (PermPlain.$f2)(m.data)
    end
end

for (f1,f2) in ((:commute, :permcommute) , (:distance, :permdistance),
                (:same, :same), (:inv , :invperm) )
    @eval begin
        ($f1)(m1::PermList, m2::PermList) = (PermPlain.$f2)(m1.data,m2.data)
    end
end

# function ==(pm::PermList, m::AbstractMatrix)
#     (n1,n2) = size(m)
#     d = pm.data
#     n1 == n2 || return false
#     for j in 1:n1
#         for i in 1:n1
#             val = m[i,j]
#             if val != 0
#                 ((val == 1 && d[j] == i) || return false)
#             end
#         end
#     end
#     return true
# end

function *(m1::PermList, m2::AbstractMatrix)
    p = m1.data
    n = length(p)
    om = zeros(m2)
    for j in 1:n
        for i in 1:n
            om[i,j] = m2[i,p[j]]
        end
    end
    return om
end

# can't make m2 abstract, because I get method collisions.
# sol'n depends on whose special matrix routine should be applied.
function *(m2::Matrix, m1::PermList)
    p = m1.data
    n = length(p)
    om = zeros(m2)
    for j in 1:n
        for i in 1:n
            om[i,j] = m2[p[i],j]
        end
    end
    return om
end
