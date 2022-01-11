---
title: P² quantile estimator marker adjusting order
date: 2022-01-11
tags:
- Statistics
- research-p2qe
features:
- math
---

I have already written a few blog posts about the P² quantile estimator
  (which is a sequential estimator that uses $O(1)$ memory):

* {{< link p2-quantile-estimator >}}
* {{< link p2-quantile-estimator-rounding-issue >}}
* {{< link p2-quantile-estimator-initialization >}}

In this post, we continue improving the P² implementation
  so that it gives better estimations for streams with a small number of elements.

<!--more-->

### The problem

In the [previous post]({{< ref p2-quantile-estimator-initialization >}}),
  I have performed the following experiment:

> We enumerate different distributions (the standard uniform, the standard normal),
>   different sample sizes (6, 7, 8),
>   and different quantile probabilities (0.05, 0.1, 0.2, 0.8, 0.9, 0.95).
> For each combination of the input parameters, we perform 10000 simulations of the sample experiment:
>   generate a random sample of the given size from the given distribution
>   and estimate the given quantile using the classic initialization strategy and
>   the new adaptive initialization strategy.
> As a baseline, we use the traditional Hyndman-Fan Type 7 quantile estimator.
> The initialization strategy that gives a better estimation (compared to the baseline)
>   is the "winner" of the corresponding experiment.
> For each combination of the input parameters, we calculate the percentage of wins for each strategy.

Here is the source code of this simulation:

```cs
var random = new Random(1729);

var distributions = new IContinuousDistribution[]
{
    new UniformDistribution(0, 1),
    new NormalDistribution(0, 1)
};

Console.WriteLine("                 Classic Adaptive");
foreach (var distribution in distributions)
foreach (int n in new[] { 6, 7, 8 })
foreach (var probability in new Probability[] { 0.05, 0.1, 0.2, 0.8, 0.9, 0.95 })
{
    var randomGenerator = distribution.Random(random);
    const int totalIterations = 10_000;
    int classicIsWinner = 0;
    for (int iteration = 0; iteration < totalIterations; iteration++)
    {
        var p2ClassicEstimator = new P2QuantileEstimator(probability, P2QuantileEstimator.InitializationStrategy.Classic);
        var p2AdaptiveEstimator = new P2QuantileEstimator(probability, P2QuantileEstimator.InitializationStrategy.Adaptive);
        var values = new List<double>();
        for (int i = 0; i < n; i++)
        {
            double x = randomGenerator.Next();
            values.Add(x);
            p2ClassicEstimator.Add(x);
            p2AdaptiveEstimator.Add(x);
        }

        double simpleEstimation = SimpleQuantileEstimator.Instance.GetQuantile(values, probability);
        double p2ClassicEstimation = p2ClassicEstimator.GetQuantile();
        double p2AdaptiveEstimation = p2AdaptiveEstimator.GetQuantile();
        if (Math.Abs(p2ClassicEstimation - simpleEstimation) < Math.Abs(p2AdaptiveEstimation - simpleEstimation))
            classicIsWinner++;
    }

    int adaptiveIsWinner = totalIterations - classicIsWinner;
    
    string title =  distribution.GetType().Name.Replace("Distribution", "").PadRight(7) + " " + 
                    "P" + (probability * 100).ToString().PadRight(2) + " " + 
                    "N" + n;
    Console.WriteLine($"{title,-15}: {classicIsWinner / 100.0,6:N2}% {(adaptiveIsWinner / 100.0),6:N2}%");
}
```

I got the following results for the Uniform and the Normal distributions:

```txt
                 Classic Adaptive
Uniform P5  N6 :   1.31%  98.69%
Uniform P10 N6 :   2.62%  97.38%
Uniform P20 N6 :  11.44%  88.56%
Uniform P80 N6 :   0.97%  99.03%
Uniform P90 N6 :   0.00% 100.00%
Uniform P95 N6 :   0.00% 100.00%

Uniform P5  N7 :   4.00%  96.00%
Uniform P10 N7 :  14.68%  85.32%
Uniform P20 N7 :  24.52%  75.48%
Uniform P80 N7 :  10.41%  89.59%
Uniform P90 N7 :  10.31%  89.69%
Uniform P95 N7 :   1.14%  98.86%

Uniform P5  N8 :   7.50%  92.50%
Uniform P10 N8 :  22.87%  77.13%
Uniform P20 N8 :  35.12%  64.88%
Uniform P80 N8 :  24.98%  75.02%
Uniform P90 N8 :  17.81%  82.19%
Uniform P95 N8 :   3.94%  96.06%

Normal  P5  N6 :   1.73%  98.27%
Normal  P10 N6 :   3.80%  96.20%
Normal  P20 N6 :  13.93%  86.07%
Normal  P80 N6 :   1.55%  98.45%
Normal  P90 N6 :   0.00% 100.00%
Normal  P95 N6 :   0.00% 100.00%

Normal  P5  N7 :   5.86%  94.14%
Normal  P10 N7 :  21.15%  78.85%
Normal  P20 N7 :  27.72%  72.28%
Normal  P80 N7 :  12.34%  87.66%
Normal  P90 N7 :  14.50%  85.50%
Normal  P95 N7 :   1.54%  98.46%

Normal  P5  N8 :   9.18%  90.82%
Normal  P10 N8 :  32.63%  67.37%
Normal  P20 N8 :  38.88%  61.12%
Normal  P80 N8 :  28.81%  71.19%
Normal  P90 N8 :  25.45%  74.55%
Normal  P95 N8 :   4.92%  95.08%
```

