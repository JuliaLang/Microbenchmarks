import java.util.List;
import java.util.Random;

import org.jblas.DoubleMatrix;

/**
 * Benchmark tests that call BLAS.
 */
public class PerfBLAS extends PerfPure {

    public static void main(String[] args) {
        PerfBLAS p = new PerfBLAS();
        p.runBenchmarks();
    }

    private double randmatmul(int i) {
        DoubleMatrix a = DoubleMatrix.randn(i,i);
        DoubleMatrix b = DoubleMatrix.randn(i,i);
        return a.mmul(b).get(0);
    }

    private double[] randmatstat(int t) {
        int n=5;
        DoubleMatrix p;
        DoubleMatrix q;
        DoubleMatrix v = new DoubleMatrix(new double[t][1]); //zeros(t,1);
        DoubleMatrix w = new DoubleMatrix(new double[t][1]); //zeros(t,1);
        for (int i=0; i < t; i++) {
            DoubleMatrix a = DoubleMatrix.randn(n,n);
            DoubleMatrix b = DoubleMatrix.randn(n,n);
            DoubleMatrix c = DoubleMatrix.randn(n,n);
            DoubleMatrix d = DoubleMatrix.randn(n,n);

            p = DoubleMatrix.concatHorizontally(DoubleMatrix.concatHorizontally(a, b),DoubleMatrix.concatHorizontally(c, d));
            q = DoubleMatrix.concatVertically(DoubleMatrix.concatHorizontally(a, b),DoubleMatrix.concatHorizontally(c, d));

            DoubleMatrix x = p.transpose().mmul(p);
            x = x.mmul(x);
            x = x.mmul(x);
            v.data[i]=x.diag().sum();

            x = q.transpose().mmul(q);
            x = x.mmul(x);
            x = x.mmul(x);
            w.data[i]=x.diag().sum();

        }

        List<Double> vElements = v.elementsAsList();
        List<Double> wElements = w.elementsAsList();

        return new double[]{stdev(vElements)/mean(vElements),stdev(wElements)/mean(wElements)};
    }

}
