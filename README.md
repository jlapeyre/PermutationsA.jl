# PermutationsA

[![Build Status](https://travis-ci.org/jlapeyre/PermutationsA.jl.svg?branch=master)](https://travis-ci.org/jlapeyre/PermutationsA.jl)

Data types and methods for permutations

## Overview

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

*  ```PermList``` an ```Array{T,1}``` corresponding to the one-line form
*  ```PermCyc```  an ```Array{Array{T,1},}``` corresponding to disjoint-cycle form
*  ```PermMat``` acts like a matrix. stores data in one-line form ```Array{T,1}```
*  ```PermSparse``` is a ```Dict``` which can be thought of as one-line form with fixed points omitted

These types differ both in how they store the data representing the
permutation, and in their interaction with other types.

This package is not meant to create a type hierarchy faithfully
reproducing mathematical structures.  It is also meant to be more than
an exercise in learning Julia.  Some choices follow those made by
other languages that have had implementations of permutations for many
years.  One goal of the package is efficiency. The objects are
lightweight; there is little copying and validation, although
```copy``` and ```isperm``` methods are provided. For instance this

```julia
 M = rand(10,10)        
 v = randperm(10)
 kron(PermMat(v),M)
 ```
performs a Kronecker product taking advantage of the structure of a permutation matrix.
```PermMat(v)``` only captures a pointer to ```v```. No copying or construction of
a matrix, apart from the output (dense) matrix, is done.

The Kronecker product of two permutations is a permutation. With
dense matrices, this would crash your computer,

```julia
julia> q = randpermmat(1000);
julia> @time size(kron(q,q))
elapsed time: 0.008285471 seconds (8000208 bytes allocated)
(1000000,1000000)
```

## Object types

### AbstractPerm

Every finite permutation can be represented (mathematically) as a
matrix.  The ```AbstractPerm``` type implements  some of the
properties of permutation matrices that are independent of the way the
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
possible like a ```Matrix```. The majority of the methods are identical to
those of ```PermList```.

### PermList

```PermList``` behaves more like a permutation than a matrix when there
is no conflict with role as a permutation.
But note this difference between ```PermList``` and ```PermMat```

```julia
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

julia> @time p^100000;    # Operate on big list. Julia is really fast, anyway
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

## Usage

Construction

```julia
PermList([10,1,3,6,9,8,4,5,7,2])    # construct from one-line form
PermMat([10,1,3,6,9,8,4,5,7,2])
PermSparse([10,1,3,6,9,8,4,5,7,2])
PermCycs(((1, 6, 2, 7, 9),(3, 8, 4,10, 5)))  # construct from tuples representing cycles
```

The identity permutation,

```julia
PermList() == PermMat() == PermCycs() == PermSparse() == 
 one(PermList) == one(PermMat) == one(PermCycs) == one(PermSparse)
true

isid(one(PermList))
true
```

plength  gives the largest number not mapped to itself. Zero
means that all numbers are mapped to themselves.

```julia
0 == plength(PermMat()) == plength(PermList()) ==
 plength(PermCycs()) == plength(PermSparse())
true 
```

For ```PermCycs``` and ```PermSparse``` there is only one
representation of the identity.
For ```PermList``` and ```PermMat``` there are many representations
of the identity.
```julia
julia> one(PermList,10)
( 1  2  3  4  5  6  7  8  9  10 )

one(PermList) == one(PermList,10) == one(PermMat,20) == one(PermCycs)
true
```

The domain of each permutation is all positive integers.
```julia
julia> p = randpermlist(10)
( 10 7  4  2  1  8  3  5  6  9  )

julia> p * 3
4

julia> p * 100
100

julia> psparse(p) * 100  # sparse(p) means SparseMatrix
100

julia> 4 == p * 3 == psparse(p) * 3 == cycles(p) * 3  # These are all the same
true
```

```PermMat``` is different

```julia
julia> size(PermMat(p) * 100)   # Not same, not application of the permutation
(10,10)

julia> pmap(PermMat(p),100)  # Same for all permutation types
100

julia> p[1]     # also application of permutation
10

julia> show(matrix(p)[1:10])  # first column of the matrix
[0,0,0,0,1,0,0,0,0,0]
```

## Sundry

Use ```list```, ```cycles```, ```psparse```, and ```matrix``` to convert from
one type to another.

Use ```full(p)``` and ```sparse(p)``` to get dense and sparse matrices
from any permutation type.

aprint,cprint,lprint,mprint,astring,cstring,lstring,mstring: Print or make
strings of any type in various forms.

```* ^``` : composition and power, using various algorithms.

randpermlist, randpermcycs, randpermmat, randpermsparse,
```randperm(type,n)``` : generate random permutations

Permutation types support element type parameters,
```julia
julia> typeof(PermList(Int32[3,2,1]))
PermList{Int32} (constructor with 1 method)
```

For other features, see the test and source files.
