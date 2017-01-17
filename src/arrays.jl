type VectorDiff{T1, T2} <: DeepDiff
    before::T1
    after::T2
    removed::Vector{Int}
    added::Vector{Int}
end

before(diff::VectorDiff) = diff.before
after(diff::VectorDiff) = diff.after
removed(diff::VectorDiff) = diff.removed
added(diff::VectorDiff) = diff.added
changed(diff::VectorDiff) = Int[]

# diffing an array is an application of the Longest Common Subsequence problem:
# https://en.wikipedia.org/wiki/Longest_common_subsequence_problem
function deepdiff(X::Vector, Y::Vector)
    # we're going to solve with dynamic programming, so let's first pre-allocate
    # our result array, which will store possible lengths of the common
    # substrings.

    lengths = zeros(Int, length(X)+1, length(Y)+1)

    for (j, v2) in enumerate(Y)
        for (i, v1) in enumerate(X)
            if v1 == v2
                lengths[i+1, j+1] = lengths[i, j] + 1
            else
                lengths[i+1, j+1] = max(lengths[i+1, j], lengths[i, j+1])
            end
        end
    end

    removed = Int[]
    added = Int[]
    backtrack(lengths, removed, added, X, Y, length(X), length(Y))

    VectorDiff(X, Y, removed, added)
end

# recursively trace back the longest common subsequence, adding items
# to the added and removed lists as we go
function backtrack(lengths, removed, added, X, Y, i, j)
    if i > 0 && j > 0 && X[i] == Y[j]
        backtrack(lengths, removed, added, X, Y, i-1, j-1)
    elseif j > 0 && (i == 0 || lengths[i+1, j] ≥ lengths[i, j+1])
        backtrack(lengths, removed, added, X, Y, i, j-1)
        push!(added, j)
    elseif i > 0 && (j == 0 || lengths[i+1, j] < lengths[i, j+1])
        backtrack(lengths, removed, added, X, Y, i-1, j)
        push!(removed, i)
    end
end

function Base.show(io::IO, diff::VectorDiff)
    from = before(diff)
    to = after(diff)
    rem = removed(diff)
    add = added(diff)

    ifrom = 1
    ito = 1
    iremoved = 1
    iadded = 1

    print(io, "[")
    while ifrom <= length(from) || ito <= length(to)
        if iremoved <= length(rem) && ifrom == rem[iremoved]
            printitem(io, from[ifrom], :red, "(-)")
            ifrom += 1
            iremoved += 1
            (ifrom <= length(from) || ito <= length(to)) && print_with_color(:red, io, ", ")
        elseif iadded <= length(add) && ito == add[iadded]
            printitem(io, to[ito], :green, "(+)")
            ito += 1
            iadded += 1
            (ifrom <= length(from) || ito <= length(to)) && print_with_color(:green, io, ", ")
        else
            # not removed or added, must be in both
            printitem(io, from[ifrom])
            ifrom += 1
            ito += 1
            (ifrom <= length(from) || ito <= length(to)) && print(io, ", ")
        end
    end
    print(io, "]")
end

function printitem(io, v, color=:normal, prefix="")
    if(Base.have_color)
        print_with_color(color, io, string(v))
    else
        print(io, prefix, v)
    end
end
