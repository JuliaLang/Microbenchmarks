// Implementation of the Julia benchmark suite in Go.
//
// Three gonum packages must be installed, and then an additional environment
// variable must be set to use the BLAS installation.
// To install the gonum packages, run:
// 		go get gonum.org/v1/netlib/blas/netlib
//		go get gonum.org/v1/gonum/mat
//		go get gonum.org/v1/gonum/stat
// The cgo ldflags must then be set to use the BLAS implementation. As an example,
// download OpenBLAS to ~/software
//		git clone https://github.com/xianyi/OpenBLAS
// 		cd OpenBLAS
//		make
// Then edit the environment variable to have
// 		export CGO_LDFLAGS="-L/$HOME/software/OpenBLAS -lopenblas"
package main

import (
	"bufio"
	"errors"
	"fmt"
	"log"
	"math"
	"math/rand"
	"os"
	"strconv"
	"testing"

	"gonum.org/v1/gonum/mat64"
	"gonum.org/v1/gonum/stat"
	"gonum.org/v1/netlib/blas/netlib"
)

func init() {
	// Use the BLAS implementation specified in CGO_LDFLAGS. This line can be
	// commented out to use the native Go BLAS implementation found in
	// gonum.org/v1/gonum/blas/gonum.
	//blas64.Use(gonum.Implementation{})

	// These are here so that toggling the BLAS implementation does not make imports unused
	_ = netlib.Implementation{}
}

// fibonacci

func fib(n int) int {
	if n < 2 {
		return n
	}
	return fib(n-1) + fib(n-2)
}

// print to file descriptor

func printfd(n int) {
	f, err := os.Create("/dev/null")
	if err != nil {
		panic(err)
	}
	defer f.Close()
	w := bufio.NewWriter(f)

	for i := 0; i < n; i++ {
		_, err = fmt.Fprintf(w, "%d %d\n", i, i+1)
	}
	w.Flush()
	f.Close()
}

// quicksort

func qsort_kernel(a []float64, lo, hi int) []float64 {
	i := lo
	j := hi
	for i < hi {
		pivot := a[(lo+hi)/2]
		for i <= j {
			for a[i] < pivot {
				i += 1
			}
			for a[j] > pivot {
				j -= 1
			}
			if i <= j {
				a[i], a[j] = a[j], a[i]
				i += 1
				j -= 1
			}
		}
		if lo < j {
			qsort_kernel(a, lo, j)
		}
		lo = i
		j = hi
	}
	return a
}

var rnd = rand.New(rand.NewSource(1))

// randmatstat

func randmatstat(t int) (float64, float64) {
	n := 5
	v := make([]float64, t)
	w := make([]float64, t)
	ad := make([]float64, n*n)
	bd := make([]float64, n*n)
	cd := make([]float64, n*n)
	dd := make([]float64, n*n)
	P := mat.NewDense(n, 4*n, nil)
	Q := mat.NewDense(2*n, 2*n, nil)
	pTmp := mat.NewDense(4*n, 4*n, nil)
	qTmp := mat.NewDense(2*n, 2*n, nil)
	for i := 0; i < t; i++ {
		for i := range ad {
			ad[i] = rnd.NormFloat64()
			bd[i] = rnd.NormFloat64()
			cd[i] = rnd.NormFloat64()
			dd[i] = rnd.NormFloat64()
		}
		a := mat.NewDense(n, n, ad)
		b := mat.NewDense(n, n, bd)
		c := mat.NewDense(n, n, cd)
		d := mat.NewDense(n, n, dd)
		P.Copy(a)
		P.Slice(0, n, n, n+n).(*mat.Dense).Copy(b)
		P.Slice(0, n, 2*n, 3*n).(*mat.Dense).Copy(c)
		P.Slice(0, n, 3*n, 4*n).(*mat.Dense).Copy(d)

		Q.Copy(a)
		Q.Slice(0, n, n, 2*n).(*mat.Dense).Copy(b)
		Q.Slice(n, 2*n, 0, n).(*mat.Dense).Copy(c)
		Q.Slice(n, 2*n, n, 2*n).(*mat.Dense).Copy(d)

		pTmp.Mul(P.T(), P)
		pTmp.Pow(pTmp, 4)

		qTmp.Mul(Q.T(), Q)
		qTmp.Pow(qTmp, 4)

		v[i] = mat.Trace(pTmp)
		w[i] = mat.Trace(qTmp)
	}
	mv, stdv := stat.MeanStdDev(v, nil)
	mw, stdw := stat.MeanStdDev(v, nil)
	return stdv / mv, stdw / mw
}

