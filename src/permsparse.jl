export PermSparse
export randpermsparse, plength, supportsize

import Base: getindex, sign

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

map(ps::PermSparse, k::Real) = getindex(ps,k)

plength(ps::PermSparse) = ps.plen
supportsize(ps::PermSparse) = length(ps.data)
support(ps::PermSparse) = collect(keys(ps.data))
isid(ps::PermSparse) = length(ps.data) == 0

sign(ps::PermSparse) = PermPlain.permsgn_from_lengths(PermPlain.sparsecycleslengths(ps.data))

# this is backwards... uhoh
*(ps::PermSparse, k::Integer) = ps[k]
==(p1::PermSparse, p2::PermSparse) = p1.data == p2.data
