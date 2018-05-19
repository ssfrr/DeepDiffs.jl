struct DictDiff{T1, KT1, T2, KT2} <: DeepDiff
    before::T1
    after::T2
    removed::Set{KT1}
    added::Set{KT2}
    changed::Dict{KT1, DeepDiff}
    unchanged::Set{KT1}
end

before(diff::DictDiff) = diff.before
after(diff::DictDiff) = diff.after
removed(diff::DictDiff) = diff.removed
added(diff::DictDiff) = diff.added
changed(diff::DictDiff) = diff.changed

Base.:(==)(lhs::DictDiff, rhs::DictDiff) = fieldequal(lhs, rhs)

function deepdiff(X::AbstractDict, Y::AbstractDict)
    xkeys = Set(keys(X))
    ykeys = Set(keys(Y))
    bothkeys = intersect(xkeys, ykeys)

    removed = setdiff(xkeys, ykeys)
    added = setdiff(ykeys, xkeys)
    unchanged = Set{eltype(bothkeys)}()
    changed = Dict{eltype(bothkeys), DeepDiff}()

    for key in bothkeys
        if X[key] != Y[key]
            changed[key] = deepdiff(X[key], Y[key])
        else
            push!(unchanged, key)
        end
    end

    DictDiff(X, Y, removed, added, changed, unchanged)
end

Base.show(io::IO, diff::DictDiff) = diffprint(io, diff, 0)

# indentation space
const inspace = "    "

function diffprint(io, d::DictDiff, indent=0)
    bef = before(d)
    aft = after(d)

    println(io, "Dict(")
    for k in d.unchanged
        # extra space to account for added linemarker
        print(io, " ", inspace ^ (indent+1))
        prettyprint(io, Pair(k, bef[k]), " ", indent+1)
        println(io, ",")
    end
    Base.with_output_color(:red, io) do io
        for k in removed(d)
            print(io, "-", inspace ^ (indent+1))
            prettyprint(io, Pair(k, bef[k]), "-", indent+1)
            println(io, ",")
        end
    end
    for (k, v) in changed(d)
        if isa(v, SimpleDiff)
            # if we have a key pointing to a SimpleDiff, then we don't know how to
            # deconstruct the value, so instead we print it like a removed and added key
            Base.with_output_color(:red, io) do io
                print(io, "-", inspace ^ (indent+1))
                prettyprint(io, Pair(k, before(v)), "-", indent+1)
                println(io, ",")
            end
            Base.with_output_color(:green, io) do io
                print(io, "+", inspace ^ (indent+1))
                prettyprint(io, Pair(k, after(v)), "+", indent+1)
                println(io, ",")
            end
        else
            # extra space to account for added linemarker
            print(io, " ", inspace ^ (indent+1))
            prettyprint(io, Pair(k, v), " ", indent+1)
            println(io, ",")
        end
    end
    Base.with_output_color(:green, io) do io
        for k in added(d)
            print(io, "+", inspace ^ (indent+1))
            prettyprint(io, Pair(k, aft[k]), "+", indent+1)
            println(io, ",")
        end
    end
    # don't print the leading space if we're at the top-level
    print(io, indent == 0 ? "" : " ")
    print(io, inspace ^ indent, ")")
end

function prettyprint(io, d::AbstractDict, linemarker, indent)
    println(io, "Dict(")
    for p in d
        print(io, linemarker, inspace ^ (indent+1))
        prettyprint(io, p, linemarker, indent+1)
        println(io, ",")
    end
    print(io, linemarker, inspace ^ indent, ")")
end

function prettyprint(io, p::Pair, linemarker, indent)
    prettyprint(io, p[1], linemarker, indent)
    print(io, " => ")
    prettyprint(io, p[2], linemarker, indent)
end

function prettyprint(io, p::Pair{<:Any, <:DictDiff}, linemarker, indent)
    prettyprint(io, p[1], linemarker, indent)
    print(io, " => ")
    diffprint(io, p[2], indent)
end

prettyprint(io, x, linemarker, indent) = show(io, x)
