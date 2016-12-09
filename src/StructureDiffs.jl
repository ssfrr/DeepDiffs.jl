module StructureDiffs

export StructureDiff, structdiff

"""
added, removed = structdiff(obj1, obj2)

structdiff computes the structural difference between two objects and returns
a `Tuple` of "edits" needed to transform obj1 into obj2. The first item in the
tuple is the elements that need to be removed, the 2nd is those that need to be
added. The type of the elements depends on what the objects are. If they are
arrays, the edits will be array indices. If they are dicts it will be keys.
"""
function structdiff end

type StructureDiff
    orig # tuple of original data structures
    added
    removed
end

StructureDiff(obj1, obj2) = StructureDiff((obj1, obj2), sdiff(obj1, obj2)...)

include("arrays.jl")

end # module
