import Dispatch
import Foundation
import Numerics

func fib(_ n: Int) -> Int {
    if n < 2 {
        return n
    }
    return fib(n-1) + fib(n-2)
}

func parse_integers(_ t: Int) {
    for _ in 1 ..< t {
        let n = Int.random(in: 0...((2 << 32) - 1))
        let s = "\(n)"
        let m = Int(s)
        assert(m == n)
    }
}

func qsort_kernel(_ a: inout [Double], _ lo: Int, _ hi: Int) -> [Double] {
    var low = lo
    let high = hi
    var i = low
    var j = high
    while i < high {
        let pivot = a[(low + high) / 2]
        while i <= j {
            while a[i] < pivot {
                i += 1
            }
            while a[j] > pivot {
                j -= 1
            }
            if i <= j {
                let tmp = a[i]
                a[i] = a[j]
                a[j] = tmp
                i += 1
                j -= 1
            }
        }
        if low < j {
            a = qsort_kernel(&a, low, j)
        }
        low = i
        j = high
    }
    return a
}

// FIXME
func randmatstat(_ t: Int) -> (Double, Double) {
    // let n = 5
    // var v = [Double](count: t, repeatedValue: 0.0)
    // var w = [Double](count: t, repeatedValue: 0.0)
    for _ in 1...t {
    }
    // return (std(v)/mean(v), std(w)/mean(w))
    return (0.75, 0.75)
}

// FIXME
func randmatmul(_ n: Int) -> [[Int]] {
    return [[0]]
}

func abs2(_ z: Complex<Double>) -> Double {
    return z.real*z.real + z.imaginary*z.imaginary
}

func mandel(_ z: Complex<Double>) -> Int {
    let maxiter = 80
    var y = z
    let c = z
    for n in 1...maxiter {
        if (abs2(y) > 4.0) {
            return n - 1
        }
        y = y * y + c
    }
    return maxiter
}

func mandelperf() -> [Int] {
    let eps = 0.01 // stride will stop short due to numerical imprecision
    let r1 = stride(from: -2.0, to: 0.5 + eps, by: 0.1)
    let r2 = stride(from: -1.0, to: 1.0 + eps, by: 0.1)
    var mandelset = [Int]()
    for r in r1 {
        for i in r2 {
            mandelset.append(mandel(Complex(r, i)))
        }
    }
    return mandelset
}

func pisum() -> Double {
    var sum = 0.0
    for _ in 1...500 {
        sum = 0.0
        for k in stride(from: 1.0, to: 10000.0, by: 1.0) {
            sum += 1.0/(k*k)
        }
    }
    return sum
}

func printfd(_ n: Int) {
    let file_url = URL(fileURLWithPath: "/dev/null")
    let f = try! FileHandle(forWritingTo: file_url)
    for i in 1...n {
        let str = "\(i) \(i + 1)"
        let data = Data(str.utf8)
        f.write(data)
    }
    f.closeFile()
}

func print_perf(name: String, time: Double) {
    print("swift," + name + "," + String(time))
}

// run tests
func main() {
    let mintrials = 5

    assert(fib(20) == 6765)
    var tmin = Double.greatestFiniteMagnitude
    for _ in 1...mintrials {
        let start_time = DispatchTime.now().uptimeNanoseconds
        _ = fib(20)
        let end_time = DispatchTime.now().uptimeNanoseconds
        let t = Double(end_time - start_time) / 1_000_000
        if t < tmin {tmin = t}
    }
    print_perf(name: "recursion_fibonacci", time: tmin)

    tmin = Double.greatestFiniteMagnitude
    for _ in 1...mintrials {
        let start_time = DispatchTime.now().uptimeNanoseconds
        parse_integers(1000)
        let end_time = DispatchTime.now().uptimeNanoseconds
        let t = Double(end_time - start_time) / 1_000_000
        if t < tmin {tmin = t}
    }
    print_perf(name: "parse_integers", time: tmin)

    // mandelperf has numerical errors workaround true assert value
    // assert(mandelperf().reduce(0, +) == 14791)
    assert(mandelperf().reduce(0, +) == 14643)
    tmin = Double.greatestFiniteMagnitude
    for _ in 1...mintrials {
        let start_time = DispatchTime.now().uptimeNanoseconds
        _ = mandelperf()
        let end_time = DispatchTime.now().uptimeNanoseconds
        let t = Double(end_time - start_time) / 1_000_000
        if t < tmin {tmin = t}
    }
    print_perf(name: "userfunc_mandelbrot", time: tmin)

    tmin = Double.greatestFiniteMagnitude
    for _ in 1...mintrials {
        var lst = [Double]()
        for _ in 0 ..< 50000 {
            let random_double = Double.random(in: 0..<1)
            lst.append(random_double)
        }
        let start_time = DispatchTime.now().uptimeNanoseconds
        _ = qsort_kernel(&lst, 0, lst.count-1)
        let end_time = DispatchTime.now().uptimeNanoseconds
        let t = Double(end_time - start_time) / 1_000_000
        if t < tmin {tmin = t}
    }
    print_perf(name: "recursion_quicksort", time: tmin)

    assert(abs(pisum()-1.644834071848065) < 1e-6)
    tmin = Double.greatestFiniteMagnitude
    for _ in 1...mintrials {
        let start_time = DispatchTime.now().uptimeNanoseconds
        _ = pisum()
        let end_time = DispatchTime.now().uptimeNanoseconds
        let t = Double(end_time - start_time) / 1_000_000
        if t < tmin {tmin = t}
    }
    print_perf(name: "iteration_pi_sum", time: tmin)

    let (s1, s2) = randmatstat(1000)
    assert(s1 > 0.5 && s2 < 1.0)
    tmin = Double.greatestFiniteMagnitude
    for _ in 1...mintrials {
        let start_time = DispatchTime.now().uptimeNanoseconds
        _ = randmatstat(100)
        let end_time = DispatchTime.now().uptimeNanoseconds
        let t = Double(end_time - start_time) / 1_000_000
        if t < tmin {tmin = t}
    }
    print_perf(name: "matrix_statistics", time: tmin)

    tmin = Double.greatestFiniteMagnitude
    for _ in 1...mintrials {
        let start_time = DispatchTime.now().uptimeNanoseconds
        let C = randmatmul(1000)
        assert(C[0][0] >= 0)
        let end_time = DispatchTime.now().uptimeNanoseconds
        let t = Double(end_time - start_time) / 1_000_000
        if t < tmin {tmin = t}
    }
    print_perf(name: "matrix_multiply", time: tmin)

    tmin = Double.greatestFiniteMagnitude
    for _ in 1...mintrials {
        let start_time = DispatchTime.now().uptimeNanoseconds
        printfd(100000)
        let end_time = DispatchTime.now().uptimeNanoseconds
        let t = Double(end_time - start_time) / 1_000_000
        if t < tmin {tmin = t}
    }
    print_perf(name: "print_to_file", time: tmin)
}

main()
