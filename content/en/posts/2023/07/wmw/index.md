---
title: Weighted Mann-Whitney U test
date: 2023-07-04
tags:
- mathematics
- statistics
- research
- mann-whitney
features:
- math
---

Previously, I have discussed how to build weighted versions of various statistical methods.
I have already covered weighted versions of
  [various quantile estimators]({{< ref preprint-wqe >}}) and
  [the Hodges-Lehmann location estimator]({{< ref whl >}}).
Such methods can be useful in various tasks like the support of weighted mixture distributions or exponential smoothing.
In this post, I suggest a way to build a weighted version of the Mann-Whitney U test.

<!--more-->

We consider the one-sided Mann-Whitney U test that compares two samples $\mathbf{x}$ and $\mathbf{y}$:

$$
\mathbf{x} = \{ x_1, x_2, \ldots, x_n \}, \quad
\mathbf{y} = \{ y_1, y_2, \ldots, y_m \}.
$$

The U statistic for this test is defined as follows:

$$
U(x, y) = \sum_{i=1}^n \sum_{j=1}^m S(x_i, y_j),\quad

S(a,b) = \begin{cases}
1,   & \text{if } a > b, \\
0.5, & \text{if } a = b, \\
0,   & \text{if } a < b.
\end{cases}
$$

For the weighted version of the test, we assign vectors of weights
  $\mathbf{w}$ and $\mathbf{v}$ for $\mathbf{x}$ and $\mathbf{y}$ respectively.

$$
\mathbf{w} = \{ w_1, w_2, \ldots, w_n \}, \quad
\mathbf{v} = \{ v_1, v_2, \ldots, v_m \},
$$

where $w_i \geq 0$, $v_j \geq 0$, $\sum w_i > 0$, $\sum v_j > 0$.

Let us consider the normalized versions of the weight vectors:

$$
\overline{\mathbf{w}} = \{ \overline{w}_1, \overline{w}_2, \ldots, \overline{w}_n \}, \quad
\overline{\mathbf{v}} = \{ \overline{v}_1, \overline{v}_2, \ldots, \overline{v}_m \},
$$

$$
\overline{w}_i = \frac{w_i}{\sum_{k=1}^n w_k},\quad
\overline{v}_j = \frac{v_j}{\sum_{k=1}^m v_k}.
$$

The samples size can be adjusted using [Kish's effective sample size]({{< ref kish-ess-weighted-quantiles >}}):

$$
n^\star = \frac{\Big( \sum_{i=1}^n w_i \Big)^2}{\sum_{i=1}^n w_i^2 }, \quad
m^\star = \frac{\Big( \sum_{j=1}^m v_j \Big)^2}{\sum_{j=1}^n v_j^2 }
$$

Now we have to introduce the weighted version of the $U$ statistic.
Similarly to the weighted [Hodges-Lehmann location estimator]({{< ref whl >}}),
  I suggest using the following approach:

$$
U^\star(x, y) = n^\star m^\star \sum_{i=1}^n \sum_{j=1}^m S(x_i, y_j) \cdot \overline{w}_i \cdot \overline{v}_j.
$$

If we use an approximation of the $U$ statistic distribution
  (e.g.,
  the Normal approximation,
  [the Edgeworth approximation]({{< ref mw-edgeworth >}}),
  the Saddlepoint approximation,
  etc.),
  we can just plug the values of $n^\star, m^\star, U^\star$ to the non-weighted equations and
  get a reasonable generalization of the approximation models.
The situation for the exact estimation of the $U$ statistic distribution is worse
  since the default implementation based on dynamic programming cannot be easily generalized to the weighted case.
In this case, I suggest considering ceiling effective sample sizes: $\lceil n^\star \rceil$ and $\lceil m^\star \rceil$
  ($U^\star$ should be appropriately adjusted using the ceiling values of sample sizes).
Of course, this approach assumes some precision loss, but it should not be significant for reasonably large samples.
