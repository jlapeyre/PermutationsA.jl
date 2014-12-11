### methods using more than one object type representing permutations

export list

## Construct objects ##

randpermcycs{T<:Integer}(n::T) = cycles(randpermlist(n))

## Compare, test, and/or return properties ##

# Don't know which to choose
==(p::PermList, c::PermCycs) = p == list(c)
==(c::PermCycs, p::PermList) = cycles(p) == c
distance(c1::PermCycs, c2::PermCycs) = distance(permlist(c1),permlist(c2)) # inefficient

## Apply permutation, and permutation operations ##

^(c::PermCycs, k::Integer) = PermCycs(canoncycles(permpower(c.data,k)))
ppow(c::PermCycs, k::Integer) = PermList(cyc_pow_perm(c.data,k))
*(c1::PermCycs, c2::PermCycs) = cycles(list(c1)*list(c2)) # inefficient
*(c::PermCycs, p::PermList) = list(c)*p # inefficient
*(p::PermList, c::PermCycs) = p*list(c) # inefficient

## Convert to other representations ##

convert(::Type{PermCycs}, p::PermList) = cycles(p)
convert(::Type{PermList}, c::PermCycs) = list(c)
matrix(c::PermCycs) = matrix(permlist(c))  # inefficient
matrix(p::PermList) = permtomat(p.data)
permlist(c::PermCycs) = PermList(cycstoperm(c.data))
cycles(p::PermList) = PermCycs(permcycles(p.data))
cycles(c::PermCycs) = c
cycles(m::Array{Integer,2}) = cycles(list(m)) # inefficient
list(c::PermCycs, n=0) = PermList(cycstoperm(c.data,n))
list(p::PermList) = p  # not a copy !
list(m::Array{Integer,2}) = PermList(m * [1:size(m,1)])
