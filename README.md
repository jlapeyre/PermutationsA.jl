# PermutationsA

[![Build Status](https://travis-ci.org/jlapeyre/PermutationsA.jl.svg?branch=master)](https://travis-ci.org/jlapeyre/PermutationsA.jl)

Data types and methods for permutations

### Overview

This module implements representations of permutations: list, disjoint
cycles, and matrix, and sparse (not ```SparseMatrix```). The name is
```PermuationsA``` to distinguish it from the module
```Permutations```. This module wraps generic routines in the module
```PermPlain```.

The Julia manual says the " ```AbstractArray``` type includes
everything vaguely array-like". Permutations are at least vaguely
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

The 

### AbstractPerm

Every finite permutation can be represented (mathematically) as a
matrix.  The ```AbstractPerm``` type implements a some of the
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
those of ```PermList``` (via code-generation) and perhaps these should be










<!--  LocalWords:  PermutationsA PermuationsA PermPlain julia PermCyc
 -->
<!--  LocalWords:  AbstractPerm AbstractMatrix PermList PermMat
 -->
<!--  LocalWords:  PermSparse
 -->
