@testset "arrays can be diffed" begin
    a1 = [1, 2, 3, 4]

    # one number changed
    a2 = [1, 7, 3, 4]
    d = deepdiff(a1, a2)
    @test added(d) == [2]
    @test removed(d) == [2]
    @test changed(d) == []
    @test before(d) == a1
    @test after(d) == a2

    # removed from middle
    d = deepdiff(a1, [1, 3, 4])
    @test removed(d) == [2]
    @test added(d) == []

    # removed from beginning
    d = deepdiff(a1, [2, 3, 4])
    @test removed(d) == [1]
    @test added(d) == []

    # removed from end
    d = deepdiff(a1, [1, 2, 3])
    @test removed(d) == [4]
    @test added(d) == []

    # added to end
    d = deepdiff(a1, [1, 2, 3, 4, 5])
    @test removed(d) == []
    @test added(d) == [5]

    # added to beginning
    d = deepdiff(a1, [0, 1, 2, 3, 4])
    @test removed(d) == []
    @test added(d) == [1]

    # two additions
    d = deepdiff(a1, [1, 4, 2, 5, 3, 4])
    @test removed(d) == []
    @test added(d) == [2, 4]

    # two removals
    d = deepdiff(a1, [2, 4])
    @test removed(d) == [1, 3]
    @test added(d) == []
end
