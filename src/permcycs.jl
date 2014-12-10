export list, flatten, support, fixed, cyclelengths
export print,arrprint, lineprint, show

import PermPlain: permsgn_from_lengths
import Base: print, show

immutable PermCycs
    data::Array{Array{Int,1},1}
end

## Construct PermCycs objects ##

# construct permutation from list of disjoint cycles
function permcycs(cycs...)
    length(cycs) == 0 && return PermCycs([])
    pc = PermCycs(canoncycles([collect(typeof(cycs[1][1]),c) for c in cycs]))
    isperm(pc) || error("Trying to construct PermCycs from illegal or non-disjoint cycles.")
    return pc
end

## Copying, indexing, ... ##

copy(c::PermCycs) = PermCycs(copy(c.data))
length(c::PermCycs) = length(c.data)
getindex(c::PermCycs, k) = c.data[k]
setindex!(c::PermCycs, ci, k) = c.data[k] = ci

## Compare, test, and/or return properties ##

#ispermcycs(c::PermCycs) = ispermcycs(c.data) # probably not useful/wise
isperm(c::PermCycs) = PermPlain.isperm(c.data)
isid(c::PermCycs) = length(c) == 0
==(c1::PermCycs, c2::PermCycs) = c1.data == c2.data # c1 and c2 must be in canonical order
sign(c::PermCycs) = permsgn_from_lengths(cyclelengths(c))
order(c::PermCycs) = permorder(c.data)
function cyclelengths(cin::PermCycs)
    c = cin.data
    return [ length(c1) for c1 in c]
end


## Apply permutation, and permutation operations ##
# ?? what is this worth ?
getindex(v::Array, c::PermCycs) = v[list(c).data]

# Whether to return as-is or sort ?
# hmm, sort flag is overkill, since wrapping call in sort! is easy
function flatten(c::PermCycs; sort = false ) # a bit inefficient
    d = c.data
    length(d) == 0 && return Array(Int,0)  # TODO: get type from d
    outa = Array(eltype(d[1]),0)
    for cyc in d
        append!(outa,cyc)
    end
    sort ? sort!(outa) : nothing
    return outa
end

# sort, to agree with PermList, and for fixed()
support(c::PermCycs) = flatten(c,sort=true)

function supportsize(c::PermCycs)
    d = c.data
    return sum([length(c1) for c1 in d])
end

# must be an idiomatic way to do this
# Not sure this is useful. fixed wrt what set ?
function fixed(c::PermCycs)
    d = c.data
    outa = Array(Int,0)  # TODO: get type
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
    d = c.data
    print("(")
    for cyc in d cycleprint(io, cyc) end
    print(")")    
end

arrprint(io::IO, c::PermCycs) = arrprint(io,list(c))
arrprint(c::PermCycs) = arrprint(STDOUT,c)
lineprint(io::IO, c::PermCycs) = print(io,list(c))
lineprint(c::PermCycs) = lineprint(STDOUT,c)
show(io::IO, c::PermCycs) = print(io,c)
