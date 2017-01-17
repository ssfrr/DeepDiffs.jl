@testset "Display tests" begin
    @testset "Array diffs print correctly" begin
        d1 = deepdiff([1, 2, 7, 3], [2, 3, 4, 1, 2, 3, 5])
        d2 = deepdiff([1], [2])

        buf = IOBuffer()
        orig_color = Base.have_color
        eval(Base, :(have_color=true))
        display(TextDisplay(buf), d1)
        @test takebuf_string(buf) == """
            [[1m[32m2[0m[1m[32m, [0m[1m[32m3[0m[1m[32m, [0m[1m[32m4[0m[1m[32m, [0m[0m1[0m, [0m2[0m, [1m[31m7[0m[1m[31m, [0m[0m3[0m, [1m[32m5[0m]"""

        eval(Base, :(have_color=false))
        display(TextDisplay(buf), d1)
        @test takebuf_string(buf) == """
            [(+)2, (+)3, (+)4, 1, 2, (-)7, 3, (+)5]"""
        display(TextDisplay(buf), d2)
        @test takebuf_string(buf) == """
            [(-)1, (+)2]"""

        eval(Base, :(have_color=$orig_color))
    end

    @testset "Dict diffs print correctly" begin
        d = deepdiff(
            Dict(
                :a => "a",
                :b => "b",
                :c => "c",
                :list => [1, 2, 3],
                :dict1 => Dict(
                    :a => 1,
                    :b => 2,
                    :c => 3
                ),
                :dict2 => Dict(
                    :a => 1,
                    :b => 2,
                    :c => 3
                )
            ),
            Dict(
                :a => "a",
                :b => "d",
                :e => "e",
                :list => [1, 4, 3],
                :dict1 => Dict(
                    :a => 1,
                    :b => 2,
                    :c => 3
                ),
                :dict2 => Dict(
                    :a => 1,
                    :c => 4
                )
            ),
        )

        orig_color = Base.have_color
        eval(Base, :(have_color=true))
        buf = IOBuffer()
        display(TextDisplay(buf), d)
        @test takebuf_string(buf) == """
            Dict(
               :a => "a",
               :dict1 => Dict(
                 :c => 3,
                 :a => 1,
                 :b => 2,
               ),
            [1m[31m-  :c => "c",
            [0m   :list => [[0m1[0m, [1m[31m2[0m[1m[31m, [0m[1m[32m4[0m[1m[32m, [0m[0m3[0m],
            [1m[31m-  :b => "b",
            [1m[32m+  :b => "d",
            [0m   :dict2 => Dict(
                 :a => 1,
            [1m[31m-    :b => 2,
            [0m[1m[31m-    :c => 3,
            [1m[32m+    :c => 4,
            [0m[1m[32m[0m   ),
            [1m[32m+  :e => "e",
            [0m )"""
        eval(Base, :(have_color=false))
        display(TextDisplay(buf), d)
        @test takebuf_string(buf) == """
            Dict(
               :a => "a",
               :dict1 => Dict(
                 :c => 3,
                 :a => 1,
                 :b => 2,
               ),
            -  :c => "c",
               :list => [1, (-)2, (+)4, 3],
            -  :b => "b",
            +  :b => "d",
               :dict2 => Dict(
                 :a => 1,
            -    :b => 2,
            -    :c => 3,
            +    :c => 4,
               ),
            +  :e => "e",
             )"""
        eval(Base, :(have_color=$orig_color))
    end
end
