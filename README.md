# Microbenchmarks

This is a collection of micro-benchmarks used to compare Julia's performance against
that of other languages.
It was formerly part of the Julia source tree.
The results of these benchmarks are used to generate the performance graph on the
[Julia benchmarks page](https://julialang.org/benchmarks).

The benchmark [results](https://julialang.github.io/Microbenchmarks.jl/) are auto-generated
on Github Actions. Times are normalized relative to C.

## Benchmarks

All benchmarks implement identical algorithms across languages (serial, single-core):

| Benchmark | Description |
|:----------|:------------|
| `iteration_pi_sum` | Alternating power-series summation (nested loops) |
| `recursion_fibonacci` | Doubly-recursive Fibonacci(20) |
| `recursion_quicksort` | Quicksort on 5,000 random numbers |
| `parse_integers` | Parse 1,000 random hex strings to integers |
| `print_to_file` | Write 100,000 formatted lines to /dev/null |
| `matrix_statistics` | Statistics on random 5x5 matrices (1,000 iterations) |
| `matrix_multiply` | Multiply two random 1,000x1,000 matrices (BLAS) |
| `userfunc_mandelbrot` | Mandelbrot set computation over a grid |

## Running benchmarks

Install Julia with [juliaup](https://github.com/JuliaLang/juliaup).

To build binaries and run the benchmarks, simply run `make`.
Note that this refers to GNU Make, so BSD users will need to run `gmake`.

### Prerequisites

Running the full suite locally requires:

* GCC and GFortran
* OpenBLAS development libraries (`libopenblas-dev` on Debian/Ubuntu)
* Go, Java (Maven), Node.js, Python 3 (NumPy), R, Rust, Scala (sbt), Swift, LuaJIT, Octave

Individual language benchmarks can be run with, e.g., `make benchmarks/julia.csv`.

## Languages in CI

* [C](c/perf.c)
* [Fortran](fortran/perf.f90)
* [Go](go/perf.go)
* [Java](java/src/main/java/PerfBLAS.java)
* [JavaScript](javascript/perf.js)
* [Julia](julia/perf.jl)
* [LuaJIT](lua/perf.lua)
* [Octave](octave/perf.m)
* [Python](python/perf.py)
* [R](r/perf.R)
* [Rust](rust/src/main.rs)
* [Scala](scala/src/main/scala/perf.scala)
* [Swift](swift/Sources/perf/main.swift)

## Additional languages (local only)

* [Mathematica](mathematica/perf.nb)
* [Matlab](octave/perf.m)
