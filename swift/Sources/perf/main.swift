// Swift port of the microbenchmarks from c/perf.c

import Foundation

#if canImport(Glibc)
import Glibc
#elseif canImport(Darwin)
import Darwin
#endif

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

func clockNow() -> Double {
    var tv = timeval()
    gettimeofday(&tv, nil)
    return Double(tv.tv_sec) + Double(tv.tv_usec) / 1.0e6
}

func printPerf(_ name: String, _ t: Double) {
    let ms = t * 1000
    print("swift,\(name),\(String(format: "%.6f", ms))")
}

let NITER = 5

// Prevent the optimizer from eliminating computation results.
// Stores value through a pointer that the compiler cannot reason about.
@inline(never)
func blackHole<T>(_ x: T) {
    withUnsafePointer(to: x) { p in
        _ = p  // force the value to exist in memory
    }
}

// ---------------------------------------------------------------------------
// Fibonacci
// ---------------------------------------------------------------------------

func fib(_ n: Int) -> Int {
    return n < 2 ? n : fib(n - 1) + fib(n - 2)
}

// ---------------------------------------------------------------------------
// Parse integers
// ---------------------------------------------------------------------------

func parseIntFromString(_ s: String, base: Int) -> Int {
    var n = 0
    for c in s.utf8 {
        let d: Int
        if c >= UInt8(ascii: "0") && c <= UInt8(ascii: "9") {
            d = Int(c - UInt8(ascii: "0"))
        } else if c >= UInt8(ascii: "A") && c <= UInt8(ascii: "Z") {
            d = Int(c - UInt8(ascii: "A")) + 10
        } else if c >= UInt8(ascii: "a") && c <= UInt8(ascii: "z") {
            d = Int(c - UInt8(ascii: "a")) + 10
        } else {
            fatalError("invalid character")
        }
        precondition(d < base, "invalid digit")
        n = n * base + d
    }
    return n
}

// ---------------------------------------------------------------------------
// Mandelbrot
// ---------------------------------------------------------------------------

struct ComplexNum {
    var re: Double
    var im: Double

    static func * (a: ComplexNum, b: ComplexNum) -> ComplexNum {
        ComplexNum(re: a.re * b.re - a.im * b.im, im: a.re * b.im + a.im * b.re)
    }

    static func + (a: ComplexNum, b: ComplexNum) -> ComplexNum {
        ComplexNum(re: a.re + b.re, im: a.im + b.im)
    }

    var abs2: Double { re * re + im * im }
}

func mandel(_ z0: ComplexNum) -> Int {
    let maxiter = 80
    let c = z0
    var z = z0
    for n in 0..<maxiter {
        if z.abs2 > 4.0 {
            return n
        }
        z = z * z + c
    }
    return maxiter
}

func mandelperf() -> [Int] {
    var M = [Int](repeating: 0, count: 21 * 26)
    for i in 0..<21 {
        for j in 0..<26 {
            let re = Double(j - 20) / 10.0
            let im = Double(i - 10) / 10.0
            M[26 * i + j] = mandel(ComplexNum(re: re, im: im))
        }
    }
    return M
}

// ---------------------------------------------------------------------------
// Quicksort
// ---------------------------------------------------------------------------

func quicksort(_ a: inout [Double], _ lo: Int, _ hi: Int) {
    var i = lo
    var j = hi
    var lo = lo
    while i < hi {
        let pivot = a[(lo + hi) / 2]
        while i <= j {
            while a[i] < pivot { i += 1 }
            while a[j] > pivot { j -= 1 }
            if i <= j {
                a.swapAt(i, j)
                i += 1
                j -= 1
            }
        }
        if lo < j {
            quicksort(&a, lo, j)
        }
        lo = i
        j = hi
    }
}

// ---------------------------------------------------------------------------
// Pi sum
// ---------------------------------------------------------------------------

func pisum() -> Double {
    var sum = 0.0
    for _ in 0..<500 {
        sum = 0.0
        for k in 1...10000 {
            sum += 1.0 / Double(k * k)
        }
    }
    return sum
}

