export PermSparse
export randpermsparse

import Base: getindex

immutable PermSparse{T<:Real} <: AbstractPerm{T}
    data::Dict{T}
end

PermSparse{T<:Real}(p::AbstractVector{T}) =  PermSparse(PermPlain.listtosparse(p))
PermSparse{T<:Real}(cycs::AbstractArray{Array{T,1},1}) = PermSparse(PermPlain.cycstosparse(cycs))

function getindex{T}(ps::PermSparse{T}, k::Real)
    res = get(ps.data,k,zero(T))
    res == zero(T) ? convert(T,k) : res
end

map(ps::PermSparse, k::Real) = getindex(ps)

randpermsparse(n::Integer) = PermSparse(randperm(n))

*(ps::PermSparse, k::Integer) = ps[k]

# This is needed to avoid trying to print PermList with showarray and failing in 1000 ways
writemime(io::IO, ::MIME"text/plain", p::PermSparse) = print(io,p)
