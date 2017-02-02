@testset "SimpleDiff tests" begin
    @test deepdiff(1, 2) == deepdiff(1, 2)
end
