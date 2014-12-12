### methods using more than one object type representing permutations
export list, psparse
import Base: randperm

## Construct objects ##


#randperm{T<:PermMat}(::Type{T}, n::Real) = randpermmat(n)

randpermlist(n::Integer) = PermList(randperm(n))
randpermlist{T<:Real}(::Type{T}, n::Integer) = PermList(randperm(T,n))
randperm(::Type{PermList}, n::Real) = randpermlist(n)
randperm{T<:Real}(::Type{PermList{T}}, n::Real) = randpermlist(T,n)

randpermcycs(n::Integer) = cycles(randpermlist(n))
randpermcycs{T<:Real}(::Type{T}, n::Integer) = cycles(randpermlist(T,n))
randperm(::Type{PermCycs}, n::Real) = randpermcycs(n)
randperm{T<:Real}(::Type{PermCycs{T}}, n::Real) = randpermcycs(T,n)

randpermmat(n::Integer) = PermMat(randperm(n))
randpermmat{T<:Real}(::Type{T}, n::Integer) = PermMat(randpermlist(T,n))
randperm(::Type{PermMat}, n::Real) = randpermmat(n)
randperm{T<:Real}(::Type{PermMat{T}}, n::Real) = randpermmat(T,n)

randpermsparse(n::Integer) = PermSparse(randperm(n))
randpermsparse{T<:Real}(::Type{T}, n::Integer) = PermSparse(randpermlist(T,n).data)
randperm(::Type{PermSparse}, n::Real) = randpermsparse(n)
randperm{T<:Real}(::Type{PermSparse{T}}, n::Real) = randpermsparse(T,n)

#randperm{T<:PermCycs}(::Type{T}, n::Real) = randpermcycs(n)
#randperm{T<:PermSparse}(::Type{T}, n::Real) = randpermsparse(n)

## Compare, test, and/or return properties ##

# Don't know which to choose
==(p::PermList, c::PermCycs) = p == list(c)
==(c::PermCycs, p::PermList) = cycles(p) == c

==(p::PermList, m::PermMat) = p == list(m)
==(m::PermMat, p::PermList) = m == matrix(p)

==(p::PermList, sp::PermSparse) = p == list(sp)
==(sp::PermSparse, p::PermList) = sp == psparse(p)

==(c::PermCycs, m::PermMat) = c == cycles(m)
==(m::PermMat, c::PermCycs) = m == matrix(c)

==(c::PermCycs, sp::PermSparse) = c == cycles(sp)
==(sp::PermSparse, c::PermCycs) = psparse(c) == sp

distance(c1::PermCycs, c2::PermCycs) = distance(permlist(c1),permlist(c2)) # inefficient

## Apply permutation, and permutation operations ##

^(c::PermCycs, k::Integer) = PermCycs(PermPlain.canoncycles(PermPlain.permpower(c.data,k)))
ppow(c::PermCycs, k::Integer) = PermList(PermPlain.cyc_pow_perm(c.data,k))
*(c1::PermCycs, c2::PermCycs) = cycles(list(c1)*list(c2)) # inefficient
*(c::PermCycs, p::PermList) = list(c) * p # inefficient
*(p::PermList, c::PermCycs) = p * list(c)
*(p::PermList, m::PermMat) = p * list(m)
*(m::PermMat, p::PermList) = m * matrix(p)
*(m::PermMat, c::PermCycs) = m * matrix(c)
*(c::PermCycs, m::PermMat) = c * cycles(m)
*(p1::PermSparse, p2::PermList) = p1 * psparse(p2)
*(p1::PermList, p2::PermSparse) = p1 * list(p2)
*(p1::PermSparse, p2::PermMat) = p1 * psparse(p2)
*(p1::PermMat, p2::PermSparse) = p1 * matrix(p2)

## Convert to other representations ##

convert(::Type{PermCycs}, p::PermList) = cycles(p)
convert(::Type{PermList}, c::PermCycs) = list(c)
convert(::Type{PermList}, m::PermMat) = list(m)
convert(::Type{PermMat}, p::PermList) = matrix(p)
convert(::Type{PermMat}, c::PermCycs) = matrix(c)
permlist(c::PermCycs) = PermList(PermPlain.cycstoperm(c.data))
matrix(c::PermCycs) = matrix(permlist(c))  # inefficient
matrix(p::PermList) = PermMat(p.data)
matrix(sp::PermSparse) = PermMat(PermPlain.sparsetolist(sp.data))
matrix(m::PermMat) = m
cycles(p::PermList) = PermCycs(PermPlain.permcycles(p.data))
cycles(c::PermCycs) = c
cycles(m::PermMat) = cycles(list(m))
cycles(m::Array{Integer,2}) = cycles(list(m)) # inefficient
list(c::PermCycs, n=0) = PermList(PermPlain.cycstoperm(c.data,n))
list(p::PermList) = p  # not a copy !
list(m::PermMat) = PermList(m.data)
#list(m::Array{Integer,2}) = PermList(m * [1:size(m,1)]) why do this ?
list(sp::PermSparse) = PermList(PermPlain.sparsetolist(sp.data))
cycles(sp::PermSparse) = PermCycs(PermPlain.canoncycles(PermPlain.sparsetocycles(sp.data)))
psparse(p::PermList) = PermSparse(p.data)
psparse(c::PermCycs) = PermSparse(c.data)
psparse(m::PermMat) = PermSparse(m.data)

PermMat(p::PermList) = PermMat(p.data)
PermMat(c::PermCycs) = PermMat(list(c))

# This is needed to avoid trying to print PermList with showarray and failing in 1000 ways
writemime(io::IO, ::MIME"text/plain", p::PermSparse) = print(io,cycles(p))
