// C# port of the microbenchmarks from c/perf.c

using System.Diagnostics;
using System.Numerics;
using System.Runtime.InteropServices;

static class Perf
{
    const int NITER = 5;

    static readonly Random rng = new();

    // Prevent constant propagation and keep the optimizer from discarding results.
    static volatile int fibArg = 20;
    static volatile int intSink;
    static double doubleSink;

    static void Check(bool condition, string message)
    {
        if (!condition) throw new InvalidOperationException(message);
    }

    // Runs `body` NITER times and reports the minimum time in milliseconds, divided by `scale`.
    static void TimeIt(string name, Action body, double scale = 1)
    {
        double tmin = double.PositiveInfinity;
        for (int i = 0; i < NITER; i++)
        {
            long start = Stopwatch.GetTimestamp();
            body();
            double t = Stopwatch.GetElapsedTime(start).TotalMilliseconds;
            if (t < tmin) tmin = t;
        }
        Console.WriteLine($"csharp,{name},{tmin / scale:F6}");
    }

    // ---------------------------------------------------------------------------
    // Fibonacci
    // ---------------------------------------------------------------------------

    static int Fib(int n) => n < 2 ? n : Fib(n - 1) + Fib(n - 2);

    // ---------------------------------------------------------------------------
    // Parse integers
    // ---------------------------------------------------------------------------

    static void ParseIntPerf(int t)
    {
        for (int i = 0; i < t; i++)
        {
            uint n = (uint)rng.NextInt64(1L << 32);
            string s = n.ToString("x");
            uint m = Convert.ToUInt32(s, 16);
            Check(m == n, "parse_integers round trip failed");
        }
    }

    // ---------------------------------------------------------------------------
    // Mandelbrot
    // ---------------------------------------------------------------------------

    static int Mandel(Complex z)
    {
        const int maxiter = 80;
        Complex c = z;
        for (int n = 0; n < maxiter; n++)
        {
            if (z.Real * z.Real + z.Imaginary * z.Imaginary > 4.0)
            {
                return n;
            }
            z = z * z + c;
        }
        return maxiter;
    }

    static int[] MandelPerf()
    {
        int[] M = new int[21 * 26];
        for (int i = 0; i < 21; i++)
        {
            for (int j = 0; j < 26; j++)
            {
                M[26 * i + j] = Mandel(new Complex((j - 20) / 10.0, (i - 10) / 10.0));
            }
        }
        return M;
    }

    // ---------------------------------------------------------------------------
    // Quicksort
    // ---------------------------------------------------------------------------

    static void Quicksort(double[] a, int lo, int hi)
    {
        int i = lo;
        int j = hi;
        while (i < hi)
        {
            double pivot = a[(lo + hi) / 2];
            while (i <= j)
            {
                while (a[i] < pivot) i++;
                while (a[j] > pivot) j--;
                if (i <= j)
                {
                    (a[i], a[j]) = (a[j], a[i]);
                    i++;
                    j--;
                }
            }
            if (lo < j) Quicksort(a, lo, j);
            lo = i;
            j = hi;
        }
    }

    static double[] MyRand(int n)
    {
        double[] a = new double[n];
        for (int i = 0; i < n; i++)
        {
            a[i] = rng.NextDouble();
        }
        return a;
    }

    // ---------------------------------------------------------------------------
    // Pi sum
    // ---------------------------------------------------------------------------

    static double PiSum()
    {
        for (int j = 0; j < 500; j++)
        {
            double s = 0.0;
            for (int k = 1; k <= 10000; k++)
            {
                s += 1.0 / (k * k);
            }
            Volatile.Write(ref doubleSink, s);
        }
        return Volatile.Read(ref doubleSink);
    }

    // ---------------------------------------------------------------------------
    // CBLAS (OpenBLAS)
    // ---------------------------------------------------------------------------

    const int CblasColMajor = 102;
    const int CblasNoTrans = 111;
    const int CblasTrans = 112;

    [DllImport("openblas")]
    static extern void cblas_dgemm(
        int order, int transA, int transB,
        int m, int n, int k,
        double alpha,
        double[] a, int lda,
        double[] b, int ldb,
        double beta,
        double[] c, int ldc);

    // ---------------------------------------------------------------------------
    // Matrix statistics
    // ---------------------------------------------------------------------------

    static double Gaussian()
    {
        double k, x, y;
        do
        {
            x = 2.0 * rng.NextDouble() - 1.0;
            y = 2.0 * rng.NextDouble() - 1.0;
            k = x * x + y * y;
        } while (k >= 1.0 || k == 0.0);
        return x * Math.Sqrt(-2.0 * Math.Log(k) / k);
    }

    static void FillRandn(double[] a)
    {
        for (int i = 0; i < a.Length; i++)
        {
            a[i] = Gaussian();
        }
    }

    // Returns the trace of (A'A)^4 for the m-by-m result of A'A, where A has `rows` rows.
    static double TraceOfFourthPower(double[] A, int rows, int m, double[] AtA, double[] AtA2)
    {
        cblas_dgemm(CblasColMajor, CblasTrans, CblasNoTrans, m, m, rows, 1.0, A, rows, A, rows, 0.0, AtA, m);
        cblas_dgemm(CblasColMajor, CblasNoTrans, CblasNoTrans, m, m, m, 1.0, AtA, m, AtA, m, 0.0, AtA2, m);
        cblas_dgemm(CblasColMajor, CblasNoTrans, CblasNoTrans, m, m, m, 1.0, AtA2, m, AtA2, m, 0.0, AtA, m);
        double trace = 0.0;
        for (int j = 0; j < m; j++)
        {
            trace += AtA[(m + 1) * j];
        }
        return trace;
    }

