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
	"fmt"
	"math"
	"math/rand"
	"os"
	"strconv"
	"time"

	"gonum.org/v1/gonum/mat"
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

// sink is a package-level variable used to prevent the compiler from
// optimizing away benchmark computations.
var sink interface{}

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
		sink = sum // prevent the compiler from collapsing the outer loop
		for k := 1.0; k <= 10000; k += 1 {
			sum += 1.0 / (k * k)
		}
	}
	return sum
}

const NITER = 5

func print_perf(name string, t float64) {
	fmt.Printf("go,%v,%v\n", name, t*1000)
}

func timeit(name string, fn func()) {
	tmin := math.Inf(1)
	for i := 0; i < NITER; i++ {
		t := time.Now()
		fn()
		elapsed := time.Since(t).Seconds()
		if elapsed < tmin {
			tmin = elapsed
		}
	}
	print_perf(name, tmin)
}

// run benchmarks

func main() {
	n := 20
	sink = &n // prevent constant propagation of fib argument
	if fib(n) != 6765 {
		panic("unexpected value for fib(20)")
	}
	timeit("recursion_fibonacci", func() {
		fib(n)
	})

	timeit("parse_integers", func() {
		for k := 0; k < 1000; k++ {
			n := rnd.Uint32()
			m, _ := strconv.ParseUint(strconv.FormatUint(uint64(n), 16), 16, 32)
			if uint32(m) != n {
				panic("incorrect value for m")
			}
		}
	})

	if mandelperf() != 14791 {
		panic("unexpected value for mandelperf")
	}
	timeit("userfunc_mandelbrot", func() {
		mandelperf()
	})

	timeit("recursion_quicksort", func() {
		lst := make([]float64, 5000)
		for k := range lst {
			lst[k] = rnd.Float64()
		}
		qsort_kernel(lst, 0, len(lst)-1)
	})

	if math.Abs(pisum()-1.644834071848065) >= 1e-6 {
		panic("pi_sum out of range")
	}
	timeit("iteration_pi_sum", func() {
		pisum()
	})

	c1, c2 := randmatstat(1000)
	if !(0.5 < c1 && c1 < 1.0 && 0.5 < c2 && c2 < 1.0) {
		panic("randmatstat out of range")
	}
	timeit("matrix_statistics", func() {
		randmatstat(1000)
	})

	timeit("matrix_multiply", func() {
		c := randmatmul(1000)
		if c.At(0, 0) < 0 {
			panic("unexpected negative value")
		}
	})

	timeit("print_to_file", func() {
		printfd(100000)
	})
}
