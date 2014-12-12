import Base: one, showarray, print, show, writemime

export leastmoved, greatestmoved, supportsize, support, fixed, list,
       idperm, plength

export randcyclelist
export commute, isperm
export compose!, eltype
export print, arrprint, cycprint, show, map

import Base: isperm, size
import Main: eltype
import DataStructures: list

immutable PermList{T<:Integer} <:AbstractPerm
    data::Array{T,1}
end

PermList() = PermList(Int[])

eltype{T}(p::PermList{T}) = (println(" permlist $T"); T)
# does not work
#eltype{T}(::PermList{T}) = (println(" permlist $T"); T)


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
getindex(p::PermList, k::Real) = p.data[k]
setindex!(p::PermList, i::Int, k::Integer) = p.data[k] = i
map{T}(p::PermList{T}, k::Real) = k > length(p.data) ? convert(T,k) : (p.data)[k]


## Compare, test, and/or return properties ##

isperm(p::PermList) = isperm(p.data)
isid(p::PermList) = PermPlain.isid(p.data)
commute(p::PermList,q::PermList) = permcommute(p.data,q.data)
distance(p::PermList, q::PermList) = permdistance(p.data,q.data)
# looks like Julia defines combinations and opposites automatically, unless otherwise defined

#= 

==(p::PermList, q::PermList) = (println("eq");permlistisequal(p.data,q.data)) # agrees with gap
<(p::PermList, q::PermList) = (println("less");ltpermlist(p.data,q.data)) # agrees with pari (or was it gap?)
<=(p::PermList, q::PermList) = (println("lesseq"); PermPlain.lepermlist(p.data,q.data)) # agrees with pari (or was it gap?)

=#

==(p::PermList, q::PermList) = permlistisequal(p.data,q.data) # agrees with gap
<(p::PermList, q::PermList) =  ltpermlist(p.data,q.data) # agrees with pari (or was it gap?)
<=(p::PermList, q::PermList) = PermPlain.lepermlist(p.data,q.data) # agrees with pari (or was it gap?)
sign(p::PermList) = permsgn(p.data)
order(p::PermList) = permorder(p.data)
cyclelengths(p::PermList) = cyclelengths(p.data)
cycletype(p::PermList) = cycletype(p.data)

## Generate, transform  PermList objects ##

randcyclelist(n::Integer) = PermList(randcycle(n))
idpermlist(n::Integer) = PermList([1:n])
idpermlist(T::DataType, n::Integer) = PermList([one(T):convert(T,n)])
idpermlist(p::PermList) = PermList([1:length(p.data)])
idperm{T}(p::PermList{T}) = PermList([one(T):convert(T,length(p.data))])
inv(p::PermList) = PermList(invperm(p.data))
#one(p::PermList) = idperm(p)

## Apply permutation, and permutation operations ##

getindex(v::Array, p::PermList) = v[p.data] # How to define this for everything?
getindex(v::String, p::PermList) = v[p.data] # How to define this for everything?
*(p::PermList, k) = k > length(p) ? k : p[k]
  # Notice we don't restrict T., TODO: avoid deref on every iteration
*{T}(p::PermList, a::AbstractVector{T}) = [ p * i for i in a]
*(p::PermList, q::PermList) = PermList(permcompose(p.data,q.data))
# updating ops are "syntactic-operators". Don't know how to define method for them
# *=(p::PermList, q::PermList) = (permcompose!(p.data,q.data), p)
compose!(p::PermList, q::PermList) = permcompose!(p.data,q.data)

# see pari,gap for more efficient algorithm
/(p::PermList, q::PermList) = PermList(permcompose(p.data,invperm(q.data)))
^(p::PermList, k::Integer) = PermList(permpower(p.data,k))

# Uing d[i] rather than p[i] is  20-30 percent faster.
# Seems compiler is not yet smart enough to optimize this
# preimage of k under p
/(k::Int, p::PermList) = PermPlain.preimage(p.data,k)
\(p::PermList, k::Int) = k / p

# List of points mapped to same point by p and q
same(p::PermList, q::PermList) = PermPlain.same(p.data,q.data)
# agrees with gap (except definition,use of inifinity is different)
leastmoved(p::PermList) = PermPlain.leastmoved(p.data)
# agrees with gap
greatestmoved(p::PermList) = PermPlain.greatestmoved(p.data)
supportsize(p::PermList) = PermPlain.supportsize(p.data)
support(p::PermList) = PermPlain.support(p.data)
fixed(p::PermList) = PermPlain.fixed(p.data)

## Output ##

 # How to use keyword arguments?
function arrprint(io::IO, p::PermList)
    permarrprint(io,p.data)
    println(io)
    permarrprint(io,[1:length(p.data)])
end

arrprint(p::PermList) = arrprint(STDOUT,p)
cycprint(io::IO,p::PermList) = print(io,cycles(p))
cycprint(p::PermList) = cycprint(STDOUT,p)
print(io::IO, p::PermList) = permarrprint(io,p.data)
lineprint(io::IO, p::PermList) = print(io,p)
lineprint(p::PermList) = lineprint(STDOUT,p)
show(io::IO, p::PermList) = print(io,p)
show(p::PermList) = print(p)
# This is needed to avoid trying to print PermList with showarray and failing in 1000 ways
writemime(io::IO, ::MIME"text/plain", p::PermList) = print(io,p)
