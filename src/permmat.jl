export PermMat

#export randpermmat, order, sign, commute, idpermmat

import Base: full, getindex, size, similar, copy, eltype, ctranspose,
             transpose

# Several methods are defined in permallrep.jl, which is loaded after
# all permutation representation objects have been defined.

## object and constructors  ##

immutable PermMat{T<:Real} <: AbstractMatrix{T}
    p::Vector{T}
end

isperm(m::PermMat) = isperm(m.p)
randpermmat(n::Integer) = PermMat(randperm(n))
# idpermmat(n::Integer) = PermMat([1:n])
# idpermmat(T::DataType, n::Integer) = PermMat([one(T):convert(T,n)])
# idperm{T}(m::PermMat{T}) = PermMat([one(T):convert(T,length(m.p))])
# one(m::PermMat) = idperm(m)

## size, copy, indexing ##

getindex{T}(m::PermMat{T}, i::Integer, j::Integer) =  m.p[i] == j ? one(T) : zero(T)

function getindex{T}(m::PermMat{T}, k::Integer)
    i,j = divrem(k-1,length(m.p))
    return m.p[i+1] == j+1 ? one(T) : zero(T)
end     

size{T}(m::PermMat{T}) = (s = length(m.p); (s,s))
copy(m::PermMat) = PermMat(copy(m.p))
similar(m::PermMat, atype, dims) = Array(atype, dims)
eltype{T}(m::PermMat{T}) = T

# dense matrix
full(m::PermMat) = [m[i,j] for i=1:size(m,1), j=1:size(m,2)]

## operators ##

^(m::PermMat, n::Integer) = PermMat(permpower(m.p,n))
==(m1::PermMat, m2::PermMat) = permlistisequal(m1.p,m2.p)
<(m1::PermMat, m2::PermMat) = ltpermlist(m1.p,m2.p)
>(m1::PermMat, m2::PermMat) = ltpermlist(m2.p,m1.p)
inv(m::PermMat) = PermMat(invperm(m.p))
*(m::PermMat, v::String) = v[m.p]
*(m1::PermMat, m2::PermMat) = PermMat(permcompose(m1.p,m2.p))
/(m1::PermMat, m2::PermMat) = PermMat(permcompose(m1.p,invperm(m2.p)))
*(m::PermMat, k::Integer) = k > length(m.p) ? k : m.p[k]
/(k::Integer, m::PermMat) = PermPlain.preimage(m.p,k)
\(m::PermMat, k::Int) = k / m
#*(m::PermMat, v::Vector) = v[m.p]
*{T}(m::PermMat, a::AbstractVector{T}) = [ m * i for i in a]
ctranspose(m::PermMat) = inv(m)
transpose(m::PermMat) = inv(m)

# Wikipedia says that if M_i represents p_i, then
# M_1 * M_2  <---> p_2 ∘ p_1
# We should check and follow this convention.
function *(m1::PermMat, m2::Matrix)
    p = m1.p
    n = length(p)
    om = similar(m2)
    for j in 1:n
        for i in 1:n
            om[i,j] = m2[i,p[j]]
        end
    end
    return om
end

function *(m2::Matrix, m1::PermMat)
    p = m1.p
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
                (:isid, :isid))
    @eval begin
        ($f1)(m::PermMat) = (PermPlain.$f2)(m.p)
    end
end

for (f1,f2) in ((:commute, :permcommute) , (:distance, :permdistance),
                (:same, :same), (:leastmoved, :leastmoved),
                (:greatestmoved,:greatestmoved), (:supportsize, :supportsize),
                (:support,:support), (:fixed,:fixed))
    @eval begin
        ($f1)(m1::PermMat, m2::PermMat) = ($f2)(m1.p,m2.p)
    end
end
