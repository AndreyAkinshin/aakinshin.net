---
title: Quantile absolute deviation of the Pareto distribution
date: 2022-08-29
thumbnail: qad-dark
tags:
- Statistics
- research-qad
features:
- math
---

In this post,
  we derive the exact equation for the quantile absolute deviation around the median of the Pareto(1,1) distribution.

{{< imgld qad >}}

<!--more-->

## Preparation

We consider the quantile absolute deviation around the median defined as follows:

$$
\newcommand{\E}{\mathbb{E}}
\newcommand{\PR}{\mathbb{P}}
\newcommand{\Q}{\operatorname{Q}}
\newcommand{\QAD}{\operatorname{QAD}}
\newcommand{\median}{\operatorname{median}}
\newcommand{\Exp}{\operatorname{Exp}}
\newcommand{\Pareto}{\operatorname{Pareto}(1, 1)}
\QAD(X, p) = \Q(|X - \median(X)|, p),
$$

  where $\Q$ is a quantile estimator.

We are looking for the asymptotic value of $\QAD(X, p)$.
For simplification, we denote it by $v_p$:

$$
v_p = \lim_{n \to \infty} \E[\Q(|X-M|, p)],
$$

where $M$ is the true median of the distribution.

By the definition of quantiles, this can be rewritten as:

$$
\PR(|X_1 - M| < v_p) = p,
$$

which is the same as

$$
\PR(-v_p < X_1 - M < v_p) = p.
$$

Hence,

$$
\PR(M - v_p < X_1 < M + v_p) = p.
$$

If $F$ is the CDF of the considered distribution, the above equality can be rewritten as

$$
F(M + v_p) - F(M - v_p) = p.
\tag{1}
$$

## Pareto distribution

We consider the $\Pareto$ distribution
  given by $F(x)=1-1/x$ with the median value $M=2$.
Since $F$ is defined only for $x \geq x_{\min} = 1$, we have to consider two cases: $M - v_p \leq 1$ and $M - v_p > 1$.
The critical value $v_p^*$ is defined by $v_p^* = M - x_{\min} = 1$.
Now it is easy to get the value of $p^*$ using Equation (1):

$$
p^* = F(2M - x_{\min}) = F(3) = 2/3.
$$

Let us consider the first case when $p \leq p^* = 2/3$.
Equation (1) has the following form:

$$
\Big( 1 - \frac{1}{2 + v_p} \Big) - \Big( 1 - \frac{1}{2 - v_p} \Big) = p,
$$

which is the same as

$$
\frac{1}{2 - v_p} - \frac{1}{2 + v_p} = p.
$$

By multiplying both sides of this equation on $(2 - v_p)(2 + v_p)$, we get:

$$
(2 + v_p) - (2 - v_p) = p (2 - v_p)(2 + v_p),
$$

which is the same as

$$
\frac{2}{p} v_p = 4 - v_p^2.
$$

Hence,

$$
v_p^2 + \frac{2}{p} v_p - 4 = 0.
$$

This is a quadratic equation for $v_p$ with coefficients $a=1$, $b=2/p$, $c=-4$.
The discriminant is given by $D = b^2 - 4ac = 4/p^2 + 16$.
The solution of the quadratic equation is

$$
v_p = \frac{-2/p \pm \sqrt{4/p^2+16}}{2} = \frac{-1}{p} \pm \sqrt{\frac{1}{p^2} + 4}.
$$

Since $v_p$ is always positive, only the plus is applicable for $\pm$.

Now let us consider the second case when $p > p^* = 2/3$.
Equation (1) has the following form:

$$
\Big( 1 - \frac{1}{2 + v_p} \Big) = p,
$$

which is the same as

$$
(2+v_p)(1 - p) = 1.
$$

Hence,

$$
2 - 2p + v_p - p v_p = 1.
$$

From this, we can express $v_p$:

$$
v_p = \frac{2p - 1}{1 - p}.
$$

Thus, if $X \sim \Pareto$,

$$
\lim_{n \to \infty} \E[\QAD(X, p)] = \begin{cases}
\frac{-1}{p} + \sqrt{\frac{1}{p^2} + 4}, & \textrm{if}\; p \leq 2/3,\\
\frac{2p - 1}{1 - p}, & \textrm{if}\; p > 2/3.
\end{cases}
$$

Here is the corresponding plot:

{{< imgld qad >}}
