---
title: Improving the efficiency of the Harrell-Davis quantile estimator for special cases using custom winsorizing and trimming strategies
date: 2021-05-25
tags:
- Statistics
- Statistical efficiency
- Harrell-Davis quantile estimator
- Winsorizing
- Trimming
- Small samples
features:
- math
---

Let's say we want to
  **estimate the median**
  based on a **small sample** (3 $\leq n \leq 7$)
  from a **right-skewed heavy-tailed distribution**
  with **high statistical efficiency**.

The traditional median estimator is the most robust estimator, but it's not the most efficient one.
Typically, the Harrell-Davis quantile estimator provides better efficiency,
  but it's not robust (its breakdown point is zero),
  so it may have worse efficiency in the given case.
The [winsorized]({{< ref winsorized-hdqe >}}) and [trimmed]({{< ref trimmed-hdqe >}})
  modifications of the Harrell-Davis quantile estimator provide a good trade-off
  between efficiency and robustness, but they require a proper winsorizing/trimming rule.
A reasonable choice of such a rule for medium-size samples is based on the highest density interval of the Beta function
  (as described [here]({{< ref winsorized-hdqe >}})).
Unfortunately, this approach may be suboptimal for small samples.
E.g., if we use the 99% highest density interval to estimate the median,
  it starts to trim sample values only for $n \geq 8$.

In this post, we are going to discuss custom winsorizing/trimming strategies for special cases of the quantile estimation problem.

<!--more-->

### Beware of small samples

So, what's wrong with the small samples from heavy-tailed distributions?
There is a high chance to observe an extremely large value in such a sample.
As an example, let's consider the Pareto distribution.
Here is the PDF for $\textrm{Pareto}(x_m = 1, \alpha = 1)$:

{{< imgld pareto-pdf >}}

The quantile function for the Pareto distribution is defined as follows:

$$
Q_\textrm{Pareto}(p) = x_m (1 - p)^{(-1/\alpha)}
$$

In our case ($x_m = 1, \alpha = 1$), we have:

$$
Q_{\textrm{Pareto}(x_m = 1,\;\alpha = 1)}(p) = \frac{1}{1 - p}
$$

Here are some of the quantile values:

```txt
q[0.500] = 2
q[0.750] = 4
q[0.900] = 10
q[0.950] = 20
q[0.990] = 100
q[0.999] = 1000
```

Thus, while the median value is $2$, the value of the $99.9^\textrm{th}$ percentile is 1000.
It may look like a small probability, but this impression is deceiving.
For example, if we consider 5000 values (or 1000 of 5-element samples),
  there is a 99.3% chance that at least one of the values is higher than 1000.

### The problem of the Harrell-Davis quantile estimator

The Harrell-Davis approach suggests estimating the quantile value as a weighted sum of all sample elements
  where all weight values are positive.
Thus, its breakdown point is zero: a single "extreme" value may "corrupt" the estimation.
Let's say we have the following sample from $\textrm{Pareto}(x_m = 1, \alpha = 1)$:

$$
x = \{ 1, 2, 1000 \}
$$

The traditional median estimator just selects the middle element.
In our case, it gives

$$
Q_\textrm{Traditional}(x) = x_2 = 2
$$

which is a pretty accurate median estimation.
The Harrell-Davis quantile estimator produces a worse estimation:

$$
Q_\textrm{HD}(x) \approx 0.259259\cdot x_1 + 0.481481\cdot x_2 + 0.259259\cdot x_3 \approx 260.481.
$$

The Harrell-Davis quantile estimator is a good approach in many cases because it typically provides better efficiency
  then the traditional one.
Unfortunately, in the considered case (small samples form heavy-tailed distribution),
  its efficiency is quite bad because it's not robust enough.
Let's try to fix this problem.

### Smart winsorizing/trimming

If we want to improve the Harrell-Davis quantile estimator robustness,
  we can consider its [winsorized]({{< ref winsorized-hdqe >}}) and [trimmed]({{< ref trimmed-hdqe >}}) modifications.
