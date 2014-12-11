import PermPlain: permlistisequal

export leastmoved, greatestmoved, supportsize, support, fixed, list
export randcyclelist
export commute, isperm
export compose!, eltype
export print, arrprint, cycprint, show

import Base: print, show, isperm
import Main: eltype
import DataStructures: list

immutable PermList{T<:Integer}
    data::Array{T,1}
end

eltype{T}(p::PermList{T}) = T

## Construct PermList objects ##

# maybe check validity, make less generic methods for efficiency
# Allow different element types ?
permlist(plist...) = PermList(collect(plist))
permlist{T<:Integer}(a::Vector{T}) = PermList(a)
permlist() = PermList(Array(Int,0))

## Copying, indexing, ... ##

copy(p::PermList) = PermList(copy(p.data))
length(p::PermList) = length(p.data)
getindex(p::PermList, k) = p.data[k]
setindex!(p::PermList, i::Int, k::Integer) = p.data[k] = i

## Compare, test, and/or return properties ##

isperm(p::PermList) = isperm(p.data)
function isid(pin::PermList)
    p = pin.data
    for i in 1:length(p)
        i == p[i] || return false
    end
    return true
end
commute(p::PermList,q::PermList) = permcommute(p.data,q.data)
distance(p::PermList, q::PermList) = permdistance(p.data,q.data)
==(p::PermList, q::PermList) = permlistisequal(p.data,q.data) # agrees with gap
sign(p::PermList) = permsgn(p.data)
order(p::PermList) = permorder(p.data)
cyclelengths(p::PermList) = cyclelengths(p.data)
cycletype(p::PermList) = cycletype(p.data)

## Generate, transform  PermList objects ##

randpermlist(n::Integer) = PermList(randperm(n))
randcyclelist(n::Integer) = PermList(randcycle(n))
idpermlist(n::Integer) = PermList([1:n])
inv(p::PermList) = PermList(invperm(p.data))

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
function /(k::Int, p::PermList)
    d = p.data
    k > length(d) && return k
    for i in 1:length(p)
        if d[i] == k
            return i
        end
    end
    error("Can't find inverse image of $k.")
end
\(p::PermList, k::Int) = k / p


# List of points mapped to same point by p and q
function same(pin::PermList, qin::PermList)
    p = pin.data
    q = qin.data
    lp = length(p)
    lq = length(q)
    d = Array(eltype(pin),0)
    if lp < lq
        for i in 1:lp
            p[i] == q[i] ? push!(d,p[i]) : nothing
        end
        for i in lp+1:lq
            q[i] == i ? push!(d,q[i]) : nothing
        end
    else  # could factor code with refs, prbly not worth the trouble
        for i in 1:lq
            p[i] == q[i] ? push!(d,p[i]) : nothing
        end
        for i in lq+1:lp
            p[i] != i ? push!(d,p[i]) : nothing
        end
    end
    return d
end

# The return type depends on value of input. How to get around this ?
# There is no integer Inf.
# agrees with gap (except definition,use of inifinity is different)
function leastmoved(pin::PermList)
    p = pin.data
    lp = length(p)
    lm = lp+1
    for i in 1:lp
        k = p[i]
        k == i ? nothing :
           k < lm ? lm = k : nothing
    end
    return lm > lp ? Inf : lm
end

# agrees with gap
function greatestmoved(pin::PermList)
    p = pin.data
    lp = length(p)
    gm = 0
    for i in 1:lp
        k = p[i]
        k == i ? nothing :
           k > gm ? gm = k : nothing
    end
    return gm
end

function supportsize(pin::PermList)
    p = pin.data
    lp = length(p)
    count = 0
    for i in 1:lp
        k = p[i]
        k != i ? count += 1 : nothing
    end
    count
end

function support(pin::PermList)
    p = pin.data
    lp = length(p)
    mov = Array(eltype(p),0)
    for i in 1:lp
        k = p[i]
        k != i ? push!(mov,i) : nothing
    end
    return mov
end

function fixed(pin::PermList)
    p = pin.data
    lp = length(p)
    fixedel = Array(eltype(p),0)
    for i in 1:lp
        k = p[i]
        k == i ? push!(fixedel,i) : nothing
    end
    return fixedel
end

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
