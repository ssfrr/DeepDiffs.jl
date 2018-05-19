@testset "Display tests" begin
    # Return a stream with color set as specified. On 0.6 this requires setting
    # a global flag, and the :color property in the IOContext has no effect.
    function setcolor(yn::Bool)
        if VERSION < v"0.7.0-DEV.3077"
            eval(Base, :(have_color = $yn))
        end
        IOContext(IOBuffer(), :color=>yn)
    end

    function resetcolor()
        global orig_color
        if VERSION < v"0.7.0-DEV.3077"
            eval(Base, :(have_color = $orig_color))
        end
        nothing
    end

    # check dictionary print output. This is a little complicated because
    # the ordering isn't specified. To work around this we just split
    # up both into lines and make sure they have the same lines in some ordering.
    # This means we could possibly miss some errors, but it seems like a
    # reasonable compomise
    # expected should be a list of display lines within that dict
    function checkdictprint(output, expected)
        outlines = sort(split(output, "\n"))
        explines = sort(split(expected, "\n"))
        @test outlines == explines
    end

    @testset "Array diffs print correctly" begin
        d1 = deepdiff([1, 2, 7, 3], [2, 3, 4, 1, 2, 3, 5])
        d2 = deepdiff([1], [2])

        buf = setcolor(true)
        expected1 = """
            [[32m2[39m[32m, [39m[32m3[39m[32m, [39m[32m4[39m[32m, [39m[0m1, [0m2, [31m7[39m[31m, [39m[0m3, [32m5[39m]"""
        expected2 = """[[31m1[39m[31m, [39m[32m2[39m]"""
        @testset "Color Diffs" begin
            display(TextDisplay(buf), d1)
            @test String(take!(buf.io)) == expected1
            display(TextDisplay(buf), d2)
            @test String(take!(buf.io)) == expected2
        end

        buf = setcolor(false)
        @testset "No-Color Diffs" begin
            display(TextDisplay(buf), d1)
            @test String(take!(buf.io)) == """
                [(+)2, (+)3, (+)4, 1, 2, (-)7, 3, (+)5]"""
            display(TextDisplay(buf), d2)
            @test String(take!(buf.io)) == """
                [(-)1, (+)2]"""
        end

        resetcolor()
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

        @testset "Color Diffs" begin
            buf = setcolor(true)
            display(TextDisplay(buf), d)
            expected = """
            Dict(
                 :a => "a",
                 :dict1 => Dict(
                     :c => 3,
                     :a => 1,
                     :b => 2,
                 ),
            [31m-    :c => "c",
            [39m     :list => [[0m1, [31m2[39m[31m, [39m[32m4[39m[32m, [39m[0m3],
                 :b => "[31mb[39m[32md[39m",
                 :dict2 => Dict(
                     :a => 1,
            [31m-        :b => 2,
            [39m[31m-        :c => 3,
            [39m[32m+        :c => 4,
            [39m[32m[39m     ),
            [32m+    :e => "e",
            [39m)"""
            # This test is broken because the specifics of how the ANSI color
            # codes are printed change based on the order, which changes with
            # different julia versions.
            @test_skip String(take!(buf.io)) == expected
        end
        @testset "No-Color Diffs" begin
            buf = setcolor(false)
            display(TextDisplay(buf), d)
            expected = """
            Dict(
                 :a => "a",
                 :dict1 => Dict(
                     :c => 3,
                     :a => 1,
                     :b => 2,
                 ),
            -    :c => "c",
                 :list => [1, (-)2, (+)4, 3],
                 :b => "{-b-}{+d+}",
                 :dict2 => Dict(
                     :a => 1,
            -        :b => 2,
            -        :c => 3,
            +        :c => 4,
                 ),
            +    :e => "e",
            )"""
            checkdictprint(String(take!(buf.io)), expected)
        end

        resetcolor()
    end

    @testset "single-line strings display correctly" begin
        # this test is just to handle some cases that don't get exercised elsewhere
        diff = deepdiff("abc", "adb")
        buf = setcolor(false)
        display(TextDisplay(buf), diff)
        @test String(take!(buf.io)) == "\"a{+d+}b{-c-}\""
        resetcolor()
    end

    @testset "Multi-line strings display correctly" begin
    s1 = """
        differences can
        be hard to find
        in
        multiline
        output"""
    s2 = """
        differences can
        be hurd to find
        multiline
        output"""
    diff = deepdiff(s1, s2)
    @testset "Color Display" begin
        buf = setcolor(true)
        expected = """
        \"\"\"
          differences can
        [31m- be hard to find[39m
        [31m- in[39m
        [32m+ be hurd to find[39m
          multiline
          output\"\"\""""
        display(TextDisplay(buf), diff)
        @test String(take!(buf.io)) == expected
    end
    @testset "No-Color Display" begin
        buf = setcolor(false)
        display(TextDisplay(buf), diff)
        @test String(take!(buf.io)) == """
        \"\"\"
          differences can
        - be hard to find
        - in
        + be hurd to find
          multiline
          output\"\"\""""
    end
    resetcolor()
    end
end
