# DeepDiffs

[![Travis Status](https://travis-ci.org/ssfrr/DeepDiffs.jl.svg?branch=master)](https://travis-ci.org/ssfrr/DeepDiffs.jl)
[![Appveyor status](https://ci.appveyor.com/api/projects/status/jim9hndbolm8p9p4/branch/master?svg=true)](https://ci.appveyor.com/project/ssfrr/deepdiffs-jl/branch/master)
[![codecov.io](http://codecov.io/github/ssfrr/DeepDiffs.jl/coverage.svg?branch=master)](http://codecov.io/github/ssfrr/DeepDiffs.jl?branch=master)

DeepDiffs.jl provides the `deepdiff` function, which finds and displays differences (diffs) between Julia data structures. It supports `Vector`s, `Dict`s, and `String`s. When diffing dictionaries where values associated with a particular key may change, `deepdiff` will recurse into value to provide a more detailed diff.

Many users will likely only use the `deepdiff` function to interactively visualize diffs. For more advanced usage, the return value from `deepdiff` will be some subtype of the `DeepDiff` abstract type which can be further manipulated. These subtypes support the following functions:

* `before(diff)`: returns the first original (left-hand-side) value that was diffed
* `after(diff)`: returns the modified (right-hand-side) value that was diffed
* `added(diff)`: returns a list of indices or dictionary keys that were new items. These indices correspond to the "after" value.
* `removed(diff)`: returns a list of indices or dictionary keys that were removed. These indices correspond to the "before" value.
* `changed(diff)`: returns a dictionary whose keys are indices or dictionary keys and whose values are themselves `DeepDiff`s that describe the modified value. Currently this is only meaningful when diffing dictionaries because the keys can be matched up between the original and modified values.

## Diffing `Vector`s

`Vector`s are diffed using a longest-subsequence algorithm that tries to minmize the number of additions and removals necessary to transform one `Vector` to another.

![Dict diff output](http://ssfrr.github.io/DeepDiffs.jl/images/vectordiff.png)

## Diffing `Dict`s

`Dict`s are diffed by matching up the keys between the original and modified values, so it can recognize removed, added, or modified values.

![Dict diff output](http://ssfrr.github.io/DeepDiffs.jl/images/dictdiff.png)

If color is disabled then the additions and removals are displayed a little differently:

![Dict diff output](http://ssfrr.github.io/DeepDiffs.jl/images/dictdiff_nocolor.png)

## Diffing `String`s

### Single-line strings

Single-line strings are diffed character-by-character. The indices returned by `added` and `removed` correspond to indices in the `Vector` of characters returned by `collect(str::String)`.

![Dict diff output](http://ssfrr.github.io/DeepDiffs.jl/images/singlestringdiff.png)

### Multi-line strings

Multi-line strings (strings with at least one newline) are diffed line-by-line. The indices returned by `added` and `removed` correspond to line numbers.

![Dict diff output](http://ssfrr.github.io/DeepDiffs.jl/images/multistringdiff.png)
