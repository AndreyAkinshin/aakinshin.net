---
title: Moving extended P² quantile estimator
date: 2022-01-25
tags:
- mathematics
- statistics
- research
- P2 quantile estimator
features:
- math
---

In the previous posts, I discussed
  [the P² quantile estimator]({{< ref p2-quantile-estimator >}})
  (a sequential estimator which takes $O(1)$ memory and estimates a single predefined quantile),
  [the moving P² quantile estimator]({{< ref mp2-quantile-estimator >}})
  (a moving modification of P² which estimates quantiles within the moving window),
  and [the extended P² quantile estimator]({{< ref ex-p2-quantile-estimator >}})
  (a sequential estimator which takes $O(m)$ memory and estimates $m$ predefined quantiles).

Now it's time to build *the moving modification of the extended P² quantile estimator*
  which estimates $m$ predefined quantiles using $O(m)$ memory within the moving window.

<!--more-->

### The approach

The idea is the same that was used for the [the moving P² quantile estimator]({{< ref mp2-quantile-estimator>}}).
We should reuse the described "movification" approach using the extended P² quantile estimator
  instead of the original P² quantile estimator
  and apply this logic to each requested quantile.

{{< img mp2 >}}

In this approach, in addition to the "target" (the moving window that contains the last $L$ elements of our stream),
  we maintain two consequent moving windows of the same size: the "previous" window and the "current" window
  (see the above figure).
The union of the "previous" and "current" windows always contain the "target" window.
Quantile estimations in the "previous" window are previously calculated using the extended P² quantile estimator.
Quantile estimations in the "current" window should be updated on each new stream element
  also using the extended P² quantile estimator.
Quantile estimations in the "target" window could be obtained
  as a weighted sum of the "previous" and the "current" window.
All the additional details are presented in the post about [the moving P² quantile estimator]({{< ref mp2-quantile-estimator>}}).

### Reference implementation

```cs
public class ExtendedP2QuantileEstimator
{
    internal readonly double[] Probabilities;
    private readonly int m, markerCount;
    private readonly int[] n;
    private readonly double[] ns;
    internal readonly double[] Q;

    public int Count { get; private set; }

    public ExtendedP2QuantileEstimator(params double[] probabilities)
    {
        this.Probabilities = probabilities;
        m = probabilities.Length;
        markerCount = 2 * m + 3;
        n = new int[markerCount];
        ns = new double[markerCount];
        Q = new double[markerCount];
    }

    private void UpdateNs(int maxIndex)
    {
        // Principal markers
        ns[0] = 0;
        for (int i = 0; i < m; i++)
            ns[i * 2 + 2] = maxIndex * Probabilities[i];
        ns[markerCount - 1] = maxIndex;

        // Middle markers
        ns[1] = maxIndex * Probabilities[0] / 2;
        for (int i = 1; i < m; i++)
            ns[2 * i + 1] = maxIndex * (Probabilities[i - 1] + Probabilities[i]) / 2;
        ns[markerCount - 2] = maxIndex * (1 + Probabilities[m - 1]) / 2;
    }

    public void Add(double value)
    {
        if (Count < markerCount)
        {
            Q[Count++] = value;
            if (Count == markerCount)
            {
                Array.Sort(Q);

                UpdateNs(markerCount - 1);
                for (int i = 0; i < markerCount; i++)
                    n[i] = (int)Math.Round(ns[i]);

                Array.Copy(Q, ns, markerCount);
                for (int i = 0; i < markerCount; i++)
                    Q[i] = ns[n[i]];
                UpdateNs(markerCount - 1);
            }

            return;
        }

        int k = -1;
        if (value < Q[0])
        {
            Q[0] = value;
            k = 0;
        }
        else
        {
            for (int i = 1; i < markerCount; i++)
                if (value < Q[i])
                {
                    k = i - 1;
                    break;
                }

            if (k == -1)
            {
                Q[markerCount - 1] = value;
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
            if (Q[i - 1] < qs && qs < Q[i + 1])
                Q[i] = qs;
            else
                Q[i] = Linear(i, dInt);
            n[i] += dInt;
        }
    }

    private double Parabolic(int i, double d)
    {
        return Q[i] + d / (n[i + 1] - n[i - 1]) * (
            (n[i] - n[i - 1] + d) * (Q[i + 1] - Q[i]) / (n[i + 1] - n[i]) +
            (n[i + 1] - n[i] - d) * (Q[i] - Q[i - 1]) / (n[i] - n[i - 1])
        );
    }

    private double Linear(int i, int d)
    {
        return Q[i] + d * (Q[i + d] - Q[i]) / (n[i + d] - n[i]);
    }

    public double GetQuantile(double p)
    {
        if (Count == 0)
            throw new InvalidOperationException("Sequence contains no elements");
        if (Count <= markerCount)
        {
            Array.Sort(Q, 0, Count);
            int index = (int)Math.Round((Count - 1) * p);
            return Q[index];
        }

        for (int i = 0; i < m; i++)
            if (Probabilities[i] == p)
                return Q[2 * i + 2];

        throw new InvalidOperationException($"Target quantile ({p}) wasn't requested in the constructor");
    }

    public void Clear()
    {
        Count = 0;
    }
}

public class MovingExtendedP2QuantileEstimator
{
    private readonly ExtendedP2QuantileEstimator estimator;
    private readonly int windowSize;
    private int n;
    private readonly double[] previousWindowEstimations;

    public MovingExtendedP2QuantileEstimator(double[] probabilities, int windowSize)
    {
        this.windowSize = windowSize;
        estimator = new ExtendedP2QuantileEstimator(probabilities);
        previousWindowEstimations = new double[probabilities.Length];
    }

    public void Add(double value)
    {
        n++;
        if (n % windowSize == 0)
        {
            for (int i = 0; i < estimator.Probabilities.Length; i++)
                previousWindowEstimations[i] = estimator.Q[2 * i + 2];
            estimator.Clear();
        }
        estimator.Add(value);
    }

    public double GetQuantile(double p)
    {
        if (n == 0)
            throw new InvalidOperationException("Sequence contains no elements");
        if (n < windowSize)
            return estimator.GetQuantile(p);

        for (int i = 0; i < estimator.Probabilities.Length; i++)
            if (estimator.Probabilities[i] == p)
            {
                double estimation1 = previousWindowEstimations[i];
                double estimation2 = estimator.Q[2 * i + 2];
                double w2 = (n % windowSize + 1) * 1.0 / windowSize;
                double w1 = 1.0 - w2;
                return w1 * estimation1 + w2 * estimation2;
            }

        throw new InvalidOperationException($"Target quantile ({p}) wasn't requested in the constructor");
    }
}
```
