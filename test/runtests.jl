using DeepDiffs
using Compat
using Compat.Test

if isdefined(Base, :have_color)
    # Capture the original state of the global flag
    orig_color = Base.have_color
end

@testset "DeepDiff Tests" begin
    include("arrays.jl")
    include("dicts.jl")
    include("display.jl")
    include("simplediff.jl")
    include("strings.jl")
end
