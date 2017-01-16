module DeepDiffs

export DeepDiff, deepdiff

"""
added, removed = deepdiff(obj1, obj2)

structdiff computes the structural difference between two objects and returns
a `Tuple` of "edits" needed to transform obj1 into obj2. The first item in the
tuple is the elements that need to be removed, the 2nd is those that need to be
added. The type of the elements depends on what the objects are. If they are
arrays, the edits will be array indices. If they are dicts it will be keys.
"""
function deepdiff end

# parametrized on object type and element type
type DeepDiff{T, ET}
    orig::Tuple{T, T} # tuple of original data structures
    removed::Vector{ET}
    added::Vector{ET}
end

DeepDiff(obj1, obj2) = DeepDiff((obj1, obj2), deepdiff(obj1, obj2)...)

include("arrays.jl")
include("dicts.jl")
include("display.jl")

end # module