// ---------------------------------------------------------------------------
// Random number helpers
// ---------------------------------------------------------------------------

// Xoshiro256++, the same generator Julia uses by default. Swift's default
// SystemRandomNumberGenerator makes a getrandom syscall for every number on
// Linux, which would dominate every benchmark that uses random numbers.
struct Xoshiro256: RandomNumberGenerator {
    var s0: UInt64, s1: UInt64, s2: UInt64, s3: UInt64

    // Expand the seed with SplitMix64, as recommended by the authors.
    static func splitmix(_ x: inout UInt64) -> UInt64 {
        x &+= 0x9e3779b97f4a7c15
        var z = x
        z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
        z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
        return z ^ (z >> 31)
    }

    init(seed: UInt64) {
        var x = seed
        s0 = Xoshiro256.splitmix(&x)
        s1 = Xoshiro256.splitmix(&x)
        s2 = Xoshiro256.splitmix(&x)
        s3 = Xoshiro256.splitmix(&x)
    }

    @inline(__always)
    mutating func next() -> UInt64 {
        let result = (s0 &+ s3).rotl(23) &+ s0
        let t = s1 << 17
        s2 ^= s0
        s3 ^= s1
        s1 ^= s2
        s0 ^= s3
        s2 ^= t
        s3 = s3.rotl(45)
        return result
    }
}

extension UInt64 {
    @inline(__always)
    func rotl(_ k: UInt64) -> UInt64 { (self << k) | (self >> (64 - k)) }
}

var rng = Xoshiro256(seed: 1776)

// Uniform double in [0, 1) from the top 53 bits.
@inline(__always)
func randDouble() -> Double {
    Double(rng.next() >> 11) * 0x1.0p-53
}

func myrand(_ n: Int) -> [Double] {
    var a = [Double](repeating: 0, count: n)
    for i in 0..<n {
        a[i] = randDouble()
    }
    return a
}

// ---------------------------------------------------------------------------
// Matrix statistics  (uses CBLAS from OpenBLAS)
// ---------------------------------------------------------------------------

// CBLAS declarations
@_silgen_name("cblas_dgemm")
func cblas_dgemm(
    _ order: Int32, _ transA: Int32, _ transB: Int32,
    _ m: Int32, _ n: Int32, _ k: Int32,
    _ alpha: Double,
    _ A: UnsafePointer<Double>, _ lda: Int32,
    _ B: UnsafePointer<Double>, _ ldb: Int32,
    _ beta: Double,
    _ C: UnsafeMutablePointer<Double>, _ ldc: Int32
)

let CblasColMajor: Int32 = 102
let CblasNoTrans: Int32 = 111
let CblasTrans: Int32 = 112

func gaussian() -> Double {
    var k: Double
    var x: Double
    var y: Double
    repeat {
        x = 2.0 * randDouble() - 1.0
        y = 2.0 * randDouble() - 1.0
        k = x * x + y * y
    } while k >= 1.0
    return x * sqrt((-2.0 * log(k)) / k)
}

func fillRandn(_ a: inout [Double]) {
    for i in 0..<a.count {
        a[i] = gaussian()
    }
}

