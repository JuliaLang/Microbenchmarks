# Microbenchmarks

[![Benchmarks](https://github.com/JuliaLang/Microbenchmarks/actions/workflows/benchmarks.yml/badge.svg)](https://github.com/JuliaLang/Microbenchmarks/actions/workflows/benchmarks.yml)

A collection of micro-benchmarks comparing Julia's performance against other languages.

**[View results](https://julialang.github.io/Microbenchmarks/dev/benchmarks)**

## Benchmarks

All benchmarks implement identical algorithms across languages (serial, single-core).
Times are normalized relative to C.

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

## Languages

* [C](c/perf.c)
* [Fortran](fortran/perf.f90)
* [Go](go/perf.go)
* [Java](java/src/main/java/PerfBLAS.java)
* [JavaScript](javascript/perf.js)
* [Julia](julia/perf.jl)
* [LuaJIT](lua/perf.lua)
* [Numba](numba/perf.py)
* [Octave](octave/perf.m)
* [Python](python/perf.py)
* [R](r/perf.R)
* [Rust](rust/src/main.rs)
* [Scala](scala/src/main/scala/perf.scala)
* [Swift](swift/Sources/perf/main.swift)

Mathematica and Matlab benchmarks are available but not run in CI.
