module DeepDiffs

using Compat

export deepdiff, added, removed, changed, before, after
export SimpleDiff, VectorDiff, StringDiff, DictDiff

# Helper function for comparing two instances of a type for equality by field
function fieldequal(x::T, y::T) where T
    for f in fieldnames(T)
        getfield(x, f) == getfield(y, f) || return false
    end
    true
end

# Determine whether color is supported by the given stream
@static if VERSION >= v"0.7.0-DEV.3077"
    hascolor(io::IO) = get(IOContext(io), :color, false)
else
    hascolor(io::IO) = Base.have_color
end

"""
diff = deepdiff(obj1, obj2)

deepdiff computes the structural difference between two objects and returns
a diff representing "edits" needed to transform obj1 into obj2. This diff
supports the `added`, `removed`, and `modified` functions that return `Set`s of
dictionary keys or array indices.
"""
function deepdiff end

abstract type DeepDiff end

# fallback diff that just stores two values
struct SimpleDiff{T1, T2} <: DeepDiff
    before::T1
    after::T2
end

Base.:(==)(lhs::SimpleDiff, rhs::SimpleDiff) = fieldequal(lhs, rhs)

before(d::SimpleDiff) = d.before
after(d::SimpleDiff) = d.after

deepdiff(x, y) = SimpleDiff(x, y)

include("arrays.jl")
include("dicts.jl")
include("strings.jl")

end # module
