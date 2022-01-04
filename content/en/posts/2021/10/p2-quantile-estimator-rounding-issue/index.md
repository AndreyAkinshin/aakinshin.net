---
title: P² quantile estimator rounding issue
date: 2021-10-26
tags:
- Statistics
- research-p2qe
features:
- math
---

**Update: The [initialization strategy could be improved]({{< ref p2-quantile-estimator-initialization >}}).**

The P² quantile estimator is a sequential estimator that uses $O(1)$ memory.
Thus, for the given sequence of numbers, it allows estimating quantiles without storing values.
I already wrote [a blog post]({{< ref p2-quantile-estimator >}}) about this approach and
  [added](https://github.com/AndreyAkinshin/perfolizer/commit/9e9ff80a4d097fe4c0814ca51c7fbe942763e308)
  its implementation in [perfolizer](https://github.com/AndreyAkinshin/perfolizer).
Recently, I got a [bug report](https://github.com/AndreyAkinshin/perfolizer/issues/8)
  that revealed a flaw of the [original paper](https://doi.org/10.1145/4372.4378).
In this post, I'm going to briefly discuss this issue and the corresponding fix.

<!--more-->

### Introduction

I already [described]({{< ref p2-quantile-estimator >}}) the P² quantile estimator algorithm
  in one of the previous blog posts.
This approach includes maintaining of five markers $\{ n'_0, n'_1, n'_2, n'_3, n'_4 \}$.
If the considered sequence currently contains exactly $n$ elements, the marker values are defined as follows:

* $n'_0 = 0$
* $n'_1 = (n - 1) p / 2$
* $n'_2 = (n - 1) p$
* $n'_3 = (n - 1) (1 + p) / 2$
* $n'_4 = (n - 1)$

After adding another element in the sequence, the marker values should be invalidated.
The [original paper](https://doi.org/10.1145/4372.4378) suggests using the marker increments to "reduce CPU overhead":

* $dn'_0 = 0$
* $dn'_1 = p / 2$
* $dn'_2 = p$
* $dn'_3 = (1 + p) / 2$
* $dn'_4 = 1$

[@AnthonyLloyd](https://github.com/AnthonyLloyd) has [reported](https://github.com/AndreyAkinshin/perfolizer/issues/8)
  that such approach has rounding issues.
Let's try to fix this problem and see how it affects the approach.

### Experiments

Let's implement the classic approach with increments (`P2QuantileEstimatorOriginal`)
  and the new one without increments (`P2QuantileEstimatorPatched`):

```cs
public class P2QuantileEstimatorOriginal
{
    private readonly double p;
    private readonly int[] n = new int[5]; // marker positions
    private readonly double[] ns = new double[5]; // desired marker positions
    private readonly double[] dns = new double[5];
    private readonly double[] q = new double[5]; // marker heights
    private int count;

    public P2QuantileEstimatorOriginal(double probability)
    {
        p = probability;
    }

    public void AddValue(double x)
    {
        if (count < 5)
        {
            q[count++] = x;
            if (count == 5)
            {
                Array.Sort(q);

                for (int i = 0; i < 5; i++)
                    n[i] = i;

                ns[0] = 0;
                ns[1] = 2 * p;
                ns[2] = 4 * p;
                ns[3] = 2 + 2 * p;
                ns[4] = 4;

                dns[0] = 0;
                dns[1] = p / 2;
                dns[2] = p;
                dns[3] = (1 + p) / 2;
                dns[4] = 1;
            }

            return;
        }

        int k;
        if (x < q[0])
        {
            q[0] = x;
            k = 0;
        }
        else if (x < q[1])
            k = 0;
        else if (x < q[2])
            k = 1;
        else if (x < q[3])
            k = 2;
        else if (x < q[4])
            k = 3;
        else
        {
            q[4] = x;
            k = 3;
        }

        for (int i = k + 1; i < 5; i++)
            n[i]++;
        for (int i = 0; i < 5; i++)
            ns[i] += dns[i];

        for (int i = 1; i <= 3; i++)
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

        count++;
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
        if (count == 0)
            throw new InvalidOperationException("Sequence contains no elements");
        if (count <= 5)
        {
            Array.Sort(q, 0, count);
            int index = (int)Math.Round((count - 1) * p);
            return q[index];
        }

        return q[2];
    }
}

public class P2QuantileEstimatorPatched
{
    private readonly double p;
    private readonly int[] n = new int[5]; // marker positions
    private readonly double[] ns = new double[5]; // desired marker positions
    private readonly double[] q = new double[5]; // marker heights
    private int count;

    public P2QuantileEstimatorPatched(double probability)
    {
        p = probability;
    }

    public void AddValue(double x)
    {
        if (count < 5)
        {
            q[count++] = x;
            if (count == 5)
            {
                Array.Sort(q);

                for (int i = 0; i < 5; i++)
                    n[i] = i;

                ns[0] = 0;
                ns[1] = 2 * p;
                ns[2] = 4 * p;
                ns[3] = 2 + 2 * p;
                ns[4] = 4;
            }

            return;
        }

        int k;
        if (x < q[0])
        {
            q[0] = x;
            k = 0;
        }
        else if (x < q[1])
            k = 0;
        else if (x < q[2])
            k = 1;
        else if (x < q[3])
            k = 2;
        else if (x < q[4])
            k = 3;
        else
        {
            q[4] = x;
            k = 3;
        }

        for (int i = k + 1; i < 5; i++)
            n[i]++;
        ns[1] = count * p / 2;
        ns[2] = count * p;
        ns[3] = count * (1 + p) / 2;
        ns[4] = count;

        for (int i = 1; i <= 3; i++)
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

        count++;
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
        if (count == 0)
            throw new InvalidOperationException("Sequence contains no elements");
        if (count <= 5)
        {
            Array.Sort(q, 0, count);
            int index = (int)Math.Round((count - 1) * p);
            return q[index];
        }

        return q[2];
    }
}
```

The main change is replacing

```cs
for (int i = 0; i < 5; i++)
    ns[i] += dns[i];
```

by

```cs
ns[1] = count * p / 2;
ns[2] = count * p;
ns[3] = count * (1 + p) / 2;
ns[4] = count;
```

Now let's benchmark it using [BenchmarkDotNet](https://github.com/dotnet/BenchmarkDotNet):

```cs
[LongRunJob]
public class P2Benchmarks
{
    [Benchmark]
    public void Original()
    {
        var estimator = new P2QuantileEstimatorOriginal(0.5);
        for (int i = 0; i < 1_000_000; i++)
            estimator.AddValue(i);
    }

    [Benchmark]
    public void Patched()
    {
        var estimator = new P2QuantileEstimatorPatched(0.5);
        for (int i = 0; i < 1_000_000; i++)
            estimator.AddValue(i);
    }
}

class Program
{
    static void Main()
    {
        BenchmarkRunner.Run<P2Benchmarks>();
    }
}
```

Here are the benchmark results:

```md
BenchmarkDotNet=v0.13.1, OS=Windows 10.0.19042.1288 (20H2/October2020Update)
Intel Core i7-7700K CPU 4.20GHz (Kaby Lake), 1 CPU, 8 logical and 4 physical cores
.NET SDK=5.0.300
  [Host]  : .NET 5.0.6 (5.0.621.22011), X64 RyuJIT
  LongRun : .NET 5.0.6 (5.0.621.22011), X64 RyuJIT

|   Method |     Mean |    Error |   StdDev |
|--------- |---------:|---------:|---------:|
| Original | 24.47 ms | 0.028 ms | 0.138 ms |
|  Patched | 21.72 ms | 0.026 ms | 0.133 ms |
```

As we can see, the `Patched` version works even faster than the `Original`.
Of course, the difference in performance could be explained
  by the manual loop unrolling and decreasing the number of operations
  (we do not update $n'_0$ in `Patched` since $dn'_0 = 0$).
Of course, further optimizations are possible.
The current implementation doesn't aim to be the fastest one, it aims to be the readable one.
The most important thing here is that the patch doesn't lead to a performance regression.
Meanwhile, it also reduces the memory overhead (we shouldn't keep the `dns` array with five `double` elements anymore).

Now it's time to check the impact on the estimator result.
Let's consider the following code snippet:

```cs
var random = new Random(1729);
var original = new P2QuantileEstimatorOriginal(0.6);
var patched = new P2QuantileEstimatorPatched(0.6);
for (int i = 0; i < 100; i++)
{
    var x = random.NextDouble();
    original.AddValue(x);
    patched.AddValue(x);
}

Console.WriteLine("Original : " + original.GetQuantile());
Console.WriteLine("Patched  : " + patched.GetQuantile());
```

Here is the corresponding output:

```md
Original : 0.6094896389457989
Patched  : 0.6053711159656534
```

As we can see, the difference is noticeable.

### Conclusion

The suggested change:
* Improves performance keeping the same readability level
* Reduces memory overhead
* Fixes the internal calculations

Thus, I have decided to
  [update](https://github.com/AndreyAkinshin/perfolizer/commit/4e40b500e60486a19b977b73974b79621d871078)
  the corresponding implementation in perfolizer.
The fix is available in perfolizer v0.3.0-nightly.106+.
Here is the updated copy-pastable version of the reference implementation:

```cs
public class P2QuantileEstimator
{
    private readonly double p;
    private readonly int[] n = new int[5]; // marker positions
    private readonly double[] ns = new double[5]; // desired marker positions
    private readonly double[] q = new double[5]; // marker heights
    private int count;

    public P2QuantileEstimator(double probability)
    {
        p = probability;
    }

    public void AddValue(double x)
    {
        if (count < 5)
        {
            q[count++] = x;
            if (count == 5)
            {
                Array.Sort(q);

                for (int i = 0; i < 5; i++)
                    n[i] = i;

                ns[0] = 0;
                ns[1] = 2 * p;
                ns[2] = 4 * p;
                ns[3] = 2 + 2 * p;
                ns[4] = 4;
            }

            return;
        }

        int k;
        if (x < q[0])
        {
            q[0] = x;
            k = 0;
        }
        else if (x < q[1])
            k = 0;
        else if (x < q[2])
            k = 1;
        else if (x < q[3])
            k = 2;
        else if (x < q[4])
            k = 3;
        else
        {
            q[4] = x;
            k = 3;
        }

        for (int i = k + 1; i < 5; i++)
            n[i]++;
        ns[1] = count * p / 2;
        ns[2] = count * p;
        ns[3] = count * (1 + p) / 2;
        ns[4] = count;

        for (int i = 1; i <= 3; i++)
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

        count++;
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
        if (count == 0)
            throw new InvalidOperationException("Sequence contains no elements");
        if (count <= 5)
        {
            Array.Sort(q, 0, count);
            int index = (int)Math.Round((count - 1) * p);
            return q[index];
        }

        return q[2];
    }
}
```