func randmatstat(_ t: Int) -> (Double, Double) {
    let n = 5
    var v = [Double](repeating: 0, count: t)
    var w = [Double](repeating: 0, count: t)

    var a = [Double](repeating: 0, count: n * n)
    var b = [Double](repeating: 0, count: n * n)
    var c = [Double](repeating: 0, count: n * n)
    var d = [Double](repeating: 0, count: n * n)
    var P = [Double](repeating: 0, count: n * 4 * n)
    var Q = [Double](repeating: 0, count: 2 * n * 2 * n)
    var PtP1 = [Double](repeating: 0, count: 4 * n * 4 * n)
    var PtP2 = [Double](repeating: 0, count: 4 * n * 4 * n)
    var QtQ1 = [Double](repeating: 0, count: 2 * n * 2 * n)
    var QtQ2 = [Double](repeating: 0, count: 2 * n * 2 * n)

    for i in 0..<t {
        fillRandn(&a)
        fillRandn(&b)
        fillRandn(&c)
        fillRandn(&d)

        // P = [a b c d]  (column-major: n rows, 4n cols)
        P.replaceSubrange(0*n*n..<1*n*n, with: a)
        P.replaceSubrange(1*n*n..<2*n*n, with: b)
        P.replaceSubrange(2*n*n..<3*n*n, with: c)
        P.replaceSubrange(3*n*n..<4*n*n, with: d)

        // Q = [a b; c d]  (column-major: 2n rows, 2n cols)
        for j in 0..<n {
            for k in 0..<n {
                Q[2*n*j + k]         = a[n*j + k]
                Q[2*n*j + n + k]     = b[n*j + k]
                Q[2*n*(n+j) + k]     = c[n*j + k]
                Q[2*n*(n+j) + n + k] = d[n*j + k]
            }
        }

        // PtP1 = P' * P  (4n x 4n)
        cblas_dgemm(CblasColMajor, CblasTrans, CblasNoTrans,
                    Int32(4*n), Int32(4*n), Int32(n), 1.0,
                    P, Int32(n), P, Int32(n), 0.0, &PtP1, Int32(4*n))
        // PtP2 = PtP1 * PtP1
        cblas_dgemm(CblasColMajor, CblasNoTrans, CblasNoTrans,
                    Int32(4*n), Int32(4*n), Int32(4*n), 1.0,
                    PtP1, Int32(4*n), PtP1, Int32(4*n), 0.0, &PtP2, Int32(4*n))
        // PtP1 = PtP2 * PtP2
        cblas_dgemm(CblasColMajor, CblasNoTrans, CblasNoTrans,
                    Int32(4*n), Int32(4*n), Int32(4*n), 1.0,
                    PtP2, Int32(4*n), PtP2, Int32(4*n), 0.0, &PtP1, Int32(4*n))

        for j in 0..<(4*n) {
            v[i] += PtP1[(4*n+1)*j]
        }

        // QtQ1 = Q' * Q
        cblas_dgemm(CblasColMajor, CblasTrans, CblasNoTrans,
                    Int32(2*n), Int32(2*n), Int32(2*n), 1.0,
                    Q, Int32(2*n), Q, Int32(2*n), 0.0, &QtQ1, Int32(2*n))
        // QtQ2 = QtQ1 * QtQ1
        cblas_dgemm(CblasColMajor, CblasNoTrans, CblasNoTrans,
                    Int32(2*n), Int32(2*n), Int32(2*n), 1.0,
                    QtQ1, Int32(2*n), QtQ1, Int32(2*n), 0.0, &QtQ2, Int32(2*n))
        // QtQ1 = QtQ2 * QtQ2
        cblas_dgemm(CblasColMajor, CblasNoTrans, CblasNoTrans,
                    Int32(2*n), Int32(2*n), Int32(2*n), 1.0,
                    QtQ2, Int32(2*n), QtQ2, Int32(2*n), 0.0, &QtQ1, Int32(2*n))

        for j in 0..<(2*n) {
            w[i] += QtQ1[(2*n+1)*j]
        }
    }

    var v1 = 0.0, v2 = 0.0, w1 = 0.0, w2 = 0.0
    for i in 0..<t {
        v1 += v[i]; v2 += v[i] * v[i]
        w1 += w[i]; w2 += w[i] * w[i]
    }
    let tf = Double(t)
    let s1 = sqrt((tf * (tf * v2 - v1 * v1)) / ((tf - 1) * v1 * v1))
    let s2 = sqrt((tf * (tf * w2 - w1 * w1)) / ((tf - 1) * w1 * w1))
    return (s1, s2)
}

// ---------------------------------------------------------------------------
// Random matrix multiply  (uses CBLAS)
// ---------------------------------------------------------------------------

func randmatmul(_ n: Int) -> [Double] {
    var A = myrand(n * n)
    var B = myrand(n * n)
    var C = [Double](repeating: 0, count: n * n)
    cblas_dgemm(CblasColMajor, CblasNoTrans, CblasNoTrans,
                Int32(n), Int32(n), Int32(n), 1.0,
                &A, Int32(n), &B, Int32(n), 0.0, &C, Int32(n))
    return C
}

