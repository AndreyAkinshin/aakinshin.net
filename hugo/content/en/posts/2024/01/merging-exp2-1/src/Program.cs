internal class Program
{
    public static void Main(string[] args)
    {
        const int n = 1000;
        const int m = 7;
        // Special cases
        Console.WriteLine(Check(
            Enumerable.Range(0, n).Select(i => 0.0).ToArray(),
            Enumerable.Range(0, n).Select(i => i < 0.4 * n ? 0.0 : 1.0).ToArray(),
            m));
        Console.WriteLine(Check(
            Enumerable.Range(0, n).Select(i => i < 0.4 * n ? 0.0 : 1.0).ToArray(),
            Enumerable.Range(0, n).Select(i => 0.0).ToArray(),
            m));
        Console.WriteLine();

        MultiCheck("Uniform", GenerateUniform, n, m);
        MultiCheck("Bimodal", GenerateBimodal, n, m);
    }

    private static void MultiCheck(string title, Func<Random, int, double[]> generate, int n, int m)
    {
        Console.WriteLine($"*** {title} ***");
        var random = new Random(1729);
        var results = new List<CheckResult>();
        for (int i = 0; i < 100; i++)
        {
            var x = generate(random, n);
            var y = generate(random, n);
            results.Add(Check(x, y, m));
        }

        results.Sort((a, b) => a.ApproxGain.CompareTo(b.ApproxGain));
        foreach (var result in results)
            Console.WriteLine(result);
        Console.WriteLine();
    }

    private static CheckResult Check(double[] x, double[] y, int m)
    {
        var xEstimator = new CustomP2MedianEstimator(m);
        var yEstimator = new CustomP2MedianEstimator(m);
        for (int i = 0; i < x.Length; i++)
            xEstimator.Add(x[i]);
        for (int j = 0; j < y.Length; j++)
            yEstimator.Add(y[j]);
        var medianApprox = CustomP2MedianEstimator.GetMedian(xEstimator, yEstimator);
        var medianTrue = GetMedian(x.Concat(y).ToArray());
        var medianX = P2QuantileEstimator.GetMedian(x);
        var medianY = P2QuantileEstimator.GetMedian(y);
        return new CheckResult(medianApprox, medianTrue, medianX, medianY);
    }

    private static double[] GenerateUniform(Random random, int n)
    {
        return Enumerable.Range(0, n)
            .Select(_ => random.NextDouble()).ToArray();
    }

    private static double[] GenerateBimodal(Random random, int n)
    {
        return Enumerable.Range(0, n)
            .Select(_ => random.Next(2) == 0 ? random.NextDouble() : random.NextDouble() + 10).ToArray();
    }

    private static double GetMedian(IReadOnlyList<double> x)
    {
        var sortedX = x.Order().ToList();
        return sortedX.Count % 2 == 0
            ? (sortedX[sortedX.Count / 2 - 1] + sortedX[sortedX.Count / 2]) / 2
            : sortedX[sortedX.Count / 2];
    }

    private class CheckResult
    {
        public double MedianApprox { get; }
        public double MedianTrue { get; }
        public double MedianX { get; }
        public double MedianY { get; }
        public double ApproxError { get; }
        public double MeanXYError { get; }
        public double ApproxGain { get; }

        public CheckResult(double medianApprox, double medianTrue, double medianX, double medianY)
        {
            MedianApprox = medianApprox;
            MedianTrue = medianTrue;
            MedianX = medianX;
            MedianY = medianY;
            ApproxError = Math.Abs(medianTrue - medianApprox);
            MeanXYError = Math.Abs(medianTrue - (medianX + medianY) / 2);
            ApproxGain = MeanXYError - ApproxError;
        }

        public override string ToString()
        {
            string Format(double value) => value.ToString("0.00").PadLeft(5);
            return
                $"True: {Format(MedianTrue)} | " +
                $"Approx: {Format(MedianApprox)} | " +
                $"X: {Format(MedianX)} | " +
                $"Y: {Format(MedianY)} | " +
                $"ApproxErr: {Format(ApproxError)} | " +
                $"MeanXYErr: {Format(MeanXYError)} | " +
                $"ApproxGain: {Format(ApproxGain)}";
        }
    }
}


// Hacky, not-complete, not-so-tested, proof-of-concept implementation
public class CustomP2MedianEstimator
{
    private readonly double[] probabilities;
    private readonly int m, markerCount;
    private readonly int[] n;
    private readonly double[] ns;
    private readonly double[] q;

    public int Count { get; private set; }

    public CustomP2MedianEstimator(int m)
    {
        if (m % 2 == 0)
            throw new NotImplementedException("m must be odd");
        probabilities = new double[m];
        for (int i = 0; i < m; i++)
            probabilities[i] = (i + 1) / (double)(m + 1);
        this.m = m;
        markerCount = 2 * m + 3;
        n = new int[markerCount];
        ns = new double[markerCount];
        q = new double[markerCount];
    }

