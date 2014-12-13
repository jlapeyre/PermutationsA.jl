export PermCycs
export randpermcycs

immutable PermCycs{T<:Real} <: AbstractPerm{T}
    data::Array{Array{T,1},1}
end

## Construct PermCycs objects ##

# construct permutation from list of disjoint cycles
function permcycs(T::Type, cycs...)
    length(cycs) == 0 && return PermCycs()
    pc = PermCycs(PermPlain.canoncycles([collect(T,c) for c in cycs]))
    isperm(pc) || error("Trying to construct PermCycs from illegal or non-disjoint cycles.")
    return pc
end

PermCycs(a::Tuple) = PermCycs(PermPlain.tupcollect(a))
PermCycs{T}(::Type{T}, a::Tuple) = PermCycs(PermPlain.tupcollect(T,a))

function permcycs(cycs...)
    length(cycs) == 0 && return PermCycs()
    permcycs(typeof(cycs[1][1]),cycs...)
end

PermCycs() = PermCycs(Array(Array{Int,1},0))
#PermCycs{T}(::Type{T}) = PermCycs(Array(Array{T,1},0))
permcycs() = PermCycs()
idpermcyc() = PermCycs()
idpermcyc{T}(::Type{T}) = PermCycs(T)
idperm{T}(c::PermCycs{T}) = PermCycs(T)
plength(c::PermCycs) = greatestmoved(c)

## Copying, indexing, ... ##

copy(c::PermCycs) = PermCycs(copy(c.data))
length(c::PermCycs) = length(c.data)
getindex(c::PermCycs, k::Real) = c.data[k]
setindex!(c::PermCycs, ci::Real, k::Real) = c.data[k] = ci

## Compare, test, and/or return properties ##

#ispermcycs(c::PermCycs) = ispermcycs(c.data) # probably not useful/wise
isperm(c::PermCycs) = PermPlain.isperm(c.data)
isid(c::PermCycs) = length(c) == 0
# commute()
# distance()
==(c1::PermCycs, c2::PermCycs) = c1.data == c2.data # c1 and c2 must be in canonical order
sign(c::PermCycs) = PermPlain.permsgn(c.data)
order(c::PermCycs) = PermPlain.permorder(c.data)
cyclelengths(c::PermCycs) = PermPlain.cyclelengths(c.data)
cycletype(c::PermCycs) = PermPlain.cycletype(c.data)

## Apply permutation, and permutation operations ##
getindex{T}(v::Array{T,1},c::PermCycs{Bool}) = error("Silence compiler. You don't want Bool, anyway")
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
    print(io,"(")
    for cyc in c.data PermPlain.cycleprint(io, cyc) end
    print(io,")")    
end

show(io::IO, c::PermCycs) = print(io,c)
# This is needed to avoid trying to print PermList with showarray and failing in 1000 ways
writemime(io::IO, ::MIME"text/plain", p::PermCycs) = print(io,p)
