---
title: Weighted trimmed Harrell-Davis quantile estimator
date: 2022-04-19
tags:
- mathematics
- statistics
- research
- research-wqe
features:
- math
---

In this post, I combine ideas from two of my previous posts:

* [Trimmed Harrell-Davis quantile estimator]({{< ref pub-thdqe >}}):
    quantile estimator that provides an optimal trade-off between statistical efficiency and robustness
* [Weighted quantile estimators]({{< ref weighted-quantiles >}}):
    a general scheme that allows building weighted quantile estimators.
  Could be used for [quantile exponential smoothing]({{< ref quantile-exponential-smoothing>}})
    and [dispersion exponential smoothing]({{< ref dispersion-exponential-smoothing >}}).

Thus, we are going to build a weighted version of the trimmed Harrell-Davis quantile estimator based on the highest
  density interval of the given width.

<!--more-->

### Simple trimmed Harrell-Davis quantile estimator

The concept of this estimator is fully covered in my recent paper [[Akinshin2022]](#Akinshin2022).
Here I just briefly recall the basic idea.

Let $x$ be a sample with $n$ elements: $x = \{ x_1, x_2, \ldots, x_n \}$.
We assume that all sample elements are sorted ($x_1 \leq x_2 \leq \ldots \leq x_n$) so that
  we could treat the $i^\textrm{th}$ element $x_i$ as the $i^\textrm{th}$ order statistic $x_{(i)}$.
Based on the given sample, we want to build an estimation of the $p^\textrm{th}$ quantile $Q(p)$.

The classic Harrell-Davis quantile estimator (see {{< link harrell1982 >}}) suggests the following approach:

$$
Q_{\operatorname{HD}}(p) = \sum_{i=1}^{n} W_{\operatorname{HD},i} \cdot x_i,\quad
W_{\operatorname{HD},i} = I_{i/n}(\alpha, \beta) - I_{(i-1)/n}(\alpha, \beta),
$$

where $I_x(\alpha, \beta)$ is the regularized incomplete beta function,
  $\alpha = (n+1)p$, $\;\beta = (n+1)(1-p)$.

When we switch to the trimmed modification of this estimator,
  we perform summation only within the highest density interval $[L;R]$ of $\operatorname{Beta}(\alpha, \beta)$
  of size $D$ (as a rule of thumb, we can use $D = 1 / \sqrt{n}$):

$$
Q_{\operatorname{THD}} = \sum_{i=1}^{n} W_{\operatorname{THD},i} \cdot x_i, \quad
W_{\operatorname{THD},i} = F_{\operatorname{THD}}(i / n) - F_{\operatorname{THD}}((i - 1) / n),
$$

$$
F_{\operatorname{THD}}(x) = \begin{cases}
0 & \textrm{for }\, x < L,\\
\big( I_x(\alpha, \beta) - I_L(\alpha, \beta) \big) /
\big( I_R(\alpha, \beta) \big) - I_L(\alpha, \beta) \big) \big)
  & \textrm{for }\, L \leq x \leq R,\\
1 & \textrm{for }\, R < x.
\end{cases}
$$

Thus, we use only sample elements with the highest weight coefficients ($W_{\operatorname{THD},i}$) and
  ignore sample elements with small weight coefficients.
It allows us to get a high statistical efficiency
  (which is close to the efficiency of the classic Harrell-Davis quantile estimator)
  and a good robustness level
  (in most cases, outliers have zero impact on the final result).

### Weighted trimmed Harrell-Davis quantile estimator

Let's assign weights $w = \{ w_1, w_2, \ldots, w_n \}$ to all sample elements.
Now we would like to patch the above equations so that they take these weights into account.

First of all, we should calculate the effective sample size for the weighted sample using
  the [Kish's approach]({{< ref kish-ess-weighted-quantiles >}}):

$$
n^* = \frac{\Big( \sum_{i=1}^n w_i \Big)^2}{\sum_{i=1}^n w_i^2 }.
$$

The $\alpha$ and $\beta$ coefficients should be also properly updated:

$$
\alpha^* = (n^*+1)p,\; \beta^* = (n^*+1)(1-p).
$$

The highest density interval $[L;R]$ of $\operatorname{Beta}(\alpha, beta)$ should be also updated to
  the highest density interval $[L^*;R^*]$ of $\operatorname{Beta}(\alpha^*, \beta^*)$.

In the original Harrell-Davis quantile estimator and its trimmed modification,
  we used $l_i = (i-1)/n$ and $r_i = i/n$ as borders for a segment of Beta distribution
  which is used to determine $W_{\operatorname{HD},i}$ / $W_{\operatorname{THD},i}$.
In the weighted case, we define these values using the given weights:

$$
\left\{
\begin{array}{rcc}
l^*_i & = & \dfrac{s_{i-1}(w)}{s_n(w)},\\
r^*_i & = & \dfrac{s_i(w)}{s_n(w)},
\end{array}
\right.
$$

where $s_i(w) = \sum_{j=1}^{i} w_j$ (assuming $s_0(w) = 0$).

Next, we define a new truncated Beta distribution for the weighted sample:

$$
F^*_{\operatorname{THD}}(x) = \begin{cases}
0 & \textrm{for }\, x < L^*,\\
\big( I_x(\alpha^*, \beta^*) - I_L(\alpha^*, \beta^*) \big) /
\big( I_R(\alpha^*, \beta^*) \big) - I_L(\alpha^*, \beta^*) \big) \big)
  & \textrm{for }\, L^* \leq x \leq R^*,\\
1 & \textrm{for }\, R^* < x.
\end{cases}
$$

Finally, we are ready to write down the final equation for the weighted trimmed Harrell-Davis quantile estimator:

$$
Q_{\operatorname{THD}}^* = \sum_{i=1}^{n} W^*_{\operatorname{THD},i} \cdot x_i, \quad
W^*_{\operatorname{THD},i} = F^*_{\operatorname{THD}}(r_i^*) - F^*_{\operatorname{THD}}(l_i^*).
$$

This approach could be easily adopted for [quantile exponential smoothing]({{< ref quantile-exponential-smoothing>}})
  and [dispersion exponential smoothing]({{< ref dispersion-exponential-smoothing >}})
  without additional efforts.

### Reference

* <b id="Akinshin2022">[Akinshin2022]</b>  
  Andrey Akinshin (2022)
  Trimmed Harrell-Davis quantile estimator based on the highest density interval of the given width,
  Communications in Statistics - Simulation and Computation,
  DOI: [10.1080/03610918.2022.2050396](https://www.tandfonline.com/doi/abs/10.1080/03610918.2022.2050396),
  [arXiv:2111.11776 [stat.ME]](https://arxiv.org/abs/2111.11776).
* <b id="Harrell1982">[Harrell1982]</b>  
  Harrell, F.E. and Davis, C.E., 1982. A new distribution-free quantile estimator.
  *Biometrika*, 69(3), pp.635-640.  
  https://doi.org/10.2307/2335999