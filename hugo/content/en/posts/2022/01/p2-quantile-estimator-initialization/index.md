---
title: P² quantile estimator initialization strategy
date: 2022-01-04
tags:
- mathematics
- statistics
- research
- research-p2qe
features:
- math
---

**Update: the estimator accuracy could be improved using a bunch of [patches]({{< ref research-p2qe >}}).**

The P² quantile estimator is a sequential estimator that uses $O(1)$ memory.
Thus, for the given sequence of numbers, it allows estimating quantiles without storing values.
I have already written a few blog posts about it:

* {{< link p2-quantile-estimator >}}
* {{< link p2-quantile-estimator-rounding-issue >}}

I tried this estimator in various contexts, and it shows pretty decent results.
However, recently I stumbled on a corner case:
  if we want to estimate extreme quantile ($p < 0.1$ or $p > 0.9$),
  this estimator provides inaccurate results on small number streams ($n < 10$).
While it looks like a minor issue, it would be nice to fix it.
In this post, we briefly discuss choosing a better initialization strategy to workaround this problem.

<!--more-->

### The problem

I assume that you have already read the [original post]({{< ref p2-quantile-estimator >}})
  and understand the approach behind P² quantile estimator.
Once we observed the first five elements, the original paper [[Jain1985]](#Jain1985) suggests
  using the following initial values:

$$
\left\{
\begin{array}{lll}
n'_0 = 0,      & n_0 = 0, & q_0 = x_{(0)},\\
n'_1 = 2p,     & n_1 = 1, & q_1 = x_{(1)},\\
n'_2 = 4p,     & n_2 = 2, & q_2 = x_{(2)},\\
n'_3 = 2 + 2p, & n_3 = 3, & q_3 = x_{(3)},\\
n'_4 = 4,      & n_4 = 4, & q_4 = x_{(4)}.
\end{array}
\right.
$$

Thus, the initial value of $q_2$ (which holds our current estimation of the target quantile)
  is the sample median of the first five elements.
It's a good estimation for $p=0.5$.
Unfortunately, in the extreme cases ($p < 0.1$ or $p > 0.9$) such an estimation is not accurate.
This inaccuracy is not noticeable after processing a huge number of stream elements (e.g., $n > 100$),
  but it leads to confusing results on small samples ($n < 10$).

### The solution

Since we know the desired marker positions $n'_i$, let's choose our initial marker parameters
  according to these positions:

$$
\left\{
\begin{array}{lll}
n'_0 = 0,      & n_0 = \lfloor n'_0 \rceil, & q_0 = x_{(n_0)},\\
n'_1 = 2p,     & n_1 = \lfloor n'_1 \rceil, & q_1 = x_{(n_1)},\\
n'_2 = 4p,     & n_2 = \lfloor n'_2 \rceil, & q_2 = x_{(n_2)},\\
n'_3 = 2 + 2p, & n_3 = \lfloor n'_3 \rceil, & q_3 = x_{(n_3)},\\
n'_4 = 4,      & n_4 = \lfloor n'_4 \rceil, & q_4 = x_{(n_4)},
\end{array}
\right.
$$

where $\lfloor n'_i \rceil$ is the rounding operator.

### New Reference Implementation

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

    public P2QuantileEstimator(double probability, InitializationStrategy strategy = InitializationStrategy.Classic)
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

        Count++;
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

### Simulation study

Now let's perform the following experiment.
We enumerate different distributions (the standard uniform, the standard normal, the Gumbel),
  different sample sizes (6, 7, 8),
  and different quantile probabilities (0.05, 0.1, 0.2, 0.8, 0.9, 0.95).
For each combination of the input parameters, we perform 10000 simulations of the sample experiment:
  generate a random sample of the given size from the given distribution
  and estimate the given quantile using the classic initialization strategy and
  the new adaptive initialization strategy.
As a baseline, we use the traditional Hyndman-Fan Type 7 quantile estimator.
The initialization strategy that gives a better estimation (compared to the baseline)
  is the "winner" of the corresponding experiment.
For each combination of the input parameters, we calculate the percentage of wins for each strategy.
Here is the source code of this simulation:

```cs
var random = new Random(1729);

var distributions = new IContinuousDistribution[]
{
    new UniformDistribution(0, 1),
    new NormalDistribution(0, 1),
    new GumbelDistribution()
};

Console.WriteLine("                 Classic Adaptive");
foreach (int n in new[] { 6, 7, 8 })
foreach (var probability in new Probability[] { 0.05, 0.1, 0.2, 0.8, 0.9, 0.95 })
foreach (var distribution in distributions)
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

And here are the results:

```txt
                 Classic Adaptive
Uniform P5  N6 :   1.31%  98.69%
Normal  P5  N6 :   1.86%  98.14%
Gumbel  P5  N6 :   1.63%  98.37%
Uniform P10 N6 :   2.61%  97.39%
Normal  P10 N6 :   3.60%  96.40%
Gumbel  P10 N6 :   3.27%  96.73%
Uniform P20 N6 :  12.05%  87.95%
Normal  P20 N6 :  14.20%  85.80%
Gumbel  P20 N6 :  13.16%  86.84%
Uniform P80 N6 :   0.96%  99.04%
Normal  P80 N6 :   1.45%  98.55%
Gumbel  P80 N6 :   2.58%  97.42%
Uniform P90 N6 :   0.00% 100.00%
Normal  P90 N6 :   0.00% 100.00%
Gumbel  P90 N6 :   0.00% 100.00%
Uniform P95 N6 :   0.00% 100.00%
Normal  P95 N6 :   0.00% 100.00%
Gumbel  P95 N6 :   0.00% 100.00%
Uniform P5  N7 :   4.38%  95.62%
Normal  P5  N7 :   5.48%  94.52%
Gumbel  P5  N7 :   5.34%  94.66%
Uniform P10 N7 :  16.04%  83.96%
Normal  P10 N7 :  21.63%  78.37%
Gumbel  P10 N7 :  18.08%  81.92%
Uniform P20 N7 :  24.15%  75.85%
Normal  P20 N7 :  27.10%  72.90%
Gumbel  P20 N7 :  26.10%  73.90%
Uniform P80 N7 :  10.73%  89.27%
Normal  P80 N7 :  13.36%  86.64%
Gumbel  P80 N7 :  13.17%  86.83%
Uniform P90 N7 :  10.07%  89.93%
Normal  P90 N7 :  14.74%  85.26%
Gumbel  P90 N7 :  17.34%  82.66%
Uniform P95 N7 :   1.26%  98.74%
Normal  P95 N7 :   1.58%  98.42%
Gumbel  P95 N7 :   1.89%  98.11%
Uniform P5  N8 :   7.54%  92.46%
Normal  P5  N8 :   9.58%  90.42%
Gumbel  P5  N8 :   8.44%  91.56%
Uniform P10 N8 :  23.83%  76.17%
Normal  P10 N8 :  32.72%  67.28%
Gumbel  P10 N8 :  28.00%  72.00%
Uniform P20 N8 :  35.11%  64.89%
Normal  P20 N8 :  39.02%  60.98%
Gumbel  P20 N8 :  37.02%  62.98%
Uniform P80 N8 :  24.83%  75.17%
Normal  P80 N8 :  28.79%  71.21%
Gumbel  P80 N8 :  29.60%  70.40%
Uniform P90 N8 :  18.42%  81.58%
Normal  P90 N8 :  24.63%  75.37%
Gumbel  P90 N8 :  28.92%  71.08%
Uniform P95 N8 :   4.25%  95.75%
Normal  P95 N8 :   4.98%  95.02%
Gumbel  P95 N8 :   5.51%  94.49%
```

As we can see, the new "adaptive" strategy shows much better results than the classic one.

### References

* <b id="Jain1985">[Jain1985]</b>  
  Jain, Raj, and Imrich Chlamtac.
  "The P² algorithm for dynamic calculation of quantiles and histograms without storing observations."
  Communications of the ACM 28, no. 10 (1985): 1076-1085.  
  https://doi.org/10.1145/4372.4378
