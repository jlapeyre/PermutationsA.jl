export PermList
export randpermlist, leastmoved, greatestmoved, supportsize, support, fixed

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

isperm(p::PermList) = PermPlain.isperm(p.data)
isid(p::PermList) = PermPlain.isid(p.data)
commute(p::PermList,q::PermList) = PermPlain.permcommute(p.data,q.data)
distance(p::PermList, q::PermList) = PermPlain.permdistance(p.data,q.data)
# looks like Julia defines combinations and opposites automatically, unless otherwise defined

==(p::PermList, q::PermList) = PermPlain.permlistisequal(p.data,q.data) # agrees with gap
<(p::PermList, q::PermList) =  PermPlain.ltpermlist(p.data,q.data) # agrees with pari (or was it gap?)
<=(p::PermList, q::PermList) = PermPlain.lepermlist(p.data,q.data) # agrees with pari (or was it gap?)
sign(p::PermList) = PermPlain.permsgn(p.data)
order(p::PermList) = PermPlain.permorder(p.data)
cyclelengths(p::PermList) = PermPlain.cyclelengths(p.data)
cycletype(p::PermList) = PermPlain.cycletype(p.data)

## Generate, transform  PermList objects ##

randcyclelist(n::Integer) = PermList(randcycle(n))
idpermlist(n::Integer) = PermList([1:n])
idpermlist(T::DataType, n::Integer) = PermList([one(T):convert(T,n)])
idpermlist(p::PermList) = PermList([1:length(p.data)])
idperm{T}(p::PermList{T}) = PermList([one(T):convert(T,length(p.data))])
inv(p::PermList) = PermList(invperm(p.data))
#one(p::PermList) = idperm(p)

## Apply permutation, and permutation operations ##

getindex{T}(v::Array{T,1},p::PermList{Bool}) = error("Silence compiler. You don't want Bool, anyway")
getindex(v::Array, p::PermList) = v[p.data] # How to define this for everything?
getindex(v::String, p::PermList) = v[p.data] # How to define this for everything?
*(p::PermList, k::Real) = k > length(p) ? k : p[k]
*{T<:String}(p::PermList, v::T) = PermPlain.permapply(p.data,v)
*{T}(p::PermList, a::AbstractVector{T}) = PermPlain.permapply(p.data,a)
*(p::PermList, q::PermList) = PermList(PermPlain.permcompose(p.data,q.data))
# updating ops are "syntactic-operators". Don't know how to define method for them
# *=(p::PermList, q::PermList) = (permcompose!(p.data,q.data), p)
compose!(p::PermList, q::PermList) = PermPlain.permcompose!(p.data,q.data)

# see pari,gap for more efficient algorithm
/(p::PermList, q::PermList) = PermList(PermPlain.permcompose(p.data,invperm(q.data)))
^(p::PermList, k::Integer) = PermList(PermPlain.permpower(p.data,k))

# Uing d[i] rather than p[i] is  20-30 percent faster.
# Seems compiler is not yet smart enough to optimize this
# preimage of k under p
/(k::Int, p::PermList) = PermPlain.preimage(p.data,k)

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

function ==(pm::PermList, m::AbstractMatrix)
    (n1,n2) = size(m)
    d = pm.data
    n1 == n2 || return false
    for j in 1:n1
        for i in 1:n1
            val = m[i,j]
            if val != 0
                ((val == 1 && d[j] == i) || return false)
            end
        end
    end
    return true
end

# could factor this code somehow
function ==(m::AbstractMatrix, pm::PermList)
    (n1,n2) = size(m)
    d = pm.data
    n1 == n2 || return false
    for j in 1:n1
        for i in 1:n1
            val = m[i,j]
            if val != 0
                ((val == 1 && d[j] == i) || return false)
            end
        end
    end
    return true
end

# Wikipedia says that if M_i represents p_i, then
# M_1 * M_2  <---> p_2 ∘ p_1
# We should check and follow this convention.
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
