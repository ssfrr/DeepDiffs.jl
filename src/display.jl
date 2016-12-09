function Base.show{T<:Array, ET}(io::IO, diff::StructureDiff{T, ET})
    from = diff.orig[1]
    to = diff.orig[2]

    ifrom = 1
    iremoved = 1
    print(io, "[")
    while ifrom < length(from)
        printitem(io, :red, from, ifrom, diff.removed, iremoved) && (iremoved += 1)
        print(io, ", ")
        ifrom += 1
    end
    printitem(io, :red, from, ifrom, diff.removed, iremoved) && (iremoved += 1)
    println(io, "]")

    ito = 1
    iadded = 1
    print(io, "[")
    while ito < length(to)
        printitem(io, :green, to, ito, diff.added, iadded) && (iadded += 1)
        print(io, ", ")
        ito += 1
    end
    printitem(io, :green, to, ito, diff.added, iadded) && (iadded += 1)
    println(io, "]")
end

# returns true if the item matched
function printitem(io, color, data, dataidx, match, matchidx)
    if matchidx > length(match) || dataidx != match[matchidx]
        print(io, data[dataidx])
        false
    else
        print_with_color(color, io, string(data[dataidx]))
        true
    end
end
