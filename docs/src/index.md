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
| `iteration_pi_sum` | Summation of the series 1/k² for k = 1 to 10,000, repeated 500 times (nested loops) |
| `recursion_fibonacci` | Doubly-recursive Fibonacci(20) |
| `recursion_quicksort` | Quicksort on 5,000 random numbers |
| `parse_integers` | Parse 1,000 random hex strings to integers |
| `print_to_file` | Write 100,000 formatted lines to /dev/null |
| `matrix_statistics` | Statistics on random 5×5 matrices (1,000 iterations) |
| `matrix_multiply` | Multiply two random 1,000×1,000 matrices (BLAS) |
| `userfunc_mandelbrot` | Mandelbrot set computation over a grid |

## Methodology

- Each language's benchmark script internally runs each benchmark 5 times and records the minimum time
- The whole suite runs 3 times back-to-back (each pass runs every language once); `collect.jl` takes the overall minimum across all runs
- Julia and Numba run an explicit untimed warm-up pass so that compilation is excluded. The other JIT-compiled languages (C#, Java, JavaScript, LuaJIT, Scala) have no separate warm-up; their first timed repetition includes JIT compilation, and taking the minimum of 5 repetitions mostly discards it
- Most languages time each repetition of a benchmark separately. Some (C, C#, Fortran, JavaScript, Rust, Swift) time a batch of calls for the shortest benchmarks and report the average per call
- Single-threaded execution enforced via environment variables (`OMP_NUM_THREADS=1`, `OPENBLAS_NUM_THREADS=1`, `MKL_NUM_THREADS=1`, `GOMAXPROCS=1`, `JULIA_NUM_THREADS=1`, `NUMBA_NUM_THREADS=1`)
- All languages run on the same GitHub Actions `ubuntu-24.04` runner (x86_64, single core used), so every time comes from the same CPU
- Benchmarks test equivalent code patterns, not peak-optimized implementations

See [Notes](notes.md) for more details.
