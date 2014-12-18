c = one(PermCycs)
p = one(PermList)
s = one(PermSparse)
m = one(PermMat)

@test null(c) == null(p) == null(s)

for el in ( :c, :p, :s, :m)
    @eval begin
        @test isid($el)
        @test issym($el)
        @test isposdef($el)
        @test iseven($el)
    end
end

##

p = PermList([3,1,2])
c = cycles(p)
s = psparse(p)
m = matrix(p)

for el in ( :c, :p, :s, :m)
    @eval begin
        @test ! isid($el)
        @test ! issym($el)
        @test ! isposdef($el)
        @test inv($el) == transpose($el)
        @test rank($el) == plength($el)
        @test det($el) == sign($el)
        @test iseven($el)
    end
end

p = PermList([2,7,8,3,1,9,6,4,5,10])
@test pivtopermlist(topiv(p)) == p

q = PermList([5,6,9,1,4,7,8,3,2,10])
q1 = pivtopermlist([5,6,9,5,5,7,8,9,9,10])
@test q1 == q