Since both the Normal and the Uniform distributions are symmetric,
  we could expect symmetric results.
However, the result table is asymmetric:
  the obtained numbers for P5/P10/P20 don't match the corresponding numbers for P80/P90/P95.

### The solution

The final stage of the P² quantile estimator suggest adjusting
  non-extreme marker heights ($q_i$) and positions ($n_i$) for $i \in \{ 1, 2, 3\} $
  (see the [algorithm description]({{< ref "p2-quantile-estimator#marker-invalidation" >}})
  and the original paper [[Jain1985]](#Jain1985) for details):

```cs
for (i = 1; i <= 3; i++)
{
    d = nꞌ[i] - n[i]
    if (d >=  1 && n[i + 1] - n[i] >  1 ||
        d <= -1 && n[i - 1] - n[i] < -1)
    {
        d = sign(d)
        qꞌ = Parabolic(i, d)
        if (!(q[i - 1] < qꞌ && qꞌ < q[i + 1]))
            qꞌ = Linear(i, d)
        q[i] = qꞌ
        n[i] += d
    }
}
```

The core equation of the algorithm is a piecewise-parabolic prediction (P²) formula
  that adjusts marker heights for each observation:

$$
q'_i = q_i + \dfrac{d}{n_{i+1}-n_{i-1}} \cdot
  \Bigg(
    (n_i-n_{i-1}+d)\dfrac{q_{i+1}-q_i}{n_{i+1}-n_i} +
    (n_{i+1}-n_i-d)\dfrac{q_i-q_{i-1}}{n_i-n_{i-1}}
  \Bigg).
$$

Once we calculated $q'_i$, we should check that $q_{i-1} < q'_i < q_{i+1}$.
If this condition is false, we should ignore the parabolic prediction and use the linear prediction instead:

$$
q'_i = q_i + d \dfrac{q_{i+d}-q_i}{n_{i+d}-n_{i}}.
$$

The problem arises when the number of elements in a stream is small and we use
  [an adjusted initialization strategy]({{< ref p2-quantile-estimator-initialization >}}).
Since we could have collisions across $\{ n_i \}$,
  the order of adjusting is important.
Currently, it's optimal only for higher quantiles ($p > 0.5$), but not for lower quantiles ($p < 0.5$).
Let's extract the adjusting logic from the above snippet to named method:

```cs
for (i = 1; i <= 3; i++)
    Adjust(i);
```

Now it's easy to introduce an adaptive adjusting order depending on the value of $p$:

```cs
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
```

if we run the simulation from the beginning of the post, we get the following result:

```txt
                 Classic Adaptive
Uniform P5  N6 :   0.00% 100.00%
Uniform P10 N6 :   0.00% 100.00%
Uniform P20 N6 :   0.84%  99.16%
Uniform P80 N6 :   0.97%  99.03%
Uniform P90 N6 :   0.00% 100.00%
Uniform P95 N6 :   0.00% 100.00%

Uniform P5  N7 :   1.19%  98.81%
Uniform P10 N7 :   9.47%  90.53%
Uniform P20 N7 :  10.77%  89.23%
Uniform P80 N7 :  10.41%  89.59%
Uniform P90 N7 :  10.31%  89.69%
Uniform P95 N7 :   1.14%  98.86%

Uniform P5  N8 :   3.91%  96.09%
Uniform P10 N8 :  17.48%  82.52%
Uniform P20 N8 :  25.13%  74.87%
Uniform P80 N8 :  24.98%  75.02%
Uniform P90 N8 :  17.81%  82.19%
Uniform P95 N8 :   3.94%  96.06%

Normal  P5  N6 :   0.00% 100.00%
Normal  P10 N6 :   0.00% 100.00%
Normal  P20 N6 :   1.63%  98.37%
Normal  P80 N6 :   1.55%  98.45%
Normal  P90 N6 :   0.00% 100.00%
Normal  P95 N6 :   0.00% 100.00%

Normal  P5  N7 :   1.81%  98.19%
Normal  P10 N7 :  13.87%  86.13%
Normal  P20 N7 :  12.85%  87.15%
Normal  P80 N7 :  12.34%  87.66%
Normal  P90 N7 :  14.50%  85.50%
Normal  P95 N7 :   1.54%  98.46%

Normal  P5  N8 :   4.84%  95.16%
Normal  P10 N8 :  25.05%  74.95%
Normal  P20 N8 :  28.43%  71.57%
Normal  P80 N8 :  28.81%  71.19%
Normal  P90 N8 :  25.45%  74.55%
Normal  P95 N8 :   4.92%  95.08%
```

Now it looks quite symmetric.
The problem is solved!

### The updated reference implementation

```cs
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
}
```

### References

* <b id="Jain1985">[Jain1985]</b>  
  Jain, Raj, and Imrich Chlamtac.
  "The P² algorithm for dynamic calculation of quantiles and histograms without storing observations."
  Communications of the ACM 28, no. 10 (1985): 1076-1085.  
  https://doi.org/10.1145/4372.4378
