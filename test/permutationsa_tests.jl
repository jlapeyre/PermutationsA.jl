using Base.Test
#using DataStructures
using PermutationsA

# is this a good idea ?
@test permlist(1,2,3) == permlist([1,2,3])

n = 10
c  = PermList([8,2,10,4,6,9,7,3,5,1])
c1 = PermList([6,8,5,7,10,9,2,3,4,1])

import Base: length

for a in (PermList([10,1,3,6,9,8,4,5,7,2]),
          PermMat([10,1,3,6,9,8,4,5,7,2]),
          PermSparse([10,1,3,6,9,8,4,5,7,2]))
    @test isperm(a)
    @test plength(a) == n
    b = copy(a)
    @test isperm(b)
    @test a == b
    b[1] = b[1] + 1
    @test !( a == b )
    @test isperm(b) == false
    @test a * a == a^2
    @test a * a * a == a^3
    @test a * a * c == a^2 * c
    @test a^order(a) == one(a)
    @test a^(order(a)+1) == a
    @test a^-1 * a == one(PermList,n)
    @test isid(a^-1 * a)
    @test a^-1 == inv(a)
    @test matrix(a)^order(a) == eye(Int,n)
    @test isid( a * a')
    @test a * "abcdefghijk" == "jacfihdegbk"
    @test sparse(a) == a == full(a)
    @test full(a) == a == sparse(a)
    @test eye(a) != a
    @test a != eye(a)
    @test kron(a,a) == kron(full(a),full(a))
    @test cyclelengths(a) == cyclelengths(list(a))
end

@test (c * eye(Int,n)) * (c' * eye(Int,n)) == eye(Int,n)
@test c * eye(Int,n) == c
@test c * eye(Int,n) * c' == eye(Int,n)

@test sparse(PermList([3,5,6,1,2,4])) == sparse(PermSparse([3,5,6,1,2,4]))

for a in (PermList([7,9,4,1,3,2,8,6,10,5]), PermList([10,1,3,6,9,8,4,5,7,2]),
          PermSparse([10,1,3,6,9,8,4,5,7,2]))
    #  not true for matrix
    @test length(a) == n
    for i in 1:n
        @test a * i == a[i]
        @test (a * i) / a == i
        @test a \ (a * i) == i
        @test a * float(i) == a * i
        @test a * BigInt(i) == a * i
    end
end

@test distance(c1,c1) == 0
@test distance(c1,inv(c1)) == 10
@test c == c
@test !( c != c )
@test c != c1
@test ! ( c < c )
@test ! ( c > c )
@test c >= c
@test c <= c
@test c > c1
@test c1 < c
@test c >= c1
@test c1 <= c
@test c1 > one(c1)

@test one(PermList,n) == PermList([1:n])

# This is ok, but trans is broken in general
#@test sign(a) == (-1)^length(trans(a))
# TODO, get sign(c::PermCycs) efficiently

p = PermList([3,2,4,10,1,6,5,8,7,9])
q = PermList([3,8,4,9,7,6,1,10,5,2])
#P = matrix(p)
#Q = matrix(q)
#@test q * p == matrix(p*q)
@test p' == inv(p)
@test string(p) == "( 3  2  4  10 1  6  5  8  7  9  )"
@test string(PermCycs(((1, 6, 2, 7, 9),(3, 8, 4,10, 5)))) == "((16279)(384105))"

a = PermList([20,15,6,7,19,10,18,3,12,14,17,9,2,5,13,1,11,16,8,4])
a1 = permlist(20,15,6,7,19,10,18,3,12,14,17,9,2,5,13,1,11,16,8,4)
@test a == a1

ac = permcycs([1,20,4,7,18,16],[2,15,13],[3,6,10,14,5,19,8],[9,12],[11,17])
# Second method no longer works. Depends on version of Julia
ac1 = permcycs((1,20,4,7,18,16),(2,15,13),(3,6,10,14,5,19,8),(9,12),(11,17))
@test ac == ac1

@test cycles(a) == ac
@test a == permlist(ac)
@test cycles(permlist(ac)) == ac
@test permlist(cycles(a)) == a
@test ac == copy(ac)

@test collect(cycletype(a)) == collect(counter([7=>1,2=>2,3=>1,6=>1]))

# Constructing this way does not check validity.
@test isperm(PermCycs(collect(([1,2,3],[4,5,6])))) == true
@test isperm(PermCycs(collect(([1,2,3],[3,4,5])))) == false
@test isperm(PermCycs(collect(([1,2,3],[4,5,5])))) == false

# Constructing this way *does* check validity
@test isperm( permcycs( (1,2),(3,4) ) ) == true
@test isperm( permcycs( [1,2], [3,4] ) ) == true
@test_throws ErrorException permcycs( (1,2),(3,2) )

@test distance(PermList([1,2,3,4,5]),PermList([1,2,3,4,5])) == 0
@test distance(PermList([1,2,3,4,5]),PermList([1,2,3,4,5,6])) == 0
@test distance(PermList([1,2,3,4,5]),PermList([1,2,3,4,6,5])) == 2
@test distance(PermList([2,1,3,4,5,6,7,8,9,10]),PermList([1,2,3,4,5])) == 2

a = permcycs([1,5,2,3,4],[7,9,10,8])
@test isid(a^order(a))
@test typeof(a^order(a)) == PermCycs{Int}
@test isid(a^-1 * a)
@test isid(a * a^-1)
@test isid(a * list(a)^-1)
@test isid(list(a) * a^-1)
@test typeof(convert(PermList,a)) == PermList{Int}
@test typeof(convert(PermCycs,convert(PermList,a))) == PermCycs{Int}

for a in (permcycs([1,2,3,4],[7,10],[9,8]),permcycs([10,7], [1,2,3,4],[9,8]),
          permcycs([1,2,3,4],[7,10]))
    @test support(a) == support(list(a))
    @test fixed(a) == fixed(list(a))
    @test sign(a) == sign(list(a))
    @test cyclelengths(a) == cyclelengths(list(a))
    @test greatestmoved(a) == greatestmoved(list(a))
    @test leastmoved(a) == leastmoved(list(a))
    @test a == cycles(list(a))
    @test supportsize(a) == length(support(a))
    @test supportsize(list(a)) == length(support(a))
    @test isid( a * a')
end

# canonical ordering
@test permcycs([1,2,3,4],[7,10],[9,8]) == permcycs([10,7], [1,2,3,4],[9,8])

# empty permutations
@test permcycs() == PermCycs()
@test list(permcycs()) == permlist()

@test list(permcycs([1,3],[6,4])) == PermList([3,2,1,6,5,4])
@test list(permcycs([1,3],[6,4]),10) == PermList([3,2,1,6,5,4,7,8,9,10])
@test list(permcycs(),5) == PermList([1,2,3,4,5])

v = ["cat","dog","zebra"]
@test v[PermList([1,3,2])] ==  v[cycles(PermList([1,3,2]))]

for c1 in ( permcycs((1,2), (3,4), (5,7,9,11)), permcycs((12,1,8), (3,4), (5,7,9,11)) )
    @test c1 == psparse(c1)
    @test c1 == list(c1)
    @test c1 == matrix(c1)
    @test det(c1) == sign(c1)
    @test rank(c1) == rank(full(c1))
    @test full(c1) == sparse(c1)
    @test sign(psparse(c1)) == sign(list(c1)) == sign(c1)
    @test plength(psparse(c1)) == plength(list(c1)) == plength(c1)
    @test null(psparse(c1)) == null(list(c1)) == null(c1) == null(full(c1))
    @test trace(psparse(c1)) == trace(list(c1)) == trace(c1) == trace(full(c1)) == trace(sparse(c1))
end

@test typeof(randperm(PermList,n)) == PermList{Int}
@test typeof(randperm(PermCycs,n)) == PermCycs{Int}
@test typeof(randperm(PermSparse,n)) == PermSparse{Int}
@test typeof(randperm(PermMat,n)) == PermMat{Int}

@test typeof(randperm(PermList{BigInt},n)) == PermList{BigInt}
@test typeof(randperm(PermCycs{BigInt},n)) == PermCycs{BigInt}
@test typeof(randperm(PermSparse{BigInt},n)) == PermSparse{BigInt}
@test typeof(randperm(PermMat{BigInt},n)) == PermMat{BigInt}
@test list(c1) * 7 == psparse(c1) * 7

@test (PermSparse( ( (1,2,3), (4,5) )) ; true )
@test (PermSparse(Int32, ( (1,2,3), (4,5) )) ; true )
@test (PermSparse(BigInt, ( (1,2,3), (4,5) )) ; true )
@test (PermCycs( ( (1,2,3), (4,5) )) ; true )
@test (PermCycs(Int32, ( (1,2,3), (4,5) )) ; true )
@test (PermCycs(BigInt, ( (1,2,3), (4,5) )) ; true )

@test PermSparse() == PermCycs() == PermList()
@test PermList([1:10]) == PermList([1:20])
