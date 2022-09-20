---
title: Weighted quantile estimators for exponential smoothing and mixture distributions
date: 2022-09-20
tags:
- Statistics
- research-wqe
features:
- math
---

There are various ways to estimate quantiles of weighted samples.
The proper choice of the most appropriate weighted quantile estimator depends not only on the own estimator properties
  but also on the goal.

Let us consider two problems:

1. *Estimating quantiles of a weighted mixture distribution.*  
   In this problem, we have a weighted mixture distribution given by $F = \sum_{i=1}^m w_i F_i$.
   We collect samples $\mathbf{x_1}, \mathbf{x_2}, \ldots, \mathbf{x_m}$ from $F_1, F_2, \ldots F_m$,
     and want to estimate quantile function $F^{-1}$ of the mixture distribution based on the given samples.
2. *Quantile exponential smoothing.*  
   In this problem, we have a time series $\mathbf{x} = \{ x_1, x_2, \ldots, x_n \}$.
   We want to describe the distribution "at the end" of this time series.
   The latest series element $x_n$ is the most "actual" one, but we cannot build a distribution based on a single element.
   Therefore, we have to consider more elements at the end of $\mathbf{x}$.
   However, if we take too many elements, we may corrupt the estimations due to obsolete measurements.
   To resolve this problem, we can assign weights to all elements according to the exponential law
     and estimate weighted quantiles.

In both problems, the usage of weighted quantile estimators looks like a reasonable solution.
However, in each problem, we have different expectations of the estimator behavior.
In this post, we provide an example that illustrates the difference in these expectations.

<!--more-->

Let us consider the following distribution:

$$
\newcommand{\eps}{\varepsilon}
F =
  \eps F_{\delta_{-1000}} +
  \frac{1-3\eps}{2} F_{\mathcal{U}(0,1)} +
  \eps F_{\delta_{10}} +
  \frac{1-3\eps}{2} F_{\mathcal{U}(99,100)} +
  \eps F_{\delta_{1000}},
$$

  where $\delta_t$ is the Dirac delta function (it has all its mass at $t$),
    $\mathcal{U}(a, b)$ is the continuous uniform distribution on $[a;b]$,
    $\eps$ is a small constant.

When we consider the problem of obtaining the true quantile values of the mixture distribution $F$,
  we should expect $F^{-1}(0) = -1000$, $F^{-1}(0.5) = 10$, $F^{-1}(1) = 1000$.

However, in the smoothing problem, we want to have a negligible impact of
  $F_{\delta_{-1000}}$, $F_{\delta_{10}}$, $F_{\delta_{1000}}$ on the quantile estimations when $\eps \to 0$.
More specifically, we expect $F^{-1}(0) \approx 0$, $F^{-1}(0.5) \approx 50$, $F^{-1}(1) \approx 101$.

Thus, there is not a single weighted quantile estimator that fits all the problems.
In each case, we have to choose the proper estimator based on the estimator properties and the research goals.