# used for single-line strings
type StringDiff{T1, T2} <: DeepDiff
    before::T1
    after::T2
    diff::VectorDiff
end

# used for multi-line strings
type StringLineDiff{T1, T2} <: DeepDiff
    before::T1
    after::T2
    diff::VectorDiff
end

function deepdiff(X::AbstractString, Y::AbstractString)
    if contains(X, "\n") || contains(Y, "\n")
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

function =={T<:AllStringDiffs}(d1::T, d2::T)
    d1.before == d2.before || return false
    d1.after == d2.after || return false
    d1.diff == d2.diff || return false

    true
end

function Base.show(io::IO, diff::StringLineDiff)
    xlines = split(diff.before, '\n')
    ylines = split(diff.after, '\n')
    println(io, "\"\"\"")
    visitall(diff.diff) do idx, state, last
        if state == :removed
            print_with_color(:red, io, "- ", escape_string(xlines[idx]))
        elseif state == :added
            print_with_color(:green, io, "+ ", escape_string(ylines[idx]))
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
        if !Base.have_color
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
            print_with_color(:red, io, string(xchars[idx]))
        elseif state == :added
            print_with_color(:green, io, string(ychars[idx]))
        else
            print(io, xchars[idx])
        end
        laststate = state
    end
    if !Base.have_color
        if laststate == :removed
            print(io, "-}")
        elseif laststate == :added
            print(io, "+}")
        end
    end
    print(io, "\"")
end