    static (double, double) RandMatStat(int t)
    {
        const int n = 5;
        double[] v = new double[t];
        double[] w = new double[t];
        double[] a = new double[n * n];
        double[] b = new double[n * n];
        double[] c = new double[n * n];
        double[] d = new double[n * n];
        double[] P = new double[n * 4 * n];
        double[] Q = new double[2 * n * 2 * n];
        double[] PtP1 = new double[4 * n * 4 * n];
        double[] PtP2 = new double[4 * n * 4 * n];
        double[] QtQ1 = new double[2 * n * 2 * n];
        double[] QtQ2 = new double[2 * n * 2 * n];

        for (int i = 0; i < t; i++)
        {
            FillRandn(a);
            FillRandn(b);
            FillRandn(c);
            FillRandn(d);

            // P = [a b c d]  (column-major: n rows, 4n columns)
            Array.Copy(a, 0, P, 0 * n * n, n * n);
            Array.Copy(b, 0, P, 1 * n * n, n * n);
            Array.Copy(c, 0, P, 2 * n * n, n * n);
            Array.Copy(d, 0, P, 3 * n * n, n * n);

            // Q = [a b; c d]  (column-major: 2n rows, 2n columns)
            for (int j = 0; j < n; j++)
            {
                for (int k = 0; k < n; k++)
                {
                    Q[2 * n * j + k] = a[n * j + k];
                    Q[2 * n * j + n + k] = c[n * j + k];
                    Q[2 * n * (n + j) + k] = b[n * j + k];
                    Q[2 * n * (n + j) + n + k] = d[n * j + k];
                }
            }

            v[i] = TraceOfFourthPower(P, n, 4 * n, PtP1, PtP2);
            w[i] = TraceOfFourthPower(Q, 2 * n, 2 * n, QtQ1, QtQ2);
        }

        double v1 = 0.0, v2 = 0.0, w1 = 0.0, w2 = 0.0;
        for (int i = 0; i < t; i++)
        {
            v1 += v[i]; v2 += v[i] * v[i];
            w1 += w[i]; w2 += w[i] * w[i];
        }
        double s1 = Math.Sqrt((t * (t * v2 - v1 * v1)) / ((t - 1) * v1 * v1));
        double s2 = Math.Sqrt((t * (t * w2 - w1 * w1)) / ((t - 1) * w1 * w1));
        return (s1, s2);
    }

    // ---------------------------------------------------------------------------
    // Random matrix multiply
    // ---------------------------------------------------------------------------

    static double[] RandMatMul(int n)
    {
        double[] A = MyRand(n * n);
        double[] B = MyRand(n * n);
        double[] C = new double[n * n];
        cblas_dgemm(CblasColMajor, CblasNoTrans, CblasNoTrans, n, n, n, 1.0, A, n, B, n, 0.0, C, n);
        return C;
    }

    // ---------------------------------------------------------------------------
    // Print to file
    // ---------------------------------------------------------------------------

    static void PrintFd(int n)
    {
        using var f = new StreamWriter("/dev/null");
        for (int i = 0; i < n; i++)
        {
            f.Write($"{i} {i + 1}\n");
        }
    }

    // ---------------------------------------------------------------------------
    // Main
    // ---------------------------------------------------------------------------

    static void Main(string[] args)
    {
        // Used by bin/versions.sh to report the runtime that actually runs the benchmarks.
        if (args is ["--version"])
        {
            Console.WriteLine(Environment.Version);
            return;
        }

        Check(Fib(20) == 6765, "fib(20) is wrong");
        TimeIt("recursion_fibonacci", () =>
        {
            int f = 0;
            for (int j = 0; j < 1000; j++)
            {
                f += Fib(fibArg);
            }
            intSink = f;
        }, scale: 1000);

        TimeIt("parse_integers", () => ParseIntPerf(1000 * 100), scale: 100);

        int mandelSum = MandelPerf().Sum();
        Check(mandelSum == 14791, $"mandel sum was {mandelSum}, expected 14791");
        TimeIt("userfunc_mandelbrot", () => intSink = MandelPerf()[0]);

        double[] sorted = MyRand(5000);
        Quicksort(sorted, 0, 5000 - 1);
        for (int k = 1; k < sorted.Length; k++)
        {
            Check(sorted[k - 1] <= sorted[k], "quicksort did not sort");
        }
        TimeIt("recursion_quicksort", () =>
        {
            double[] d = MyRand(5000);
            Quicksort(d, 0, 5000 - 1);
            Volatile.Write(ref doubleSink, d[4999]);
        });

        Check(Math.Abs(PiSum() - 1.644834071848065) < 1e-12, "pi sum is wrong");
        TimeIt("iteration_pi_sum", () => PiSum());

        (double s1, double s2) = RandMatStat(1000);
        Check(0.5 < s1 && s1 < 1.0 && 0.5 < s2 && s2 < 1.0, $"matrix statistics out of range: {s1}, {s2}");
        TimeIt("matrix_statistics", () => RandMatStat(1000));

        TimeIt("matrix_multiply", () =>
        {
            double[] C = RandMatMul(1000);
            Check(0 <= C[0], "matrix product of positive matrices has a negative entry");
        });

        TimeIt("print_to_file", () => PrintFd(100000));
    }
}
