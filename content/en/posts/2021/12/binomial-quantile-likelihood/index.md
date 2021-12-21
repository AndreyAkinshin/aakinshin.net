---
title: Matching quantile sets using likelihood based on the binomial coefficients
date: 2021-12-21
tags:
- Statistics
features:
- math
---

Let's say we have a distribution $X$ that is given by its $s$-quantile values:

$$
q_{X_1} = Q_X(p_1),\; q_{X_2} = Q_X(p_2),\; \ldots,\; q_{X_{s-1}} = Q_X(p_{s-1})
$$

where $Q_X$ is the quantile function of $X$, $p_j = j / s$.

We also have a sample $y = \{y_1, y_2, \ldots, y_n \}$ that is given by its $s$-quantile estimations:

$$
q_{y_1} = Q_y(p_1),\; q_{y_2} = Q_y(p_2),\; \ldots,\; q_{y_{s-1}} = Q_y(p_{s-1}),
$$

where $Q_y$ is the quantile estimation function for sample $y$.
We also assume that $q_{y_0} = \min(y)$, $q_{y_s} = \max(y)$.

We want to know the likelihood of "$y$ is drawn from $X$".
In this post, I want to suggest a nice way to do this using the binomial coefficients.

<!--more-->

The $q_{X_j}$ quantile values split all the real numbers into $s$ intervals:

$$
(-\infty; q_{X_1}],\; (q_{X_1}; q_{X_2}],\; \ldots,\; (q_{X_{s-2}}; q_{X_{s-1}}],\; (q_{X_{s-1}}; \infty)
$$

If we introduce $q_{X_0} = -\infty$, $q_{X_s}=\infty$,
  we can describe the $j^\textrm{th}$ interval as $(q_{X_{j-1}}; q_{X_{j}}]$.
Each of such intervals contains exactly $1/s$ portion of the whole distribution:

$$
F_X(q_{X_j}) - F_X(q_{X_{j-1}}) = 1/s,
$$

where $F_X$ is the CDF of $X$.

If we knew the elements of sample $y$, we would be able to match $y_i$ to the corresponding intervals.
Let's consider another sample $z = \{ z_1, z_2, \ldots, z_n \}$ where $z_i$ is the index of the interval
  that contains $z_i$:

$$
z_i = \sum_{j=1}^{s} j \cdot \mathbf{1} \{ q_{X_{j-1}} < y_i \leq q_{X_j} \} \quad (i \in \{ 1..n\}).
$$

Let $k_j$ be the number of $y$ elements that belong to the $j^\textrm{th}$ segment:

$$
k_j = \sum_{i=1}^n \mathbf{1} \{ z_i = j \} \quad (j \in \{ 1..s\}).
$$

Unfortunately, we don't know the exact values of $y_i$, we know only $s$-quantile estimations $q_{y_j}$.
For this case, we could estimate the $k_j$ values using linear interpolation between known quantiles:

$$
k_j = n \cdot \sum_{l=1}^{s} \frac{1}{s} \frac{\max(0, \min(q_{y_l}, q_{X_j}) - \max(q_{y_{l-1}}, q_{X_{j-1}}) )}{q_{y_l} - q_{y_{l-1}}}
   \quad (j \in \{ 1..s\}).
$$

(Here we assume that $q_{y_l} \neq q_{y_{l-1}}$, such cases should be handled separately.)

Now we transform the original problem into the new one:
  what's the likelihood of observing sample $\{ z_i \}$ described by $\{ k_j \}$
  given that $z_i$ is a random number from $\{ 1, 2, \ldots, s \}$.

This is a simple combinatorial problem.
The total number of different $z$ samples is $s^n$ (we have $n$ elements, each element is one of $s$ values).
The number of ways to choose $k_1$ elements that equal $1$ is $C_n^{k_1}$.
Once we remove these elements from consideration,
  the number of ways to choose $k_2$ elements that equal $2$ is $C_{n-k_1}^{k_2}$.
If we continue this process, we will get the following equation for the likelihood:

$$
\mathcal{L} = \frac{
  C_n^{k_1} \cdot
  C_{n-k_1}^{k_2} \cdot
  C_{n-k_1-k_2}^{k_3} \cdot
  \ldots \cdot
  C_{n-k_1-k_2-\ldots-k_{s-1}}^{k_s}}{s^n}
$$

Note that $C_n^k$ usually assumes that $n$ and $k$ are integers.
However, in our approach with the linear interpolation, $k_j$ are real numbers.
To work around this limitation, we could consider a generalization of $C_n^k$ on real numbers using the gamma function
  $\Gamma(n) = (n-1)!$:

$$
C_n^k = \frac{n!}{k!(n-k)!} =
  \frac{\Gamma(n+1)}{\Gamma(k+1)\Gamma(n-k+1)}
$$

In practice, it's pretty hard to "honestly" calculate the likelihood using the above formulate
  so we switch to the log-likelihood notation:

$$
\log\mathcal{L} =
  \log C_n^{k_1} +
  \log C_{n-k_1}^{k_2} +
  \log C_{n-k_1-k_2}^{k_3} +
  \ldots +
  \log C_{n-k_1-k_2-\ldots-k_{s-1}}^{k_s} -
  n \log s
$$

It's easy to see that $\log C_n^k$ could be easily expressed via the log-gamma function:

$$
\log C_n^k =
  \log \frac{\Gamma(n+1)}{\Gamma(k+1)\Gamma(n-k+1)} =
  \log\Gamma(n+1) - \log\Gamma(k+1) - \log\Gamma(n-k+1).
$$

This log-likelihood could be used in various applications
  where we need a way to match sets of quantiles between each other.
In one of the future posts, we will learn to apply this approach to change point detection.