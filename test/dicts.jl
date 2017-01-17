@testset "Dicts can be diffed" begin
    d1 = Dict(
        :foo => "foo",
        :bar => "bar",
        :baz => Dict(
            :fizz => "fizz",
            :buzz => "buzz"
        )
    )

    # one changed
    d = deepdiff(d1, Dict(
        :foo => "foo",
        :bar => "biz",
        :baz => Dict(
            :fizz => "fizz",
            :buzz => "buzz"
        )
    ))
    @test added(d) == Set()
    @test removed(d) == Set()
    @test changed(d) == Set([:bar])

    # one removed
    d = deepdiff(d1, Dict(
        :foo => "foo",
        :baz => Dict(
            :fizz => "fizz",
            :buzz => "buzz"
        )
    ))
    @test added(d) == Set()
    @test removed(d) == Set([:bar])
    @test changed(d) == Set()

    # one added
    d = deepdiff(d1, Dict(
        :foo => "foo",
        :bar => "bar",
        :biz => "biz",
        :baz => Dict(
            :fizz => "fizz",
            :buzz => "buzz"
        )
    ))
    @test added(d) == Set([:biz])
    @test removed(d) == Set()
    @test changed(d) == Set()

    # inner dict modified
    d = deepdiff(d1, Dict(
        :foo => "foo",
        :bar => "bar",
        :baz => Dict(
            :fizz => "fizz",
            :buzz => "bizzle"
        )
    ))
    @test added(d) == Set()
    @test removed(d) == Set()
    @test changed(d) == Set([:baz])

    # totally removed
    d = deepdiff(d1, Dict())
    @test added(d) == Set()
    @test removed(d) == Set([:foo, :bar, :baz])
    @test changed(d) == Set()

    # totally added
    d = deepdiff(Dict(), d1)
    @test added(d) == Set([:foo, :bar, :baz])
    @test removed(d) == Set()
    @test changed(d) == Set()
end
