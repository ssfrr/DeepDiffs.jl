@testset "Array diffs print correctly" begin
    d = deepdiff([1, 2, 7, 3], [2, 3, 4, 1, 2, 3, 5])
    buf = IOBuffer()
    orig_color = Base.have_color
    eval(Base, :(have_color=true))
    display(TextDisplay(buf), d)
    @test takebuf_string(buf) == """
        [[1m[32m2[0m[1m[32m, [0m[1m[32m3[0m[1m[32m, [0m[1m[32m4[0m[1m[32m, [0m[0m1[0m, [0m2[0m, [1m[31m7[0m[1m[31m, [0m[0m3[0m, [1m[32m5[0m]
        """

    eval(Base, :(have_color=false))
    display(TextDisplay(buf), d)
    @test takebuf_string(buf) == """
        [(+)2, (+)3, (+)4, 1, 2, (-)7, 3, (+)5]
        """

    eval(Base, :(have_color=$orig_color))
end
