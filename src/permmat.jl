export PermMat
export randpermmat

import Base: kron

## object and constructors  ##

immutable PermMat{T<:Real} <: AbstractPerm{T}
    data::Vector{T}
end

length(p::PermMat) = (l=length(p.data); l * l)

# Single dimensional index means different things in different
# contexts. For matrix, it acts like a matrix.
function getindex(m::PermMat, k::Integer)
    i,j = divrem(k-1,plength(m))
    return m.data[j+1] == i+1 ? one(eltype(m)) : zero(eltype(m))
end

# should not be calling this, anyway
setindex!(m::PermMat, i::Int, k::Integer) = m.data[k] = i

# This is needed for eigvals()
similar(p::PermMat, T, dims...) = Array(T,dims...)
# Allows linear indexing, eg a[1:3]
similar(a::PermMat, dims::Dims) = Array(eltype(a), dims)

## operators ##

*{T}(p::PermMat, a::AbstractVector{T}) = PermPlain.permapply(p.data,a)
/(m1::PermMat, m2::PermMat) = PermMat(PermPlain.permcompose(m2.data,invperm(m1.data)))
*(m::PermMat, k::Integer) = full(m) * k

function +(p::PermMat, m::AbstractArray)
    size(p) == size(m) || error("dimensions must match")
    mout = copy(m)
    d = p.data
    mo = one(eltype(m))
    for i in 1:length(d)
        mout[i,d[i]] += mo
    end
    mout
end

function +(m::PermMat, p::PermMat)
    size(p) == size(m) || error("dimensions must match")
    dp = p.data
    dm = m.data
    mo = one(eltype(m))
    mout = full(m)
    for i in 1:length(dp)
        mout[i,dp[i]] += mo
    end
    mout
end

function +(m::AbstractArray, p::PermMat)
    size(p) == size(m) || error("dimensions must match")
    mout = copy(m)
    d = p.data
    mo = one(eltype(m))
    for i in 1:length(d)
        mout[i,d[i]] += mo
    end
    mout
end

function -(p::PermMat, m::AbstractArray)
    size(p) == size(m) || error("dimensions must match")
    mout = copy(m)
    d = p.data
    mo = one(eltype(m))
    for i in 1:length(d)
        j = d[i]
        mout[i,j] = -mout[i,j] + mo
    end
    mout
end

# output *is* a permutation
# This is *very* slow. Does not take advantage of data structure.
# The other AbstractPerm types can't use this because of the R[m].
# Copied from linalg/dense.jl
function kron{T,S}(a::PermMat{T}, b::PermMat{S})
    R = Array(promote_type(T,S), size(a,1)*size(b,1), size(a,2)*size(b,2))
    m = 1
    for j = 1:size(a,2), l = 1:size(b,2), i = 1:size(a,1)
        aij = a[i,j]
        for k = 1:size(b,1)
            R[m] = aij*b[k,l]
            m += 1
        end
    end
    R
end

# This a bit more efficient. Cuts out one loop
function kron{T,S}(a::PermMat{T}, b::AbstractMatrix{S})
    (nrowa, ncola) = size(a)
    (nrowb, ncolb) = size(a)
    R = zeros(promote_type(T,S), nrowa * nrowb, ncola * ncolb)
    d = inv(a).data  # prbly better to not break abstraction everywhere    
    for j = 1:ncola, l = 1:ncolb
        soff = ncola * (j-1)
        i = d[j]
        roff = ncola * (i-1)
        for k = 1:nrowb
            R[roff+k,soff+l] = b[k,l]
        end
    end
    R
end

# For testing. If there is a difference, it is small
function kron2{T,S}(a::PermMat{T}, b::AbstractMatrix{S})
    (nrowa, ncola) = size(a)
    (nrowb, ncolb) = size(a)
    R = zeros(promote_type(T,S), nrowa * nrowb, ncola * ncolb)
    d = a.data
    for j = 1:ncola, l = 1:ncolb
        soff = ncola * (j-1)
        i = d[j]
        roff = ncola * (i-1)
        for k = 1:nrowb
            R[soff+l,roff+k] = b[l,k]
        end
    end
    R
end

include("matlistcommon.jl")
