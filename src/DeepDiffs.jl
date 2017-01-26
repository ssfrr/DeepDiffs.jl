module DeepDiffs

export deepdiff, added, removed, changed, before, after

"""
diff = deepdiff(obj1, obj2)

deepdiff computes the structural difference between two objects and returns
a diff representing "edits" needed to transform obj1 into obj2. This diff
supports the `added`, `removed`, and `modified` functions that return `Set`s of
dictionary keys or array indices.
"""
function deepdiff end

abstract DeepDiff

# fallback diff that just stores two values
type SimpleDiff{T1, T2} <: DeepDiff
    before::T1
    after::T2
end

import Base: ==
==(lhs::SimpleDiff, rhs::SimpleDiff) = lhs.before == rhs.before && lhs.after == rhs.after

before(d::SimpleDiff) = d.before
after(d::SimpleDiff) = d.after

deepdiff(x, y) = SimpleDiff(x, y)

include("arrays.jl")
include("dicts.jl")
include("strings.jl")

end # module
