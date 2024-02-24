---
title: Statistical efficiency of the Hodges-Lehmann median estimator, Part 1
thumbnail: eff-dark
date: 2022-05-17
tags:
- mathematics
- statistics
- research
- hodges-lehmann
features:
- math
aliases:
- hodgeslehmann-efficiency1
---

In this post, we evaluate the relative statistical efficiency of the Hodges-Lehmann median estimator
  against the sample median under the normal distribution.
We also compare it with the efficiency of the Harrell-Davis quantile estimator.

<!--more-->

### Introduction

The Hodges-Lehmann median estimator is defined as the sample median of all pair-wise averages of the given sample.
However, there are various ways to define an explicit formula.
Following an approach from {{< link park2020 >}}, we consider three options:

$$
\operatorname{HL}_1 = \underset{i < j}{\operatorname{median}}\Big(\frac{x_i + x_j}{2}\Big),\quad
\operatorname{HL}_2 = \underset{i \leq j}{\operatorname{median}}\Big(\frac{x_i + x_j}{2}\Big),\quad
\operatorname{HL}_3 = \underset{\forall i, j}{\operatorname{median}}\Big(\frac{x_i + x_j}{2}\Big).
$$

We also consider the classic Harrell-Davis quantile estimator which can also be used to estimate the median:
$$
Q_\textrm{HD}(p) = \sum_{i=1}^{n} W_{i} \cdot x_{(i)}, \quad
W_{i} = I_{i/n}(a, b) - I_{(i-1)/n}(a, b), \quad
a = p(n+1),\; b = (1-p)(n+1)
$$

where
  $I_t(a, b)$ denotes the [regularized incomplete beta function](https://en.wikipedia.org/wiki/Beta_function#Incomplete_beta_function),
  $x_{(i)}$ is the $i^\textrm{th}$ [order statistics](https://en.wikipedia.org/wiki/Order_statistic).

### Simulation study

In order to evaluate the relative statistical efficiency of the listed median estimators against the sample median,
  we use the following scheme:

* Enumerate different sample size values $n$ from $3$ to $30$.
* For each sample size, we generate $10\,000$ samples from the normal distribution.
* For each sample, we estimate the median using the sample median,
    the Harrell-Davis quantile estimator, and
    three versions of the Hodges-Lehmann median estimator.
* Since all considered estimators are unbiased under the normal distribution,
    the relative statistical efficiency is just a ratio between
    the variance of the sample median and
    the variance of the target median estimator.

The results of the performed simulation study are shown in the following figure:

{{< imgld eff >}}

As we can see, for $n\geq 6$, all three versions of the Hodges-Lehmann median estimator
  outperform the Harrell-Davis quantile estimator in terms of relative statistical efficiency
  under the normal distribution.

In the [next post]({{< ref hodges-lehmann-efficiency2 >}}), we perform more simulations study to get a better understanding of the properties
  of the Hodges-Lehmann median estimator.

### References

* <b id=Harrell1982>[Harrell1982]</b>  
  Harrell, F.E. and Davis, C.E., 1982. A new distribution-free quantile estimator.
  *Biometrika*, 69(3), pp.635-640.  
  https://doi.org/10.2307/2335999 
* <b id="Park2020">[Park2020]</b>  
  Park, Chanseok, Haewon Kim, and Min Wang.
  "Investigation of finite-sample properties of robust location and scale estimators."
  Communications in Statistics-Simulation and Computation (2020): 1-27.  
  https://doi.org/10.1080/03610918.2019.1699114
