module PermutationsA

export permlist, order, idpermlist, matrix, distance, permcycs
export cycles, cycletype, cyclelengths

using PermPlain
import Base: length, sign, copy, convert, sparse, full
import Base: show,print,writemime

include("abstractperm.jl")
include("permlist.jl")
include("permcycs.jl")
include("permmat.jl")
include("permsparse.jl")
include("permallrep.jl")
end # module PermutationsA
