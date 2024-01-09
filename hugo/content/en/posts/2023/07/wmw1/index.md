---
title: "Weighted Mann-Whitney U test, Part 1"
date: 2023-07-04
tags:
- mathematics
- statistics
- research
- research-wmw
- mann-whitney
features:
- math
aliases:
- wmw
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
\mathbf{x} = ( x_1, x_2, \ldots, x_n ), \quad
\mathbf{y} = ( y_1, y_2, \ldots, y_m ).
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

It is easy to see that $U(x, y) \in [0; n \cdot m]$.
For further discussion, it is convenient to also consider a "normalized" version of $U$ that we denote by $U_\circ$:

$$
U_\circ(x, y) = \frac{U(x, y)}{n \cdot m} \in [0; 1].
$$

For the weighted version of the test, we assign vectors of weights
  $\mathbf{w}$ and $\mathbf{v}$ for $\mathbf{x}$ and $\mathbf{y}$ respectively.

$$
\mathbf{w} = ( w_1, w_2, \ldots, w_n ), \quad
\mathbf{v} = ( v_1, v_2, \ldots, v_m ),
$$

where $w_i \geq 0$, $v_j \geq 0$, $\sum w_i > 0$, $\sum v_j > 0$.

Let us consider the normalized versions of the weight vectors:

$$
\overline{\mathbf{w}} = ( \overline{w}_1, \overline{w}_2, \ldots, \overline{w}_n ), \quad
\overline{\mathbf{v}} = ( \overline{v}_1, \overline{v}_2, \ldots, \overline{v}_m ),
$$

$$
\overline{w}_i = \frac{w_i}{\sum_{k=1}^n w_k},\quad
\overline{v}_j = \frac{v_j}{\sum_{k=1}^m v_k}.
$$

Let us introduce the weighted version of the $U$ statistic.
Similarly to the weighted [Hodges-Lehmann location estimator]({{< ref whl >}}),
  I suggest using the following approach for the normalized weighted version:

$$
U_\circ^\star(\mathbf{x}, \mathbf{y}, \mathbf{w}, \mathbf{v}) =
  \sum_{i=1}^n \sum_{j=1}^m S(x_i, y_j) \cdot \overline{w}_i \cdot \overline{v}_j.
$$

It seems that denormalizing $U_\circ^\star$ does not make a lot of sense.
Firstly, the sample size in the weighted case is not unambiguously defined.[^hr]
Secondly, the denormalized version is not much more useful than the normalized one since we cannot reuse
  the distribution of the classic non-weighted $U$ statistic for the weighted case.
Therefore, we can continue with the normalized statistic $U_\circ^\star$.

To convert the statistic value to the p-value,
  we can approximate the distribution of $U_\circ^\star$ via bootstrap.


[^hr]: For example, we can use the [Huggins-Roy family of effective sample sizes]({{< ref huggins-roy-ess >}})
  that provides a class of equations to define the weighted versions of $n$ and $m$.
  This family includes [Kish's effective sample size]({{< ref kish-ess-weighted-quantiles >}}).
