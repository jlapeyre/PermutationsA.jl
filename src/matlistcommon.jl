# These types should probably be subclasses of an abstract type

for (ptype, lcptype) in  ( (:PermMat, :permmat ) , (:PermList, :permlist))
    if ptype == :stopsym
        continue
    end

    @eval begin
        
        ## Construct $ptype objects ##

        $ptype() = $ptype(Int[])
        $ptype{T<:Real}(m::AbstractArray{T,2}) = $ptype(PermPlain.mattoperm(m))
        
        $lcptype(plist...) = $ptype(collect(plist))
        $lcptype{T<:Integer}(a::Vector{T}) = $ptype(a)
        $lcptype() = $ptype(Array(Int,0))
        
        ## Copying, indexing, ... ##
        
        copy(p::$ptype) = $ptype(copy(p.data))
        similar(m::$ptype) = $ptype(Array(eltype(m),length(m.data)))
        similar(m::$ptype, a::Int, b::Int) = Array(eltype(m),a,b)
        similar{T}(m::$ptype, ::Type{T}, a::Int, b::Int) = Array(T,a,b)
#        similar{T,V}(m::$ptype{V}, ::Type{T}, a::Int, b::Int) = Array(T,a,b)        
        similar{T<:Real}(::Type{$ptype}, ::Type{T}, a::Int, b::Int) = Array(T,a,b)        
        plength(p::$ptype) = length(p.data)

        one(::Type{$ptype}) = $ptype()
        one{T}(::Type{$ptype{T}}) = $ptype(T)
        one{T}(::Type{$ptype{T}}, n::Integer) = $ptype(T[one(1):convert(T,n)])
        one(::Type{$ptype}, n::Integer) = one($ptype{Int},n)
        one{T}(p::$ptype{T}) = one($ptype{T},plength(p))
        one(p::$ptype) = one($ptype{Int},plength(p))
        zero(p::$ptype) = zeros(eltype(p),size(p)) # can't be a permutation
        
        inv(p::$ptype) = $ptype(invperm(p.data))
        pmap(m::$ptype, k::Real) = k > length(m.data) ? convert(eltype(m),k) : (m.data)[k]
        compose!(p::$ptype, q::$ptype) = PermPlain.permcompose!(p.data,q.data)
        *(p::$ptype, q::$ptype) = $ptype(PermPlain.permcompose(p.data,q.data))
        
        function *(m1::$ptype, m2::AbstractMatrix)
            p = m1.data
            n = length(p)
            om = zeros(m2)
            for j in 1:n
                for i in 1:n
                    om[j,i] = m2[i,p[j]]
                end
            end
            return om
        end

        # can't make m2 abstract, because I get method collisions.
        # sol'n depends on whose special matrix routine should be applied.
        function *(m2::Matrix, m1::$ptype)
            p = m1.data
            n = length(p)
            om = zeros(m2)
            for j in 1:n
                for i in 1:n
                    om[i,j] = m2[p[i],j]
                end
            end
            return om
        end
        
        ^(m::$ptype, n::Integer) = $ptype(PermPlain.permpower(m.data,n))
        pow2(p::$ptype, k::Real) = $ptype(PermPlain.cyc_pow_perm(cycles(p).data,k))
        ==(m1::$ptype, m2::$ptype) = PermPlain.permlistisequal(m1.data,m2.data)
        <(m1::$ptype, m2::$ptype) = PermPlain.ltpermlist(m1.data,m2.data)
        <=(m1::$ptype, m2::$ptype) = PermPlain.lepermlist(m1.data,m2.data)
        >(m1::$ptype, m2::$ptype) = PermPlain.ltpermlist(m2.data,m1.data)
        *{T<:String}(p::$ptype, v::T) = PermPlain.permapply(p.data,v)
        kron{T,S}(a::$ptype{T}, b::$ptype{S}) = $ptype(PermPlain.permkron(a.data,b.data))
        kron{T,S}(a::$ptype{T}, b::AbstractMatrix{S}) = PermPlain.permkron(a.data,b)
        
        # How to use keyword arguments?
        function aprint(io::IO, p::$ptype)
            PermPlain.permarrprint(io,p.data)
            println(io)
            PermPlain.permarrprint(io,[1:length(p.data)])
        end
        aprint(p::$ptype) = aprint(STDOUT,p)
        print(io::IO, p::$ptype) = PermPlain.permarrprint(io,p.data)
        lprint(io::IO, p::$ptype) = print(io,p)
        lprint(p::$ptype) = lprint(STDOUT,p)
        
    end
    
        
    for f in (:cyclelengths, :cycletype, :isid, :leastmoved, :isperm,
              :greatestmoved, :supportsize, :support, :fixed )
        @eval begin
            ($f)(m::$ptype) = (PermPlain.$f)(m.data)
        end
    end
    for (f1,f2) in ((:order, :permorder) , (:sign, :permsgn),
                    (:cyclelengths, :cyclelengths), (:cycletype, :cycletype),
                    (:isid, :isid), (:leastmoved, :leastmoved), (:isperm, :isperm),
                    (:greatestmoved,:greatestmoved), (:supportsize, :supportsize),
                    (:support,:support), (:fixed,:fixed))
        @eval begin
            ($f1)(m::$ptype) = (PermPlain.$f2)(m.data)
        end
    end
    for (f1,f2) in ((:commute, :permcommute) , (:distance, :permdistance),
                    (:same, :same))
        @eval begin
            ($f1)(m1::$ptype, m2::$ptype) = (PermPlain.$f2)(m1.data,m2.data)
        end
    end
end
