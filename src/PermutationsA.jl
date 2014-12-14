using DataStructures: counter
module PermutationsA

export permlist, order, idpermlist, matrix, distance, permcycs, list
export cycles, cycletype, cyclelengths
export cprint, lprint, aprint, mprint
export pmap

using PermPlain
import Base: length, sign, copy, convert, sparse, full, similar
import Base: show,print,writemime

include("abstractperm.jl")
include("permlist.jl")
include("permcycs.jl")
include("permmat.jl")
include("permsparse.jl")
include("permallrep.jl")
end # module PermutationsA
