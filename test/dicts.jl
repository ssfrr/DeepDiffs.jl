@testset "Dicts can be diffed" begin
    d1 = Dict(
        :foo => "foo",
        :bar => "bar",
        :baz => Dict(
            :fizz => "fizz",
            :buzz => "buzz"
        )
    )

    @testset "One Changed" begin
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
        @test changed(d) == Dict{Symbol, DeepDiffs.DeepDiff}(:bar => deepdiff("bar", "biz"))
    end

    @testset "One Removed" begin
        d = deepdiff(d1, Dict(
            :foo => "foo",
            :baz => Dict(
                :fizz => "fizz",
                :buzz => "buzz"
            )
        ))
        @test added(d) == Set()
        @test removed(d) == Set([:bar])
        @test changed(d) == Dict()
    end

    @testset "One Added" begin
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
        @test changed(d) == Dict()
    end

    @testset "Inner Dict Modified" begin
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
        @test changed(d) == Dict{Symbol, DeepDiffs.DeepDiff}(:baz => deepdiff(
            Dict(
                :fizz => "fizz",
                :buzz => "buzz"
            ),
            Dict(
                :fizz => "fizz",
                :buzz => "bizzle"
            )
        ))
    end

    @testset "Totally Removed" begin
        d = deepdiff(d1, Dict())
        @test added(d) == Set()
        @test removed(d) == Set([:foo, :bar, :baz])
        @test changed(d) == Dict()
    end

    @testset "Totally added" begin
        d = deepdiff(Dict(), d1)
        @test added(d) == Set([:foo, :bar, :baz])
        @test removed(d) == Set()
        @test changed(d) == Dict()
    end
end
