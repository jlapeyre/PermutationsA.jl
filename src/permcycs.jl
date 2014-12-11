export list, flatten, support, fixed, cyclelengths
export print,arrprint, lineprint, show

import PermPlain: permsgn_from_lengths
import Base: print, show

immutable PermCycs{T<:Integer}
    data::Array{Array{T,1},1}
end

eltype{T}(c::PermCycs{T}) = T

## Construct PermCycs objects ##

# construct permutation from list of disjoint cycles
function permcycs(cycs...)
    length(cycs) == 0 && return PermCycs()
    pc = PermCycs(canoncycles([collect(typeof(cycs[1][1]),c) for c in cycs]))
    isperm(pc) || error("Trying to construct PermCycs from illegal or non-disjoint cycles.")
    return pc
end
PermCycs() = PermCycs(Array(Array{Int,1},0))
permcycs() = PermCycs()

## Copying, indexing, ... ##

copy(c::PermCycs) = PermCycs(copy(c.data))
length(c::PermCycs) = length(c.data)
getindex(c::PermCycs, k) = c.data[k]
setindex!(c::PermCycs, ci, k) = c.data[k] = ci

## Compare, test, and/or return properties ##

#ispermcycs(c::PermCycs) = ispermcycs(c.data) # probably not useful/wise
isperm(c::PermCycs) = PermPlain.isperm(c.data)
isid(c::PermCycs) = length(c) == 0
# commute()
# distance()
==(c1::PermCycs, c2::PermCycs) = c1.data == c2.data # c1 and c2 must be in canonical order
sign(c::PermCycs) = permsgn_from_lengths(cyclelengths(c))
order(c::PermCycs) = permorder(c.data)
cyclelengths(c::PermCycs) = [length(c1) for c1 in c.data]
cycletype(c::PermCycs) = cycletype(c.data)

## Apply permutation, and permutation operations ##
getindex(v::Array, c::PermCycs) = v[list(c).data]
getindex(v::String, c::PermCycs) = v[list(c).data] # How to define this for everything?

# Whether to return as-is or sort ?
# hmm, sort flag is overkill, since wrapping call in sort! is easy
function flatten(c::PermCycs; sort = false ) # a bit inefficient
    length(c) == 0 && return Array(eltype(c),0)
    outa = Array(eltype(c),0)
    for cyc in c.data
        append!(outa,cyc)
    end
    sort ? sort!(outa) : nothing
    return outa
end

# sort, to agree with PermList, and for fixed()
support(c::PermCycs) = flatten(c,sort=true)
supportsize(c::PermCycs) = sum([length(c1) for c1 in c.data])

# must be an idiomatic way to do this
# Not sure this is useful. fixed wrt what set ?
function fixed(c::PermCycs)
    outa = Array(eltype(c),0)
    mvd = support(c)
    ci = 1
    mi = mvd[ci]
    for i in 1:mvd[end]
        if i != mi
            push!(outa,i)
        elseif ci < length(mvd)
            ci += 1
            mi = mvd[ci]
        end
    end
    return outa
end

greatestmoved(cs::PermCycs) = maximum([ maximum(c) for c in cs.data ])
leastmoved(cs::PermCycs) = minimum([ minimum(c) for c in cs.data ])

## Output ##

function print(io::IO, c::PermCycs)
    print("(")
    for cyc in c.data cycleprint(io, cyc) end
    print(")")    
end

arrprint(io::IO, c::PermCycs) = arrprint(io,list(c))
arrprint(c::PermCycs) = arrprint(STDOUT,c)
lineprint(io::IO, c::PermCycs) = print(io,list(c))
lineprint(c::PermCycs) = lineprint(STDOUT,c)
show(io::IO, c::PermCycs) = print(io,c)