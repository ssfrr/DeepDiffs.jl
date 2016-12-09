@testset "Array diffs print correctly" begin
    d = StructureDiff([1, 2, 7, 3], [2, 3, 4, 1, 2, 3, 5])
    buf = IOBuffer()
    display(TextDisplay(buf), d)
    @test takebuf_string(buf) == """
        [1, 2, [1m[31m7[0m, 3]
        [[1m[32m2[0m, [1m[32m3[0m, [1m[32m4[0m, 1, 2, 3, [1m[32m5[0m]
        """
end
