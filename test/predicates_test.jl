@test iscyclic(permcycs((1,2,3)))
@test iscyclic(permcycs((42,100,3)))
@test !iscyclic(permcycs((1,2), (3,4)))
