---
title: Efficiency of the central tendency measures under the uniform distribution
description: Calculation of the relative efficiency of the median, the Hodges-Lehmann location estimator, and the midrange to the mean under uniformity
date: 2023-05-16
thumbnail: eff-dark
tags:
- mathematics
- statistics
- research
- hodges-lehmann
features:
- math
---

Statistical efficiency is one of the primary ways to compare various estimators.
Since the normality assumption is often used, Gaussian efficiency (efficiency under the normality distribution)
  is typically considered.
For example, the asymptotic Gaussian efficiency values of
  the median and the Hodges-Lehmann location estimator (the pseudo-median)
  are $\approx 64\%$ and $\approx 96\%$ respectively (assuming the baseline is the mean).

But what if the underlying distribution is not normal, but uniform?
What would happen to the relative statistical efficiency values in this case?
Let's find out!
In this post, we calculate
  the relative efficiency of the median, the Hodges-Lehmann location estimator, and the midrange
  to the mean under the uniform distribution (or under uniformity).

<!--more-->

### The statistical efficiency

Let $\mathbf{x}$ be a sample of n elements: $\mathbf{x} = \{ x_1, x_2, \ldots, x_n \}$.
In this case study, we consider the below estimators.

$$
\operatorname{Mean}_n(\mathbf{x}) = \frac{x_1 + x_2 + \ldots + x_n}{n},
$$

$$
\operatorname{Median}_n(\mathbf{x}) = \begin{cases}
x_{((n+1)/2)} & \textrm{if } n \textrm{ is odd}, \\
\left(x_{(n/2)}+x_{(n/2+1)}\right)/2 & \textrm{if } n \textrm{ is even} ,\\
\end{cases}
$$

$$
\operatorname{HodgesLehmann}_n(\mathbf{x}) =
  \underset{1 \leq i \leq j \leq n}{\operatorname{Median}} \left(\frac{x_i + x_j}{2} \right),
$$

$$
\operatorname{Midrange}_n(\mathbf{x}) =
  \frac{\min(x) + \max(x)}{2}.
$$

We also consider the standard uniform distribution $\mathcal{U}(0, 1)$.
Since this distribution is symmetric, all the above estimators are unbiased.
Therefore, the relative statistical efficiency $\operatorname{e}$ of an estimator $T_n$ to the mean
  can be estimated as the ratio of the variances of the sampling distributions:

$$
\operatorname{e}(T_n) = \frac{\mathbb{V}[\operatorname{Mean}_n]}{\mathbb{V}[T_n]}.
$$

### The simulation study

We generate $100\,000$ samples from $\mathcal{U}(0, 1)$, calculate the values of all four estimators,
  and get the approximate efficiency values.
Here are the results:

{{< imgld eff >}}

Based on this chart, we can do the following observations:

* The relative efficiency of the Hodges-Lehmann estimator to the mean under uniformity is almost the same
    as under normality: it slowly converges to $1$.
* The relative efficiency of the median to the mean under uniformity is not so great:
    the asymptotic value is about $\approx 34\%$ (comparing to $\approx 64\%$ under normality).
* The relative efficiency of the midrange to the mean under uniformity is awesome:
    it increases indefinitely as the sample size grows.
  However, the efficiency of this estimator under normality decreases as the sample size grows,
    so it is not recommended to use this estimator in non-uniform cases.

To provide additional illustrations of these results,
  we also present the actual sampling distributions of all the considered estimators for $n = \{ 5, 10, 30 \}$:

{{< imgld samp_5 >}}
{{< imgld samp_10 >}}
{{< imgld samp_30 >}}

### Conclusion

Among the considered measures of the central tendency, I advocate using the Hodges-Lehmann location estimator.
While it's sufficiently robust in practice (the asymptotic breakdown point is about $\approx 29\%$),
  it's an efficient replacement for the mean not only under normality but also under uniformity.
Meanwhile, the commonly recommended median has much poorer efficiency
  not only under normality but also under uniformity.
