---
title: Quantile absolute deviation of the Uniform distribution
date: 2022-08-25
thumbnail: qad-dark
tags:
- mathematics
- statistics
- research
- research-qad
features:
- math
---

In this post,
  we derive the exact equation for the quantile absolute deviation around the median of the Uniform distribution.

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

## Uniform distribution

We consider the standard uniform distribution $\mathcal{U}(0, 1)$
  given by the CDF $F(x)=x$ on $[0;1]$ with the median value $M=0.5$.
From(1), we have:

$$
(0.5 + v_p) - (0.5 - v_p) = p,
$$

which is the same as

$$
v_p = p / 2.
$$

Thus, if $X \sim \mathcal{U}(0, 1)$,

$$
\lim_{n \to \infty} \E[\QAD(X, p)] = \frac{p}{2}.
$$

Here is the corresponding plot:

{{< imgld qad >}}
