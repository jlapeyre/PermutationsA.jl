# PermutationsA

[![Build Status](https://travis-ci.org/jlapeyre/PermutationsA.jl.svg?branch=master)](https://travis-ci.org/jlapeyre/PermutationsA.jl)

Data types and methods for permutations

### Overview

This module implements representations of permutations: list, disjoint
cycles, and matrix, and sparse (not ```SparseMatrix```). The name is
```PermuationsA``` to distinguish it from the module
```Permutations```. This module wraps generic routines in the module
```PermPlain``` .

The Julia manual says the ```AbstractArray``` type includes
everything "vaguely array-like". Permutations are at least vaguely
array-like. This package defines

```julia
     AbstractPerm{T} <: AbstractMatrix{T}
```

and concrete subtypes:

*  ```PermList``` is an ```Array{T,1}``` corresponding to the one-line form
*  ```PermCyc``` is an ```Array{Array{T,1},}``` corresponding to disjoint-cycle form
*  ```PermMat``` is a ```Matrix``` that stores the data in one-line form ```Array{T,1}```
*  ```PermSparse``` is a ```Dict``` which can be thought of as one-line form with fixed points omitted

These types differ both in how they store the data representing the
permutation, and in their interaction with other types.

One goal of the package is efficiency. The objects are lightweight; there
is little copying and validation, although ```copy``` and ```isperm``` methods
are provided. For instance this

```julia
 M = rand(10,10)        
 v = randperm(10)
 kron(PermMat(v),M)
 ```
performs a kronecker product taking advantage of the structure of a permutation matrix.
```Permat(v)``` only captures a pointer to ```v```. No copying or construction of
a matrix, except for the output matrix, is done.

### AbstractPerm

Every finite permutation can be represented (mathematically) as a
matrix.  The ```AbstractPerm``` type implements  some of the
properites of permutation matrices that are independent of the way the
data is stored in the concrete types. The following methods are
defined in ```AbtractPerm``` and behave as they would on the
```Matrix``` type: det, logdet, rank, trace, ishermitian, issym,
istriu, istril, isposdef, null, getindex(i,j), transpose, ctranspose,
inv, one, size, eltype. The methods full and sparse which return
```Matrix``` and ```SparseMatrix``` objects are also implemented here.
To support all these methods, some stubs are present in place of low-level
methods that must be implemented by the concrete types.

### PermMat

This type stores data in one-line form, but is meant to behave as much as
possible like a ```Matrix```.  The method 'length' returns 

The majority of the methods are identical to
those of ```PermList```.

### PermList

```PermList``` behaves more like a permutation than a matrix when there
is no conflict with role as a permutation.
But note this difference between ```PermList``` and ```PermMat```

julia> p = randpermlist(3)
( 3 1 2 )

julia> p * 3    # p maps 3 to 2
2

julia> m = matrix(p)  # capture the pointer to the data in p, nothing else.
3x3 PermMat{Int64}:   # But the display is different.
 0  0  1
 1  0  0
 0  1  0


julia> m * 3          # PermMat behaves like a matrix whenever possible.
3x3 Array{Int64,2}:
 0  0  3
 3  0  0
 0  3  0

julia> M = rand(3,3); kron(m,M) == kron(p,M) # kron can't be interpreted another way for a permutation
true
```

### PermCyc

```julia
julia> c = permcycs( (1,10^5), (2,3) )   # defined by list of disjoint cycles
((1 100000)(2 3))

julia> p = list(c); length(p.data)   # convert to PermList. The data is a big array.
100000

julia> @time c^100000;        # Take advantage of cycle structure (easy in this case)
elapsed time: 2.3248e-5 seconds (320 bytes allocated)

julia> @time p^100000;    # Operate on big list. Julia is really fast anyway
elapsed time: 0.01122444 seconds (1600192 bytes allocated)
```

### PermSparse

```julia
julia> s  = psparse(c)             # convert to PermSparse. Displays as disjoint cycles
((1 100000)(2 3))

julia> s.data
Dict{Int64,Int64} with 4 entries:  # stored efficiently
  2      => 3
  3      => 2
  100000 => 1
  1      => 100000

julia> sparse(s)                   # convert to sparse matrix; not the same thing
100000x100000 sparse matrix with 100000 Int64 entries:
        [100000,      1]  =  1
        [3     ,      2]  =  1
        [2     ,      3]  =  1
            ...
```            

<!--  LocalWords:  PermutationsA PermuationsA PermPlain julia PermCyc
 -->
<!--  LocalWords:  AbstractPerm AbstractMatrix PermList PermMat
 -->
<!--  LocalWords:  PermSparse
 -->
