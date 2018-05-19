# used for single-line strings
struct StringDiff{T1, T2} <: DeepDiff
    before::T1
    after::T2
    diff::VectorDiff
end

# used for multi-line strings
struct StringLineDiff{T1, T2} <: DeepDiff
    before::T1
    after::T2
    diff::VectorDiff
end

function deepdiff(X::AbstractString, Y::AbstractString)
    if occursin("\n", X) || occursin("\n", Y)
        # we'll compare hashes of each line rather than the text itself, because
        # these comparisons are done many times
        xhashes = map(hash, split(X, '\n'))
        yhashes = map(hash, split(Y, '\n'))

        StringLineDiff(X, Y, deepdiff(xhashes, yhashes))
    else
        StringDiff(X, Y, deepdiff(collect(X), collect(Y)))
    end
end

const AllStringDiffs = Union{StringDiff, StringLineDiff}

before(diff::AllStringDiffs) = diff.before
after(diff::AllStringDiffs) = diff.after
added(diff::AllStringDiffs) = added(diff.diff)
removed(diff::AllStringDiffs) = removed(diff.diff)
changed(diff::AllStringDiffs) = []

Base.:(==)(d1::T, d2::T) where {T<:AllStringDiffs} = fieldequal(d1, d2)

function Base.show(io::IO, diff::StringLineDiff)
    xlines = split(diff.before, '\n')
    ylines = split(diff.after, '\n')
    println(io, "\"\"\"")
    visitall(diff.diff) do idx, state, last
        if state == :removed
            printstyled(io, "- ", escape_string(xlines[idx]), color=:red)
        elseif state == :added
            printstyled(io, "+ ", escape_string(ylines[idx]), color=:green)
        else
            print(io, "  ", escape_string(xlines[idx]))
        end
        if last
            print(io, "\"\"\"")
        else
            println(io)
        end
    end
end

function Base.show(io::IO, diff::StringDiff)
    xchars = before(diff.diff)
    ychars = after(diff.diff)
    laststate = :init

    print(io, "\"")
    visitall(diff.diff) do idx, state, last
        if !hascolor(io)
            # check to see if we need to close a block
            if laststate == :removed && state != :removed
                print(io, "-}")
            elseif laststate == :added && state != :added
                print(io, "+}")
            end
            # check to see if we need to open a block
            if laststate != :removed && state == :removed
                print(io, "{-")
            elseif laststate != :added && state == :added
                print(io, "{+")
            end
        end
        if state == :removed
            printstyled(io, string(xchars[idx]), color=:red)
        elseif state == :added
            printstyled(io, string(ychars[idx]), color=:green)
        else
            print(io, xchars[idx])
        end
        laststate = state
    end
    if !hascolor(io)
        if laststate == :removed
            print(io, "-}")
        elseif laststate == :added
            print(io, "+}")
        end
    end
    print(io, "\"")
end
