# PermutationsA

[![Build Status](https://travis-ci.org/jlapeyre/PermutationsA.jl.svg?branch=master)](https://travis-ci.org/jlapeyre/PermutationsA.jl)

Data types and methods for permutations

### Overview

This module implements representations of permutations: list, disjoint
cycles, and matrix, and sparse. The name is `PermuationsA` to
distinguish it from the module `Permutations`. This module wraps
generic routines in the module `PermPlain`.

There is an abstract permutation type.

```julia
     AbstractPerm{T} <: AbstractMatrix{T}
```
The remaining types differ in how they store the data representing the permutation

*  ```PermList``` is an ```Array{T,1}``` corresponding to the one-line form
*  ```PermCyc``` is an ```Array{Array{T,1},}``` corresponding to disjoint-cycle form
*  ```PermMat``` is a ```Matrix``` that stores the data in one-line form ```Array{T,1}```
*  ```PermSparse``` is a ```Dict``` which can be thought of as one-line form with fixed points ommitted

The interface is experimental, it will be pruned at least. In fact
this is an exercise in progress. Currently, there is not a clear
choice between using `[]` and operators to denote matrix or
permutation operations.

PermMat and PermList are very similar. One should be removed, or
code should be factored.
