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
        assert(d < base)
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
// Random number helpers (simple LCG for parse_int; system random for others)
// ---------------------------------------------------------------------------

func myrand(_ n: Int) -> [Double] {
    var a = [Double](repeating: 0, count: n)
    for i in 0..<n {
        a[i] = Double.random(in: 0.0..<1.0)
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
        x = Double.random(in: -1.0...1.0)
        y = Double.random(in: -1.0...1.0)
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
                Q[2*n*j + k]         = a[k]
                Q[2*n*j + n + k]     = b[k]
                Q[2*n*(n+j) + k]     = c[k]
                Q[2*n*(n+j) + n + k] = d[k]
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

func printfd(_ n: Int) {
    let fh = FileHandle(forWritingAtPath: "/dev/null")!
    for i in 0..<n {
        let s = "\(i) \(i + 1)\n"
        fh.write(s.data(using: .utf8)!)
    }
    fh.closeFile()
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
        let n = UInt32.random(in: 0...UInt32.max)
        let s = String(n, radix: 16)
        let m = parseIntFromString(s, base: 16)
        blackHole(m == Int(n))
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
    for _ in 0..<100 {
        blackHole(mandelperf())
    }
    let elapsed = clockNow() - t
    if elapsed < tmin { tmin = elapsed }
}
printPerf("userfunc_mandelbrot", tmin / 100)

// quicksort
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
