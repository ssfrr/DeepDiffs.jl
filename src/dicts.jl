function structdiff(X::Dict, Y::Dict)
    xkeys = Set(keys(X))
    ykeys = Set(keys(Y))

    removed = setdiff(xkeys, ykeys)
    added = setdiff(ykeys, xkeys)

    for key in intersect(xkeys, ykeys)
        if X[key] != Y[key]
            # the value changed, so add to both the removed and added lists
            push!(removed, key)
            push!(added, key)
        end
    end

    # TODO: not sure whether we want to return a Vector or a Set
    (removed, added)
end

function outputlines(obj)
    buf = IOBuffer()
    prettyprint(buf, obj)

    split(takebuf_string(buf))
end

function Base.show{T<:Dict, ET}(io::IO, diff::StructureDiff{T, ET})
    leftout = outputlines(diff.orig[1])
    rightout = outputlines(diff.orig[2])

    leftwidth = maximum(map(length, leftout))
end

# function highlightprint(io, d::Dict, match, color)
#     # print sorted so things line up better when we print side-by-side
#     for k in sort(keys(d))
#         if k in match
#             print_with_color(color, io, )
# end

function prettyprint(io, d::Dict, indent=0)
    println(typeof(d), "(")
    for k in keys(d)
        print("  " ^ (indent+1))
        show(k)
        print(" => ")
        prettyprint(io, d[k], indent+1)
        println()
    end
    print("  " ^ indent, ")")
end

prettyprint(io, x, indent=0) = show(io, x)