// ---------------------------------------------------------------------------
// Print to file
// ---------------------------------------------------------------------------

// Use C stdio so output is buffered, as in the other languages. FileHandle.write
// makes one write syscall per call.
func printfd(_ n: Int) {
    guard let f = fopen("/dev/null", "w") else { fatalError("cannot open /dev/null") }
    for i in 0..<n {
        fputs("\(i) \(i + 1)\n", f)
    }
    fclose(f)
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

// fib(20)
precondition(fib(20) == 6765)
var tmin = Double.infinity
for _ in 0..<NITER {
    let t = clockNow()
    for _ in 0..<1000 {
        blackHole(fib(20))
    }
    let elapsed = clockNow() - t
    if elapsed < tmin { tmin = elapsed }
}
printPerf("recursion_fibonacci", tmin / 1000)

// parse_int
tmin = Double.infinity
for _ in 0..<NITER {
    let t = clockNow()
    for _ in 0..<(1000 * 100) {
        let n = UInt32(truncatingIfNeeded: rng.next() >> 32)
        let s = String(n, radix: 16)
        let m = parseIntFromString(s, base: 16)
        precondition(m == Int(n), "parse_integers returned the wrong value")
    }
    let elapsed = clockNow() - t
    if elapsed < tmin { tmin = elapsed }
}
printPerf("parse_integers", tmin / 100)

// mandel
do {
    let M = mandelperf()
    let mandelSum = M.reduce(0, +)
    precondition(mandelSum == 14791, "mandel sum was \(mandelSum), expected 14791")
}
tmin = Double.infinity
for _ in 0..<NITER {
    let t = clockNow()
    blackHole(mandelperf())
    let elapsed = clockNow() - t
    if elapsed < tmin { tmin = elapsed }
}
printPerf("userfunc_mandelbrot", tmin)

// quicksort
do {
    var d = myrand(5000)
    quicksort(&d, 0, 5000 - 1)
    precondition(zip(d, d.dropFirst()).allSatisfy { $0 <= $1 }, "quicksort did not sort")
}
tmin = Double.infinity
for _ in 0..<NITER {
    let t = clockNow()
    var d = myrand(5000)
    quicksort(&d, 0, 5000 - 1)
    blackHole(d)
    let elapsed = clockNow() - t
    if elapsed < tmin { tmin = elapsed }
}
printPerf("recursion_quicksort", tmin)

// pi sum
tmin = Double.infinity
for _ in 0..<NITER {
    let t = clockNow()
    let pi = pisum()
    let elapsed = clockNow() - t
    blackHole(pi)
    precondition(abs(pi - 1.644834071848065) < 1e-12)
    if elapsed < tmin { tmin = elapsed }
}
printPerf("iteration_pi_sum", tmin)

// rand mat stat
do {
    let (s1, s2) = randmatstat(1000)
    precondition(0.5 < s1 && s1 < 1.0 && 0.5 < s2 && s2 < 1.0,
                 "matrix_statistics out of range: \(s1), \(s2)")
}
tmin = Double.infinity
for _ in 0..<NITER {
    let t = clockNow()
    blackHole(randmatstat(1000))
    let elapsed = clockNow() - t
    if elapsed < tmin { tmin = elapsed }
}
printPerf("matrix_statistics", tmin)

// rand mat mul
tmin = Double.infinity
for _ in 0..<NITER {
    let t = clockNow()
    let C = randmatmul(1000)
    blackHole(C)
    precondition(0 <= C[0])
    let elapsed = clockNow() - t
    if elapsed < tmin { tmin = elapsed }
}
printPerf("matrix_multiply", tmin)

// printfd
tmin = Double.infinity
for _ in 0..<NITER {
    let t = clockNow()
    printfd(100000)
    let elapsed = clockNow() - t
    if elapsed < tmin { tmin = elapsed }
}
printPerf("print_to_file", tmin)
