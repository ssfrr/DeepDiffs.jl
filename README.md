# DeepDiff

[![Travis Status](https://travis-ci.org/ssfrr/StructureDiffs.jl.svg?branch=master)](https://travis-ci.org/ssfrr/StructureDiffs.jl)
[![Appveyor status](https://ci.appveyor.com/api/projects/status/jim9hndbolm8p9p4/branch/master?svg=true)](https://ci.appveyor.com/project/ssfrr/deepdiffs-jl/branch/master)
[![codecov.io](http://codecov.io/github/ssfrr/StructureDiffs.jl/coverage.svg?branch=master)](http://codecov.io/github/ssfrr/StructureDiffs.jl?branch=master)

## Design Thoughts

### Goals

* some kind of `diff` function to compare two data structures and see what changed
* pretty-printing of diffs that show removed in red, added in green, and modified in yellow when it makes sense.

### API

`deepdiff(from, to)` function - returns some `T <: DeepDiff`, supports `from`, `to`, `added`, `removed`, `changed` methods.

OR

`deepdiff(from, to)` returns a `(added, removed)` tuple


### Pretty Printing

```julia
julia> deepdiff([1, 2, 3, 4], [1, 6, 7, 3, 4])

[1, 2, 3, 4]
[1, 6, 7, 3, 4]
```
