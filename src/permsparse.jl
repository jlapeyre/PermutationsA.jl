export PermSparse
export randpermsparse, plength

import Base: getindex

immutable PermSparse{T<:Real} <: AbstractPerm{T}
    data::Dict{T}
    plen::T
end

PermSparse{T<:Real}(p::AbstractVector{T}) =  PermSparse(PermPlain.listtosparse(p)...)
PermSparse{T<:Real}(cycs::AbstractArray{Array{T,1},1}) = PermSparse(PermPlain.cycstosparse(cycs)...)

function getindex{T}(ps::PermSparse{T}, k::Real)
    res = get(ps.data,k,zero(T))
    res == zero(T) ? convert(T,k) : res
end

map(ps::PermSparse, k::Real) = getindex(ps)

randpermsparse(n::Integer) = PermSparse(randperm(n))

plength(ps::PermSparse) = ps.plen

*(ps::PermSparse, k::Integer) = ps[k]
