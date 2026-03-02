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

- Each benchmark is run 3 times; the minimum time is reported
- A minimum accumulation time of 2 seconds ensures stable measurements
- The first iteration serves as warmup
- Both `OMP_NUM_THREADS` and `OPENBLAS_NUM_THREADS` are set to 1 for deterministic single-threaded execution
- Runs on GitHub Actions `ubuntu-latest` runners (x86_64)

## Matrix benchmarks and BLAS

The `matrix_multiply` benchmark calls the most obvious built-in/standard
matrix multiplication routine for each language. For most compiled
languages this means calling BLAS (via OpenBLAS):

**Using BLAS/optimized libraries:** C, Fortran, Julia, Python (NumPy),
Go (Gonum), Java (jBLAS), Rust (ndarray), R, Octave, Swift (Accelerate)

**Pure implementation:** JavaScript, LuaJIT

The `matrix_statistics` benchmark computes statistics on small 5×5
matrices and is less BLAS-dependent, testing the language's own matrix
operations.
