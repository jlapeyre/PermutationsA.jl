export PermMat

export randpermmat, idpermmat
#, order, sign, commute, idpermmat

import Base: full, sparse, getindex, size, similar, copy, eltype, ctranspose,
      transpose, one, trace, det, logdet, rank, ishermitian,
      istriu, istril, isposdef, issym, null, setindex!

# Several methods are defined in permallrep.jl, which is loaded after
# all permutation representation objects have been defined.

## object and constructors  ##

immutable PermMat{T<:Real} <: AbstractPerm{T}
    data::Vector{T}
end

PermMat() = PermMat(Int[])

isperm(m::PermMat) = isperm(m.data)
idpermmat(n::Integer) = PermMat([1:n])
idpermmat(T::DataType, n::Integer) = PermMat([one(T):convert(T,n)])

idperm{T}(m::PermMat{T}) = PermMat([one(T):convert(T,length(m.data))])
one(m::PermMat) = idperm(m)

plength(m::PermMat) = length(m.data)

## size, copy, indexing ##

#getindex{T}(m::PermMat{T}, i::Integer, j::Integer) =  m.data[j] == i ? one(T) : zero(T)

# Single dimensional index means different things in different
# contexts. We need to choose one meaning
function getindex{T}(m::PermMat{T}, k::Integer)
    i,j = divrem(k-1,plength(m))
    return m.data[j+1] == i+1 ? one(T) : zero(T)
end
#getindex{T}(m::PermMat{T}, k::Integer) = k > length(m.data) ? convert(T,k) : (m.data)[k]

setindex!(m::PermMat, i::Int, k::Integer) = m.data[k] = i

map(m::PermMat, k::Real) = k > length(m.data) ? convert(T,k) : (m.data)[k]

copy(m::PermMat) = PermMat(copy(m.data))
similar(m::PermMat, atype, dims) = Array(atype, dims)
eltype{T}(m::PermMat{T}) = T

# dense matrix
full(m::PermMat) = [m[i,j] for i=1:size(m,1), j=1:size(m,2)]

# sparse matrix
function sparse{T}(m::PermMat{T})
    n = plength(m)
    I = [1:n]
    J = (m.data)[I]
    V = ones(T,n)
    sparse(J,I,V)
end

## operators ##

^(m::PermMat, n::Integer) = PermMat(PermPlain.permpower(m.data,n))
==(m1::PermMat, m2::PermMat) = PermPlain.permlistisequal(m1.data,m2.data)
<(m1::PermMat, m2::PermMat) = PermPlain.ltpermlist(m1.data,m2.data)
>(m1::PermMat, m2::PermMat) = PermPlain.ltpermlist(m2.data,m1.data)
inv(m::PermMat) = PermMat(invperm(m.data))
*(m::PermMat, v::String) = v[m.data]
*(m1::PermMat, m2::PermMat) = PermMat(PermPlain.permcompose(m2.data,m1.data))
/(m1::PermMat, m2::PermMat) = PermMat(PermPlain.permcompose(m2.data,invperm(m1.data)))
*(m::PermMat, k::Integer) = k > plength(m) ? k : m.data[k]
/(k::Integer, m::PermMat) = PermPlain.preimage(m.data,k)
\(m::PermMat, k::Int) = k / m
#*(m::PermMat, v::Vector) = v[m.data]
*{T}(m::PermMat, a::AbstractVector{T}) = [ m * i for i in a]

function ==(pm::PermMat, m::AbstractMatrix)
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
function ==(m::AbstractMatrix, pm::PermMat)
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
function *(m1::PermMat, m2::AbstractMatrix)
    p = m1.data
    n = length(p)
    om = similar(m2)
    for j in 1:n
        for i in 1:n
            om[i,j] = m2[i,p[j]]
        end
    end
    return om
end

# can't make m2 abstract, because I get method collisions.
# sol'n depends on whose special matrix routine should be applied.
function *(m2::Matrix, m1::PermMat)
    p = m1.data
    n = length(p)
    om = similar(m2)
    for j in 1:n
        for i in 1:n
            om[i,j] = m2[p[i],j]
        end
    end
    return om
end

## tests and properties

for (f1,f2) in ((:order, :permorder) , (:sign, :permsgn),
                (:cyclelengths, :cyclelengths), (:cycletype, :cycletype),
                (:isid, :isid), (:leastmoved, :leastmoved),
                (:greatestmoved,:greatestmoved), (:supportsize, :supportsize),
                (:support,:support), (:fixed,:fixed))
    @eval begin
        ($f1)(m::PermMat) = (PermPlain.$f2)(m.data)
    end
end

for (f1,f2) in ((:commute, :permcommute) , (:distance, :permdistance),
                (:same, :same))
    @eval begin
        ($f1)(m1::PermMat, m2::PermMat) = (PermPlain.$f2)(m1.data,m2.data)
    end
end

trace(m::PermMat) = plength(m) - PermPlain.supportsize(m.data)
det(m::PermMat) = permsgn(m.data) # much faster than default 'det'
logdet(m::PermMat) = det(m) > 0 ? 0 : error("DomainError: determinant is -1")
rank(m::PermMat) = plength(m)
ishermitian(m::PermMat) = isid(m)
issym(m::PermMat) = isid(m)
istriu(m::PermMat) = isid(m)
istril(m::PermMat) = isid(m)
isposdef(m::PermMat) = isid(m)
null{T}(m::PermMat{T}) = zeros(Float64,plength(m),0) # for consistency

#null{T}(m::PermMat{T}) = zeros(T,plength(m),0)
