using DeepDiffs
using Compat
using Compat.Test

@testset "DeepDiff Tests" begin
    include("arrays.jl")
    include("dicts.jl")
    include("display.jl")
    include("simplediff.jl")
    include("strings.jl")
end
