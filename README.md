# Microbenchmarks

This is a collection of micro-benchmarks used to compare Julia's performance against
that of other languages.
It was formerly part of the Julia source tree.
The results of these benchmarks are used to generate the performance graph on the
[Julia homepage](https://julialang.org) and the table on the
[benchmarks page](https://julialang.org/benchmarks).

## Running benchmarks

This repository assumes that Julia has been built from source and that there exists
an environment variable `JULIAHOME` that points to the root of the Julia source tree.
This can also be set when invoking `make`, e.g. `make JULIAHOME=path/to/julia`.

To build binaries and run the benchmarks, simply run `make`.
Note that this refers to GNU Make, so BSD users will need to run `gmake`.

## Included languages:

* C
* Fortran
* Go
* Java
* JavaScript
* Julia
* LuaJIT
* Mathematica
* Matlab
* Python
* R
* Rust
* Scala
* Stata
