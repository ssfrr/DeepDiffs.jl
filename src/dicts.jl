type DictDiff{T1, KT1, T2, KT2} <: DeepDiff
    before::T1
    after::T2
    removed::Set{KT1}
    added::Set{KT2}
    changed::Set{KT1}
end

before(diff::DictDiff) = diff.before
after(diff::DictDiff) = diff.after
removed(diff::DictDiff) = diff.removed
added(diff::DictDiff) = diff.added
changed(diff::DictDiff) = diff.changed

function deepdiff(X::Associative, Y::Associative)
    xkeys = Set(keys(X))
    ykeys = Set(keys(Y))
    bothkeys = intersect(xkeys, ykeys)
    changedkeys = Set{eltype(bothkeys)}()

    removed = setdiff(xkeys, ykeys)
    added = setdiff(ykeys, xkeys)

    for key in bothkeys
        if X[key] != Y[key]
            push!(changedkeys, key)
        end
    end

    DictDiff(X, Y, removed, added, changedkeys)
end

function outputlines(obj)
    buf = IOBuffer()
    prettyprint(buf, obj)

    split(takebuf_string(buf))
end

function Base.show(io::IO, diff::DictDiff)
    # leftout = outputlines(before(diff))
    # rightout = outputlines(after(diff))
    #
    # leftwidth = maximum(map(length, leftout))
end

# function highlightprint(io, d::Dict, match, color)
#     # print sorted so things line up better when we print side-by-side
#     for k in sort(keys(d))
#         if k in match
#             print_with_color(color, io, )
# end

function diffprint(io, d::Dict, addedkeys, removedkeys, changedkeys, indent=0)
    println(typeof(d), "(")
    allkeys = [keys(d); addedkeys; removedkeys; changedkeys] |> unique |> sort
    for k in allkeys
        print("  " ^ (indent+1))
        show(k)
        print(" => ")
        prettyprint(io, d[k], indent+1)
        println()
    end
    print("  " ^ indent, ")")
end

# fallback for non-dicts
diffprint(io, x, addedkeys, removedkeys, changedkeys, indent=0) = show(io, x)
