@testset "Single-line Strings can be diffed" begin
    @testset "bπiz -> bπaz" begin
        s1 = "bπiz"
        s2 = "bπaz"
        diff = deepdiff(s1, s2)
        @test before(diff) == s1
        @test after(diff) == s2
        # the indices are assuming a Vector of chars, like you'd get from `collect`
        @test removed(diff) == [3]
        @test added(diff) == [3]
        @test changed(diff) == []
    end
end

@testset "Multi-line Strings can be diffed" begin
    s1 = """differences can
           be hard to find
           in
           multiline
           output"""
    s2 = """differences can
           be hurd to find
           multiline
           output"""
    diff = deepdiff(s1, s2)
    @test before(diff) == s1
    @test after(diff) == s2
    @test removed(diff) == [2, 3]
    @test added(diff) == [2]
    @test changed(diff) == []
end
