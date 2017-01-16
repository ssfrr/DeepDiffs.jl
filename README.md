# StructureDiffs

[![Build Status](https://travis-ci.org/ssfrr/StructureDiffs.jl.svg?branch=master)](https://travis-ci.org/ssfrr/StructureDiffs.jl)

[![Coverage Status](https://coveralls.io/repos/ssfrr/StructureDiffs.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/ssfrr/StructureDiffs.jl?branch=master)

[![codecov.io](http://codecov.io/github/ssfrr/StructureDiffs.jl/coverage.svg?branch=master)](http://codecov.io/github/ssfrr/StructureDiffs.jl?branch=master)

## Design Thoughts

### Goals

* some kind of `diff` function to compare two data structures and see what changed
* pretty-printing of diffs that show removed in red, added in green, and _maybe_ modified in yellow

### API

`structdiff(from, to)` function - returns `T <: StructDiff`, supports `from`, `to`, `added`, `removed`, `modified` methods

OR

`structdiff(from, to)` returns a `(added, removed)` tuple
