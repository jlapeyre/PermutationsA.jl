module PermutationsA

include("abstractperm.jl")

export getindex,setindex!,cycles,cyclelengths,sign,order,
       cycletype,div2,trans,randpermlist,permlist,matrix,
       permcycs, copy, idpermlist, isid, inv,
       distance, same, convert,ppow, list

using PermPlain

export randpermcycs

import Base: length, sign, copy, convert, sparse, full

include("permlist.jl")
include("permcycs.jl")
include("permmat.jl")
include("permsparse.jl")
include("permallrep.jl")
end # module PermutationsA

# TODO:
# see pari/gp as well
# implement iterators, for mapping, etc.
