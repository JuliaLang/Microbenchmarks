# Julia Microbenchmarks

These micro-benchmarks, while not comprehensive, do test compiler
performance on a range of common code patterns, such as function
calls, string parsing, sorting, numerical loops, random number
generation, recursion, and array operations.

See the [Benchmarks](benchmarks.md) page for the interactive chart comparing all languages.

Source code: [JuliaLang/Microbenchmarks](https://github.com/JuliaLang/Microbenchmarks)

## What is measured

All benchmarks implement identical algorithms across languages (serial, single-core).
Times are normalized relative to C.

| Benchmark | Description |
|:----------|:------------|
| `iteration_pi_sum` | Alternating power-series summation (nested loops) |
| `recursion_fibonacci` | Doubly-recursive Fibonacci(20) |
| `recursion_quicksort` | Quicksort on 5,000 random numbers |
| `parse_integers` | Parse 1,000 random hex strings to integers |
| `print_to_file` | Write 100,000 formatted lines to /dev/null |
| `matrix_statistics` | Statistics on random 5×5 matrices (1,000 iterations) |
| `matrix_multiply` | Multiply two random 1,000×1,000 matrices (BLAS) |
| `userfunc_mandelbrot` | Mandelbrot set computation over a grid |

## Methodology

- Each benchmark runs 5 iterations; the minimum time is taken
- Single-threaded execution (`OMP_NUM_THREADS=1`, `OPENBLAS_NUM_THREADS=1`)
- Julia results exclude compile time
- Runs on GitHub Actions `ubuntu-latest` (x86_64, single core used)
- Benchmarks test equivalent code patterns, not peak-optimized implementations

See [Notes](notes.md) for more details.
