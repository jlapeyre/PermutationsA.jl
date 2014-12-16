# Bug in sparsetocycles fixed in commit
# b03248da3d9f106682e7ecc8b057cfc119fa2613
# in PermPlain
p = PermList([9,8,7,6,5,4,3,2,1])
@test cycles(psparse(cycles(p))) == cycles(p)

# another sparsetocycles bug
p = PermList([3,2,7,9,8,4,1,6,5])
q = PermList([1,4,3,5,9,7,2,8,6])
sp = psparse(p)
sq = psparse(q)
sprod = sp * sq

@test isperm(sprod)
#cycles(sprod)