In one of the previous posts, I [described]({{< ref winsorized-hdqe >}}) an approach
  that selects the trimming percentage based on the highest density interval of the corresponding beta function.
It works great for medium-size samples, but it's useless for small samples.
If we use the 99% highest density interval to estimate the median,
  the trimming percentage will be positive only for $n \geq 8$.

In our case, we can consider a custom trimming strategy.
Our greatest enemy here is the random extreme values.
We want to trim them whenever it's possible.

Let's consider a sample $x$ with $n$ elements where all the samples elements are already sorted:

$$
x_1 \leq x_2 \leq \ldots \leq x_n.
$$

Now let's discuss how we should trim the samples for different $n$ values:

* $n=3$  
  It's not a good idea to trim $x_2$ because it's our traditional median estimation.
  It's also doesn't make sense to trim $x_1$ because the considered distribution is right-skewed
    ($x_1$ is the minimum element of the sample; it has the smallest chance to be "extreme").
  Thus, the reasonable decision is to trim $x_3$.
* $n=4$  
  The traditional median estimator for samples with even size uses two middle elements.
  For $n=4$, these elements are $x_2$ and $x_3$, so we don't want to trim them.
  It's still useless to trim $x_1$, so our only option is to trim $x_4$.
* $n=5$  
  Here the traditional median estimator uses only $x_3$.
  So, we can trim two elements: $x_4$ and $x_5$.
* $n=6$  
  By analogy, we can trim $x_5$ and $x_6$.
* $n=7$  
  Here the traditional median estimator uses only $x_4$.
  Thus, we can trim three elements: $x_5$, $x_6$, and $x_7$.

This strategy can be described using the following scheme
  (`@` denotes non-trimmed element; `x` denotes trimmed element; assuming sorted sample):

```txt
n = 3: @@x
n = 4: @@@x
n = 5: @@@xx
n = 6: @@@@xx
n = 7: @@@@xxx
```

It's time to check how it works.

### Numerical simulation

We are going to compare four quantile estimators:

* `hf7`: the traditional quantile estimator (also known as the Hyndman-Fan Type 7)
* `hd`: the Harrell-Davis quantile estimator
* `whd`: the winsorized Harrell-Davis quantile estimator where
    the winsorized elements are defined according to the scheme from the previous section
* `thd`: the trimmed Harrell-Davis quantile estimator where
    the trimmed elements are defined according to the scheme from the previous section

Typically, the estimator efficiency is evaluated using the mean squared error (`mse`) and the bias.
This approach works good for light-tailed error distribution,
  but it could be misleading for heavy-tailed distribution.
Thus, in addition to the classic bias and mse metric,
  we also consider different percentiles of the absolute values of simulated errors.
Also, we are going to draw the PDF of the error distributions.
Each error distribution is based on 100'000 random samples.

In this simulation, we are going to estimate the median for the normal distribution (the true median value is $0$)
  and for $\textrm{Pareto}(x_m = 1, \alpha = 1)$ (the true median value is $2$).


#### Normal distribution (n = 5)

Let's start with the normal distribution (which is symmetric and light-tailed) to do a dry-check of our estimators.

{{< imgld normal5 >}}

```js
 estimator   bias    mse    p25    p50    p75    p90    p95    p99
       hf7 1.9989 4.2806 1.6406 1.9986 2.3571 2.6808 2.8774 3.2498
        hd 1.9983 4.2088 1.6835 2.0003 2.3115 2.5946 2.7598 3.0799
       whd 2.1971 5.0761 1.8597 2.1935 2.5307 2.8371 3.0237 3.3723
       thd 2.2851 5.4642 1.9532 2.2805 2.6133 2.9198 3.1023 3.4480
```

As we can see, `hf7` and `hd` give pretty similar results.
In this particular case, `whd` and `thd` give worse results (but they are still pretty acceptable)
It's an expected situation because our winsorizing/trimming strategy is "overfitted" to the right-skewed case
  while the actual distribution is symmetric.

