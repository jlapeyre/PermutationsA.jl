export PermMat
export randpermmat

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

include("matlistcommon.jl")
