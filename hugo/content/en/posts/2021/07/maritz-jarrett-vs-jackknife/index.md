---
title: "Estimating quantile confidence intervals: Maritz-Jarrett vs. jackknife"
date: 2021-07-13
thumbnail: coverage-p50-a95-light
tags:
- mathematics
- statistics
- research
- Quantile
- Confidence Interval
- Coverage
features:
- math
---

When it comes to estimating quantiles of the given sample,
  my estimator of choice is the Harrell-Davis quantile estimator
  (to be more specific, its [trimmed version]({{< ref trimmed-hdqe >}})).
If I need to get a confidence interval for the obtained quantiles,
  I use the [Maritz-Jarrett method]({{< ref weighted-quantiles-ci >}}#the-maritz-jarrett-method)
  because it provides a [decent coverage percentage]({{< ref quantile-ci-coverage >}}).
Both approaches work pretty nicely together.

However, in the original paper by [Harrell and Davis (1982)](https://doi.org/10.2307/2335999),
  the authors suggest using the jackknife variance estimator in order to get the confidence intervals.
The obvious question here is which approach better: the Maritz-Jarrett method or the jackknife estimator?
In this post, I perform a numerical simulation that compares both techniques using different distributions.

<!--more-->

### Numerical simulation

Let's consider a set of different distributions that includes symmetric/right-skewed and light-tailed/heavy-tailed options:

* `beta(2,10)`: the Beta distribution (a = 2, b = 10)
* `cauchy`: the standard Cauchy distribution (location = 0, scale = 1)
* `gumbel`: the Gumbel distribution
* `log-norm(0,3)`: the Log-normal distribution ($\mu$ = 0, $\sigma$ = 3)
* `pareto(1,0.5)`: the Pareto distribution ($x_m$ = 1, $\alpha$ = 0.5)
* `weibull(1,2)`: the Weibull distribution ($\lambda$ = 1, $k$ = 2) (light-tailed)
* `uniform(0,1)`: the uniform distribution (a=0, b=1)
* `normal(0,1)`: the standard normal distribution ($\mu$ = 0, $\sigma$ = 1)

For each distribution, we choose
  the evaluated quantile (P25, P50, P75, P90),
  the confidence level (0.90, 0.95, 0.99),
  and the sample size (3..50).
Next, we generate a random sample 1000 times,
  evaluate the target confidence interval the Maritz-Jarrett method and the jackknife estimator,
  and check if we cover the true quantile value or not using for each approach.

#### Median

First of all, let's look at the confidence interval estimations around the median.

{{< imgld coverage-p50-a90 >}}
{{< imgld coverage-p50-a95 >}}
{{< imgld coverage-p50-a99 >}}

As we can see, the Maritz-Jarrett method produces better coverage values in all cases.

#### P25

Now let's check the $25^\textrm{th}$ percentile.

{{< imgld coverage-p25-a90 >}}
{{< imgld coverage-p25-a95 >}}
{{< imgld coverage-p25-a99 >}}

The Maritz-Jarrett method is still better.

#### P75

Now let's check the $75^\textrm{th}$ percentile.

{{< imgld coverage-p75-a90 >}}
{{< imgld coverage-p75-a95 >}}
{{< imgld coverage-p75-a99 >}}

The Maritz-Jarrett method is still better.

#### P90

Now let's check the $90^\textrm{th}$ percentile.

{{< imgld coverage-p90-a90 >}}
{{< imgld coverage-p90-a95 >}}
{{< imgld coverage-p90-a99 >}}

Here the situation is a little bit trickier.
The jackknife method performs better for small samples ($n < 10$),
  but the Maritz-Jarrett method is asymptotically better.

### Conclusion

In most cases, the Maritz-Jarrett method outperforms the jackknife variance estimator
  in terms of the confidence interval coverage.
However, in some specific cases (e.g., extreme quantiles + small sample size),
  the jackknife approach could be more preferable.

### Simulation source code

{{< src simulation.R >}}