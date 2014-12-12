export PermSparse
export randpermsparse, plength, supportsize

import Base: getindex, sign, length

immutable PermSparse{T<:Real} <: AbstractPerm{T}
    data::Dict{T}
    plen::T
end

PermSparse{T<:Real}(p::AbstractVector{T}) =  PermSparse(PermPlain.listtosparse(p)...)
PermSparse{T<:Real}(cycs::AbstractArray{Array{T,1},1}) = PermSparse(PermPlain.cycstosparse(cycs)...)

PermSparse(a::Tuple) = PermSparse(PermPlain.tupcollect(a))
PermSparse{T}(::Type{T}, a::Tuple) = PermSparse(PermPlain.tupcollect(T,a))
PermSparse() = PermSparse(Int[])

function getindex{T}(ps::PermSparse{T}, k::Real)
    res = get(ps.data,k,zero(T))
    res == zero(T) ? convert(T,k) : res    
#    res == zero(T) ? convert(Array{T,1},k) : res
end

map(ps::PermSparse, k::Real) = getindex(ps,k)

copy(p::PermSparse) = PermSparse(copy(p.data),p.plen)
setindex!(p::PermSparse, i::Int, k::Integer) = (p.data)[k] = i
length(ps::PermSparse) = ps.plen
plength(ps::PermSparse) = ps.plen
isperm(ps::PermSparse) = PermPlain.isperm(ps.data)
isid(ps::PermSparse) = length(ps.data) == 0

order(ps::PermSparse) = PermPlain.permorder(ps.data)
supportsize(ps::PermSparse) = length(ps.data)
support(ps::PermSparse) = collect(keys(ps.data))

sign(ps::PermSparse) = PermPlain.permsgn_from_lengths(PermPlain.cyclelengths(ps.data))

*(ps::PermSparse, k::Real) = ps[k]
*{T<:String}(p::PermSparse, v::T) = PermPlain.permapply(p.data,v)
*{T<:AbstractVector}(p::PermSparse, v::T) = PermPlain.permapply(p.data,v)
/(k::Real, p::PermSparse) = PermPlain.preimage(p.data,k)
\(p::PermSparse, k::Real) = k / p
*(p1::PermSparse, p2::PermSparse) = PermSparse(PermPlain.permcompose(p1.data,p2.data)...)
^(ps::PermSparse, n::Integer) = PermSparse(PermPlain.permpower(ps.data,n)...)
^(ps::PermSparse, n::FloatingPoint) = PermSparse(PermPlain.permpower(ps.data,n)...)
==(p1::PermSparse, p2::PermSparse) = p1.data == p2.data
