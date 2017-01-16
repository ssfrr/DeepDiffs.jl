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
    @test structdiff(d1, Dict(
        :foo => "foo",
        :bar => "biz",
        :baz => Dict(
            :fizz => "fizz",
            :buzz => "buzz"
        )
    )) == (Set([:bar]), Set([:bar]))

    # one removed
    @test structdiff(d1, Dict(
        :foo => "foo",
        :baz => Dict(
            :fizz => "fizz",
            :buzz => "buzz"
        )
    )) == (Set([:bar]), Set([]))

    # one added
    @test structdiff(d1, Dict(
        :foo => "foo",
        :bar => "bar",
        :biz => "biz",
        :baz => Dict(
            :fizz => "fizz",
            :buzz => "buzz"
        )
    )) == (Set([]), Set([:biz]))

    # inner dict modified
    @test structdiff(d1, Dict(
        :foo => "foo",
        :bar => "bar",
        :baz => Dict(
            :fizz => "fizz",
            :buzz => "bizzle"
        )
    )) == (Set([:baz]), Set([:baz]))

    # totally removed
    @test structdiff(d1, Dict()) == (Set([:foo, :bar, :baz]), Set([]))

    # totally added
    @test structdiff(Dict(), d1) == (Set([]), Set([:foo, :bar, :baz]))
end
