# This file was formerly a part of Julia. License is MIT: https://julialang.org/license

using LinearAlgebra: tr
using Printf: @printf
using Random: seed!, rand, randn
using Statistics: std, mean
using Test: @test

const NITER = 5

seed!(1776)

macro timeit(ex, name)
    quote
        t = zeros(NITER)
        for i = 0:NITER
            e = 1000 * (@elapsed $(esc(ex)))
            if i > 0
                t[i] = e  # i == 0 is JIT warmup
            end
        end
        @printf "julia,%s,%f\n" $(esc(name)) minimum(t)
        GC.gc()
    end
end

## recursive fib ##

fib(n) = n < 2 ? n : fib(n - 1) + fib(n - 2)

@test fib(20) == 6765
@timeit fib(20) "recursion_fibonacci"

## parse integer ##

function parseintperf(t)
    local n
    for i = 1:t
        n = rand(UInt32)
        s = string(n, base=16)
        m = parse(UInt32, s, base=16)
        @assert m == n
    end
    return n
end

@timeit parseintperf(1000) "parse_integers"

## mandelbrot set: complex arithmetic and comprehensions ##

function mandel(z)
    c = z
    maxiter = 80
    for n = 1:maxiter
        if real(z)*real(z) + imag(z)*imag(z) > 4
            return n - 1
        end
        z = z^2 + c
    end
    return maxiter
end

mandelperf() = [mandel(complex(r, i)) for i = -1.0:0.1:1.0, r = -2.0:0.1:0.5]
@test sum(mandelperf()) == 14791
@timeit mandelperf() "userfunc_mandelbrot"

## numeric vector sort ##

function qsort!(a, lo, hi)
    i, j = lo, hi
    while i < hi
        pivot = a[(lo+hi)>>>1]
        while i <= j
            while a[i] < pivot; i += 1; end
            while a[j] > pivot; j -= 1; end
            if i <= j
                a[i], a[j] = a[j], a[i]
                i, j = i + 1, j - 1
            end
        end
        if lo < j; qsort!(a, lo, j); end
        lo, j = i, hi
    end
    return a
end

sortperf(n) = qsort!(rand(n), 1, n)
@test issorted(sortperf(5000))
@timeit sortperf(5000) "recursion_quicksort"

## slow pi series ##

const _pisum_vol = Ref(0.0)

function pisum()
    for j = 1:500
        s = 0.0
        for k = 1:10000
            s += 1.0 / (k * k)
        end
        _pisum_vol[] = s
    end
    return _pisum_vol[]
end

@test abs(pisum() - 1.644834071848065) < 1e-12
@timeit pisum() "iteration_pi_sum"

## random matrix statistics ##

function randmatstat(t)
    n = 5
    v = zeros(t)
    w = zeros(t)
    for i = 1:t
        a = randn(n, n)
        b = randn(n, n)
        c = randn(n, n)
        d = randn(n, n)
        P = [a b c d]
        Q = [a b; c d]
        v[i] = tr((P'P)^4)
        w[i] = tr((Q'Q)^4)
    end
    return (std(v) / mean(v), std(w) / mean(w))
end

(s1, s2) = randmatstat(1000)
@test 0.5 < s1 < 1.0 && 0.5 < s2 < 1.0
@timeit randmatstat(1000) "matrix_statistics"

## largish random number gen & matmul ##

@timeit rand(1000, 1000) * rand(1000, 1000) "matrix_multiply"

## printfd ##

if Sys.isunix()
    function printfd(n)
        open("/dev/null", "w") do io
            for i = 1:n
                @printf(io, "%d %d\n", i, i + 1)
            end
        end
    end

    printfd(1)
    @timeit printfd(100000) "print_to_file"
end