// randmatmul

func randmatmul(n int) *mat.Dense {
	aData := make([]float64, n*n)
	for i := range aData {
		aData[i] = rnd.Float64()
	}
	a := mat.NewDense(n, n, aData)

	bData := make([]float64, n*n)
	for i := range bData {
		bData[i] = rnd.Float64()
	}
	b := mat.NewDense(n, n, bData)
	var c mat.Dense
	c.Mul(a, b)
	return &c
}

// mandelbrot
func abs2(z complex128) float64 {
	return real(z)*real(z) + imag(z)*imag(z)
}
func mandel(z complex128) int {
	maxiter := 80
	c := z
	for n := 0; n < maxiter; n++ {
		if abs2(z) > 4 {
			return n
		}
		z = z*z + c
	}
	return maxiter
}

// mandelperf

func mandelperf() int {
	mandel_sum := 0
	// These loops are constructed as such because mandel is very sensitive to
	// its input and this avoids very small floating point issues.
	for re := -20.0; re <= 5; re += 1 {
		for im := -10.0; im <= 10; im += 1 {
			m := mandel(complex(re/10, im/10))
			mandel_sum += m
		}
	}
	return mandel_sum
}

// pisum

func pisum() float64 {
	var sum float64
	for i := 0; i < 500; i++ {
		sum = 0.0
		for k := 1.0; k <= 10000; k += 1 {
			sum += 1.0 / (k * k)
		}
	}
	return sum
}

func print_perf(name string, time float64) {
	fmt.Printf("go,%v,%v\n", name, time*1000)
}

// run tests

func assert(b *testing.B, t bool) {
	if t != true {
		b.Fatal("assert failed")
	}
}

func main() {
	for _, bm := range benchmarks {
		seconds, err := runBenchmarkFor(bm.fn)
		if err != nil {
			log.Fatalf("%s %s", bm.name, err)
		}
		print_perf(bm.name, seconds)
	}
}

func runBenchmarkFor(fn func(*testing.B)) (seconds float64, err error) {
	bm := testing.Benchmark(fn)
	if (bm.N == 0) {
		return 0, errors.New("failed")
	}
	return bm.T.Seconds() / float64(bm.N), nil
}

var benchmarks = []struct {
	name string
	fn   func(*testing.B)
}{
	{
		name: "recursion_fibonacci",
		fn: func(b *testing.B) {
			for i := 0; i < b.N; i++ {
				if fib(20) != 6765 {
					b.Fatal("unexpected value for fib(20)")
				}
			}
		},
	},

	{
		name: "parse_integers",
		fn: func(b *testing.B) {
			for i := 0; i < b.N; i++ {
				for k := 0; k < 1000; k++ {
					n := rnd.Uint32()
					m, _ := strconv.ParseUint(strconv.FormatUint(uint64(n), 16), 16, 32)
					if uint32(m) != n {
						b.Fatal("incorrect value for m")
					}
				}
			}
		},
	},

	{
		name: "userfunc_mandelbrot",
		fn: func(b *testing.B) {
			for i := 0; i < b.N; i++ {
				if mandelperf() != 14791 {
					b.Fatal("unexpected value for mandelperf")
				}
			}
		},
	},

	{
		name: "print_to_file",
		fn: func(b *testing.B) {
			for i := 0; i < b.N; i++ {
				printfd(100000)
			}
		},
	},

	{
		name: "recursion_quicksort",
		fn: func(b *testing.B) {
			lst := make([]float64, 5000)
			b.ResetTimer()
			for i := 0; i < b.N; i++ {
				for k := range lst {
					lst[k] = rnd.Float64()
				}
				qsort_kernel(lst, 0, len(lst)-1)
			}
		},
	},

	{
		name: "iteration_pi_sum",
		fn: func(b *testing.B) {
			for i := 0; i < b.N; i++ {
				if math.Abs(pisum()-1.644834071848065) >= 1e-6 {
					b.Fatal("pi_sum out of range")
				}
			}
		},
	},

	{
		name: "matrix_statistics",
		fn: func(b *testing.B) {
			for i := 0; i < b.N; i++ {
				c1, c2 := randmatstat(1000)
				assert(b, 0.5 < c1)
				assert(b, c1 < 1.0)
				assert(b, 0.5 < c2)
				assert(b, c2 < 1.0)
			}
		},
	},

	{
		name: "matrix_multiply",
		fn: func(b *testing.B) {
			for i := 0; i < b.N; i++ {
				c := randmatmul(1000)
				assert(b, c.At(0, 0) >= 0)
			}
		},
	},
}