    private void UpdateNs(int maxIndex)
    {
        // Principal markers
        ns[0] = 0;
        for (int i = 0; i < m; i++)
            ns[i * 2 + 2] = maxIndex * probabilities[i];
        ns[markerCount - 1] = maxIndex;

        // Middle markers
        ns[1] = maxIndex * probabilities[0] / 2;
        for (int i = 1; i < m; i++)
            ns[2 * i + 1] = maxIndex * (probabilities[i - 1] + probabilities[i]) / 2;
        ns[markerCount - 2] = maxIndex * (1 + probabilities[m - 1]) / 2;
    }

    public void Add(double value)
    {
        if (Count < markerCount)
        {
            q[Count++] = value;
            if (Count == markerCount)
            {
                Array.Sort(q);

                UpdateNs(markerCount - 1);
                for (int i = 0; i < markerCount; i++)
                    n[i] = (int)Math.Round(ns[i]);

                Array.Copy(q, ns, markerCount);
                for (int i = 0; i < markerCount; i++)
                    q[i] = ns[n[i]];
                UpdateNs(markerCount - 1);
            }

            return;
        }

        int k = -1;
        if (value < q[0])
        {
            q[0] = value;
            k = 0;
        }
        else
        {
            for (int i = 1; i < markerCount; i++)
                if (value < q[i])
                {
                    k = i - 1;
                    break;
                }

            if (k == -1)
            {
                q[markerCount - 1] = value;
                k = markerCount - 2;
            }
        }

        for (int i = k + 1; i < markerCount; i++)
            n[i]++;
        UpdateNs(Count);

        int leftI = 1, rightI = markerCount - 2;
        while (leftI <= rightI)
        {
            int i;
            if (Math.Abs(ns[leftI] / Count - 0.5) <= Math.Abs(ns[rightI] / Count - 0.5))
                i = leftI++;
            else
                i = rightI--;
            Adjust(i);
        }

        Count++;
    }

    private void Adjust(int i)
    {
        double d = ns[i] - n[i];
        if (d >= 1 && n[i + 1] - n[i] > 1 || d <= -1 && n[i - 1] - n[i] < -1)
        {
            int dInt = Math.Sign(d);
            double qs = Parabolic(i, dInt);
            if (q[i - 1] < qs && qs < q[i + 1])
                q[i] = qs;
            else
                q[i] = Linear(i, dInt);
            n[i] += dInt;
        }
    }

    private double Parabolic(int i, double d)
    {
        return q[i] + d / (n[i + 1] - n[i - 1]) * (
            (n[i] - n[i - 1] + d) * (q[i + 1] - q[i]) / (n[i + 1] - n[i]) +
            (n[i + 1] - n[i] - d) * (q[i] - q[i - 1]) / (n[i] - n[i - 1])
        );
    }

    private double Linear(int i, int d)
    {
        return q[i] + d * (q[i + d] - q[i]) / (n[i + d] - n[i]);
    }

    public void Clear()
    {
        Count = 0;
    }

    public static double GetMedian(CustomP2MedianEstimator x, CustomP2MedianEstimator y)
    {
        if (x.Count != y.Count)
            throw new NotImplementedException("Different counts are not supported yet");
        if (x.markerCount != y.markerCount)
            throw new NotImplementedException("Different marker counts are not supported yet");

        if (x.Count <= x.markerCount || y.Count <= y.markerCount)
        {
            var size = x.Count;
            var values = new List<double>(2 * size);
            values.AddRange(x.q);
            values.AddRange(y.q);
            values.Sort();
            // Return median
            return (values[size - 1] + values[size]) / 2;
        }

        int markerCount = x.markerCount;

        // Original .n contains indexes in the range [0; Count - 1]
        // Let's transform them to quantile orders in the range [0; 1].
        var px = x.n.Select(value => value / (double)(x.Count - 1)).ToArray();
        var py = y.n.Select(value => value / (double)(y.Count - 1)).ToArray();
        var qx = x.q;
        var qy = y.q;

        double[] p = new double[2 * markerCount], q = new double[2 * markerCount];
        int i = 0, j = 0, k = 0;
        while (k < 2 * markerCount)
        {
            if (j == markerCount || i < markerCount && qx[i] < qy[j])
            {
                // Take X
                double pxi = px[i];
                double pyj;
                if (j == 0)
                    pyj = 0.0;
                else if (j == markerCount)
                    pyj = 1.0;
                else
                    pyj = Interpolation(py[j - 1], py[j], qy[j - 1], qx[i], qy[j]);

                p[k] = (pxi + pyj) / 2;
                q[k++] = qx[i++];
            }
            else
            {
                // Take Y
                double pyj = py[j];
                double pxi;
                if (i == 0)
                    pxi = 0.0;
                else if (i == markerCount)
                    pxi = 1.0;
                else
                    pxi = Interpolation(px[i - 1], px[i], qx[i - 1], qy[j], qx[i]);

                p[k] = (pxi + pyj) / 2;
                q[k++] = qy[j++];
            }
        }

        for (k = 0; k < 2 * markerCount - 1; k++)
            if (p[k + 1] >= 0.5)
                return Interpolation(q[k], q[k + 1], p[k], 0.5, p[k + 1]);
        throw new InvalidOperationException("Median not found");
    }

