using DeepDiffs
using Base.Test
using TestSetExtensions
using Compat

@testset DottedTestSet "DeepDiff Tests" begin
    @includetests ARGS
end