#### Pareto distribution (n = 3)

Now it's time to check our estimators on the most complicated case:
  we should guess the median value of $\textrm{Pareto}(x_m = 1, \alpha = 1)$
  based only on three elements!

{{< imgld pareto3 >}}

```js
 estimator   bias       mse     p25     p50     p75    p90     p95    p99
       hf7 1.5123    62.215 0.32717 0.63312 1.06588 3.1005  5.3714 15.368
        hd 8.9820 53457.769 0.37791 0.82852 2.94861 8.5900 17.2297 82.489
       whd 1.1791    13.033 0.32245 0.61093 0.89666 2.2888  3.9940 11.355
       thd 1.0959    10.468 0.32505 0.60616 0.87402 2.0557  3.6763 10.116
```

Expectedly, `hd` has the worst error values because of its zero breakdown point.
Meanwhile, `whd` and `thd` have better error values than `hf7` (which is our baseline).
They are better not only based on the "classic" `bias` and `mse` metrics but only based on all the percentile values.

Let's see what happens for higher $n$ values.

#### Pareto distribution (n = 4)

{{< imgld pareto4 >}}

```js
 estimator   bias        mse     p25     p50    p75    p90     p95    p99
       hf7 1.3685     17.729 0.28709 0.58347 1.2009 3.0084  4.9603 12.553
        hd 8.9832 341193.607 0.35421 0.82811 2.6347 6.9242 13.0648 55.666
       whd 1.3481     75.375 0.28768 0.57450 1.1052 2.8478  4.7321 12.135
       thd 1.2203    159.813 0.27968 0.55621 0.9480 2.5127  4.1917 10.584
```

#### Pareto distribution (n = 5)

{{< imgld pareto5 >}}

```js
 estimator    bias        mse     p25     p50     p75    p90    p95     p99
       hf7 0.93476 3.6081e+00 0.26418 0.52748 0.85761 2.0465 3.2767  7.5615
        hd 6.89114 9.5374e+05 0.32004 0.74949 2.20399 5.3076 9.3283 34.6076
       whd 0.75266 1.9533e+00 0.26330 0.51288 0.77389 1.4601 2.3995  5.3516
       thd 0.67432 1.3032e+00 0.26495 0.50669 0.75081 1.1632 1.9720  4.4307
```

#### Pareto distribution (n = 6)

{{< imgld pareto6 >}}

```js
 estimator    bias       mse     p25     p50     p75    p90    p95     p99
       hf7 0.86396    3.1662 0.24138 0.49037 0.84813 1.9343 3.0090  6.4052
        hd 2.45124 1146.6008 0.29475 0.67508 1.83344 4.1168 6.7717 21.5434
       whd 0.80034    2.5351 0.23669 0.47788 0.78792 1.7473 2.7498  5.8945
       thd 0.70381    1.6713 0.23367 0.46480 0.73381 1.4345 2.2906  4.9982
```

#### Pareto distribution (n = 7)

{{< imgld pareto7 >}}

```js
 estimator    bias        mse     p25     p50     p75     p90    p95     p99
       hf7 0.72789 1.7341e+00 0.22666 0.46096 0.75719 1.58315 2.4422  5.0349
        hd 3.81677 4.7061e+05 0.25941 0.58495 1.49718 3.19833 4.9741 12.9881
       whd 0.59597 9.2458e-01 0.22620 0.44712 0.68831 1.09442 1.7404  3.6767
       thd 0.54333 6.5777e-01 0.23242 0.44939 0.67056 0.88692 1.3906  2.9339
```

### Conclusion

In this post, we performed a numerical simulation that compared the statistical efficiency
  of the median estimation on small samples from right-skewed heavy-tailed distributions.
We compared four quantile estimators:
  the traditional one (also known as the Hyndman-Fan Type 7),
  the Harrell-Davis quantile estimator,
  and its winsorized/trimming modifications that use a custom trimming strategy optimized for the given case.
Based on the simulation results, we can conclude that the **trimmed modification is the clear winner**.