m = PermMat([2, 1, 4, 5, 3])
m3 = m * 3
@test size(m3) == (5,5)
@test sum(m3) == 15

p = list(m)
@test p * 3 == 4
@test m * "cat" == p * "cat" == "act"
mf = full(m)
@test p * mf == m * mf

@test p[1] == 2
@test m[1] == 0

@test length(m) == 25
@test size(m) == (5,5)
# Can't do this with the other permutation types
@test repmat(m,3,4) == repmat(mf,3,4)
@test m + eye(Int,5) == mf + eye(Int,5)
v = [1,2,3,4,5]
@test broadcast(+,v,m) == broadcast(+,v,mf)
@test broadcast(-,v,m) == broadcast(-,v,mf)
@test m + m == mf + mf
e1 = [1,2,3]
@test m[e1] == Int[0,1,0]
@test m[1:3] == Int[0,1,0]
v1 = [.2,.3,.1,.7,.9]
@test m * v1 == mf * v1

@test length([i for i in m]) == 25
@test length([i for i in p]) == 5

# wikipedia example
p1 = PermList([1,4,2,5,3])
m1 = matrix(p1)
@test m1 * v == p1.data
@test full(m1) * v == p1.data
@test sparse(m1) * v == p1.data
