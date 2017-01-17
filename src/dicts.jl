type DictDiff{T1, KT1, T2, KT2} <: DeepDiff
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

function deepdiff(X::Associative, Y::Associative)
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

function diffprint(io, d::DictDiff, indent=0)
    bef = before(d)
    aft = after(d)

    println(io, typeof(d), "(")
    for k in d.unchanged
        # extra space to account for added linemarker
        print(io, " ", "  " ^ (indent+1))
        prettyprint(io, Pair(k, bef[k]), " ", indent+1)
        println(io)
    end
    # TODO: use `with_output_color` in 0.6 to make this cleaner
    Base.have_color && print(Base.text_colors[:red])
    for k in removed(d)
        print(io, "-", "  " ^ (indent+1))
        prettyprint(io, Pair(k, bef[k]), "-", indent+1)
        println(io)
    end
    Base.have_color && print(Base.text_colors[:normal])
    for (k, v) in changed(d)
        if isa(v, SimpleDiff)
            # if we have a key pointing to a SimpleDiff, then we don't know how to
            # deconstruct the value, so instead we print it like a removed and added key
            Base.have_color && print(Base.text_colors[:red])
            print(io, "-", "  " ^ (indent+1))
            prettyprint(io, Pair(k, before(v)), "-", indent+1)
            println(io)
            Base.have_color && print(Base.text_colors[:green])
            print(io, "+", "  " ^ (indent+1))
            prettyprint(io, Pair(k, after(v)), "+", indent+1)
            println(io)
            Base.have_color && print(Base.text_colors[:normal])
        else
            # extra space to account for added linemarker
            print(io, " ", "  " ^ (indent+1))
            prettyprint(io, Pair(k, v), " ", indent+1)
            println(io)
        end
    end
    Base.have_color && print(Base.text_colors[:green])
    for k in added(d)
        print(io, "+", "  " ^ (indent+1))
        prettyprint(io, Pair(k, aft[k]), "+", indent+1)
        println(io)
    end
    Base.have_color && print(Base.text_colors[:normal])
    print(io, " ", "  " ^ indent, ")")
end

function prettyprint(io, d::Associative, linemarker, indent)
    println(io, typeof(d), "(")
    for p in d
        print(io, linemarker, "  " ^ (indent+1))
        prettyprint(io, p, linemarker, indent+1)
        println()
    end
    print(io, linemarker, "  " ^ indent, ")")
end

function prettyprint(io, p::Pair, linemarker, indent)
    prettyprint(io, p[1], linemarker, indent)
    print(io, " => ")
    prettyprint(io, p[2], linemarker, indent)
end

function prettyprint{T1, T2<:DictDiff}(io, p::Pair{T1, T2}, linemarker, indent)
    prettyprint(io, p[1], linemarker, indent)
    print(io, " => ")
    diffprint(io, p[2], indent)
end


prettyprint(io, x, linemarker, indent) = show(io, x)
