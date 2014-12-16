# Bug in sparsetocycles fixed in commit
# b03248da3d9f106682e7ecc8b057cfc119fa2613
# in PermPlain
p = PermList([9,8,7,6,5,4,3,2,1])
@test cycles(psparse(cycles(p))) == cycles(p)
