---
title: Weighted quantile estimation for a weighted mixture distribution
date: 2022-10-25
tags:
- mathematics
- statistics
- research
- research-wqe
features:
- math
---

Let $\mathbf{x} = \{ x_1, x_2, \ldots, x_n \}$ be a sample of size $n$.
We assign non-negative weight coefficients $w_i$ with a positive sum for all sample elements:

$$
\mathbf{w} = \{ w_1, w_2, \ldots, w_n \}, \quad w_i \geq 0, \quad \sum_{i=1}^{n} w_i > 0.
$$

For simplification, we also consider normalized (standardized) weights $\overline{\mathbf{w}}$:

$$
\overline{\mathbf{w}} = \{ \overline{w}_1, \overline{w}_2, \ldots, \overline{w}_n \}, \quad
  \overline{w}_i = \frac{w_i}{\sum_{i=1}^{n} w_i}.
$$

In the non-weighted case, we can consider a quantile estimator $\operatorname{Q}(\mathbf{x}, p)$
  that estimates the $p^\textrm{th}$ quantile of the underlying distribution.
We want to build a weighted quantile estimator $\operatorname{Q}(\mathbf{x}, \mathbf{w}, p)$
  so that we can estimate the quantiles of a weighed sample.

In this post, we consider a specific problem of estimating quantiles of a weighted mixture distribution.

<!--more-->

For example, we can consider three distributions given by their cumulative distribution functions (CDFs)
  $F_X$, $F_Y$, and $F_Z$ with weight coefficients $w_X$, $w_Y$, and $w_Z$.
Their weighted mixture is given by $F=\overline{w}_X F_X + \overline{w}_Y F_Y + \overline{w}_Z F_Z$.
Let us say that we have samples $\mathbf{x}$, $\mathbf{y}$, and $\mathbf{z}$ from $F_X$, $F_Y$, and $F_Z$;
  and we want to estimate the quantile function $F^{-1}$ of the mixture distribution $F$.
If each sample contains a sufficient number of elements, we can consider a straightforward approach:

1. Obtain estimations $\hat{F}^{-1}_X$, $\hat{F}^{-1}_Y$, $\hat{F}^{-1}_Z$
     of the distribution quantile functions based on the given samples;
2. Invert quantile functions and obtain estimations $\hat{F}_X$, $\hat{F}_Y$, $\hat{F}_Z$
     of the CDFs for each distribution;
3. Combine these CDFs and build an estimation $\hat{F}=\overline{w}_X\hat{F}_X+\overline{w}_Y\hat{F}_Y+\overline{w}_Z\hat{F}_Z$ of the mixture CDF;
4. Invert $\hat{F}$ and get the estimation $\hat{F}^{-1}$ of the mixture distribution quantile function.

The approach performs well only when the sample sizes are large enough
  so that we can efficiently estimate sample quantiles.