    private static double Interpolation(double start, double end, double prev, double current, double next)
    {
        return Math.Abs(next - prev) < 1e-9
            ? end
            : start + (end - start) * (current - prev) / (next - prev);
    }
}

// Copy-pasted from https://aakinshin.net/posts/p2-quantile-estimator-adjusting-order/
public class P2QuantileEstimator
{
    private readonly double p;
    private readonly InitializationStrategy strategy;
    private readonly int[] n = new int[5];
    private readonly double[] ns = new double[5];
    private readonly double[] q = new double[5];

    public int Count { get; private set; }

    public enum InitializationStrategy
    {
        Classic,
        Adaptive
    }

    public P2QuantileEstimator(double probability,
                               InitializationStrategy strategy = InitializationStrategy.Classic)
    {
        p = probability;
        this.strategy = strategy;
    }

    public void Add(double value)
    {
        if (Count < 5)
        {
            q[Count++] = value;
            if (Count == 5)
            {
                Array.Sort(q);

                for (int i = 0; i < 5; i++)
                    n[i] = i;

                if (strategy == InitializationStrategy.Adaptive)
                {
                    Array.Copy(q, ns, 5);
                    n[1] = (int)Math.Round(2 * p);
                    n[2] = (int)Math.Round(4 * p);
                    n[3] = (int)Math.Round(2 + 2 * p);
                    q[1] = ns[n[1]];
                    q[2] = ns[n[2]];
                    q[3] = ns[n[3]];
                }

                ns[0] = 0;
                ns[1] = 2 * p;
                ns[2] = 4 * p;
                ns[3] = 2 + 2 * p;
                ns[4] = 4;
            }

            return;
        }

        int k;
        if (value < q[0])
        {
            q[0] = value;
            k = 0;
        }
        else if (value < q[1])
            k = 0;
        else if (value < q[2])
            k = 1;
        else if (value < q[3])
            k = 2;
        else if (value < q[4])
            k = 3;
        else
        {
            q[4] = value;
            k = 3;
        }

        for (int i = k + 1; i < 5; i++)
            n[i]++;
        ns[1] = Count * p / 2;
        ns[2] = Count * p;
        ns[3] = Count * (1 + p) / 2;
        ns[4] = Count;

        if (p >= 0.5)
        {
            for (int i = 1; i <= 3; i++)
                Adjust(i);
        }
        else
        {
            for (int i = 3; i >= 1; i--)
                Adjust(i);
        }

        Count++;
    }

    private void Adjust(int i)
    {
        double d = ns[i] - n[i];
        if (d >= 1 && n[i + 1] - n[i] > 1 || d <= -1 && n[i - 1] - n[i] < -1)
        {
            int dInt = Math.Sign(d);
            double qs = Parabolic(i, dInt);
            if (q[i - 1] < qs && qs < q[i + 1])
                q[i] = qs;
            else
                q[i] = Linear(i, dInt);
            n[i] += dInt;
        }
    }

    private double Parabolic(int i, double d)
    {
        return q[i] + d / (n[i + 1] - n[i - 1]) * (
            (n[i] - n[i - 1] + d) * (q[i + 1] - q[i]) / (n[i + 1] - n[i]) +
            (n[i + 1] - n[i] - d) * (q[i] - q[i - 1]) / (n[i] - n[i - 1])
        );
    }

    private double Linear(int i, int d)
    {
        return q[i] + d * (q[i + d] - q[i]) / (n[i + d] - n[i]);
    }

    public double GetQuantile()
    {
        if (Count == 0)
            throw new InvalidOperationException("Sequence contains no elements");
        if (Count <= 5)
        {
            Array.Sort(q, 0, Count);
            int index = (int)Math.Round((Count - 1) * p);
            return q[index];
        }

        return q[2];
    }

    public void Clear()
    {
        Count = 0;
    }

    public static double GetMedian(IEnumerable<double> x)
    {
        var estimator = new P2QuantileEstimator(0.5);
        foreach (var value in x)
            estimator.Add(value);
        return estimator.GetQuantile();
    }
}
