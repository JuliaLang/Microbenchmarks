# Notes

## Compile time

The Julia results depicted above do not include compile time.

## Code philosophy

The benchmark codes are not written for absolute maximal performance.

For example, the fastest code to compute `recursion_fibonacci(20)` is
the constant literal `6765`. Instead, the benchmarks are written to
test the performance of identical algorithms and code patterns
implemented in each language. The Fibonacci benchmarks all use the
same (inefficient) doubly-recursive algorithm, and the pi summation
benchmarks use the same for-loop.

## Timing methodology

All languages follow the same pattern:

- Each benchmark is run 5 times internally; the minimum time is reported
- CI runs the whole suite 3 times back-to-back (`PASSES=3`); each pass invokes every language's script once (`ITERATIONS=1`), so runs of the same language are spread across the job rather than taken in a row. Run locally, the Makefile invokes each script 3 times (`ITERATIONS=3`)
- `bin/collect.jl` takes the overall minimum across all runs, so the final reported time is the best of up to 15 measurements
- JIT languages (Julia, Numba) include a warmup pass before the 5 timed iterations to exclude compilation overhead

Environment:

- The following environment variables are set to 1 (via the Makefile and the GitHub Actions workflow) for deterministic single-threaded execution:
  - `OMP_NUM_THREADS=1` — OpenMP threads
  - `OPENBLAS_NUM_THREADS=1` — OpenBLAS threads
  - `MKL_NUM_THREADS=1` — Intel MKL threads (if linked)
  - `GOMAXPROCS=1` — Go runtime OS threads
  - `JULIA_NUM_THREADS=1` — Julia threads
  - `NUMBA_NUM_THREADS=1` — Numba parallel threads
- All languages run in one job on a single GitHub Actions `ubuntu-24.04` runner (x86_64). Every toolchain is installed and all code is compiled before any benchmark runs, so the benchmarks run back-to-back on an otherwise idle machine and every time (and every ratio to C) comes from the same CPU. The CPU model is printed in the job log and summary

## Matrix benchmarks and BLAS

The `matrix_multiply` benchmark calls the most obvious built-in/standard
matrix multiplication routine for each language. For most compiled
languages this means calling BLAS (via OpenBLAS):

**Using BLAS/optimized libraries:** C, C# (P/Invoke), Fortran, Julia, Numba (NumPy),
Python (NumPy), Go (Gonum), Java (jBLAS), Rust (ndarray), Scala (Breeze),
R, Octave, Swift (Accelerate)

**Pure implementation:** JavaScript, LuaJIT

The `matrix_statistics` benchmark computes statistics on small 5×5
matrices and is less BLAS-dependent, testing the language's own matrix
operations.

## Running locally

To build and run all benchmarks: `make` (GNU Make required).

Individual languages can be run with, e.g., `make benchmarks/julia.csv`.

The full suite requires: GCC, GFortran, OpenBLAS (`libopenblas-dev`),
.NET, Go, Java (Maven), Node.js, Python 3 (NumPy, Numba), R, Rust, Scala (sbt),
Swift, LuaJIT, and Octave.
