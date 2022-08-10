---
title: Asymptotic Gaussian efficiency of the quantile absolute deviation
date: 2022-08-16
tags:
- Statistics
- research-qad
features:
- math
---

I have already discussed the concept of the [quantile absolute deviation]({{< ref qad >}})
  in [several previous posts]({{< ref research-qad >}}).
In this post, we derive the equation for the relative statistical efficiency of the quantile absolute deviation
  against the standard deviation under the normal distribution (so call Gaussian efficiency).

<!--more-->

In the context of this post, we consider the quantile absolute deviation ($\operatorname{QAD}$) around the median:

$$
\newcommand{MAD}{\operatorname{MAD}}
\newcommand{QAD}{\operatorname{QAD}}
\newcommand{Q}{\operatorname{Q}}
\newcommand{SD}{\operatorname{SD}}
\newcommand{QHF}{\operatorname{Q}_{\operatorname{HF7}}}
\newcommand{QHD}{\operatorname{Q}_{\operatorname{HD}}}
\newcommand{QTHD}{\operatorname{Q}_{\operatorname{THD-SQRT}}}
\newcommand{exp}{\operatorname{exp}}
\newcommand{erfinv}{\operatorname{erf}^{-1}}
\newcommand{E}{\mathbb{E}}
\newcommand{V}{\mathbb{V}}
\QAD(X, p) = \Q(|X - \Q(X, 0.5)|, p),
$$

  where $Q$ is a sample quantile estimator, X is a sample of i.i.d. random variables $X = \{ X_1, X_2, \ldots, X_n \}$.

Let us consider $X$ from the standard normal distribution: $X \sim \mathcal{N}(0, 1)$.
For the normal model, $\E[\Q(X, 0.5)] = 0$.
Therefore,

$$
\lim_{n \to \infty} \QAD(X, p) = Q(|X|, p).
$$

If $X$ follows the standard normal distribution, $|X|$ follows the standard half-normal distribution.
The probability density function and the quantile function
  of the standard half-normal distribution are defined as follows:

$$
f_{\operatorname{HN}}(x) = \sqrt{\frac{2}{\pi}} \operatorname{exp}(-x^2/2), \quad
Q_{\operatorname{HN}}(p) = \sqrt{2} \erfinv(p),
$$

  where $\erfinv$ is the inverse error function.

The asymptotic variance of the sample quantile estimator for distribution with probability density function $f$
  and quantile function $Q$ is defined as follows:

$$
\lim_{n \to \infty} \V(Q_n(X, p)) = \frac{p(1-p)}{n f(Q(p))^2}.
$$

Using $f_{\operatorname{HN}}$ and $Q_{\operatorname{HN}}$, we get

$$
\lim_{n \to \infty} \V(\QAD_n(X, p)) = \frac{\pi p(1-p)}{2n} \operatorname{exp}\Big(2\big(\erfinv(p) \big)^2 \Big).
$$

The asymptotic variance of the standard deviation estimator is well-known:

$$
\lim_{n \to \infty} \V(\SD_n) = \frac{1}{2n}.
$$

Finally, we are ready to draw the equation for the Gaussian efficiency of $\QAD$:

$$
\lim_{n \to \infty} e(\QAD_n(X, p),\; \SD_n(X)) =
  \lim_{n \to \infty} \frac{\V[\SD_n(X)]}{\V[\QAD_n(X, p)]} =
  \Bigg( \pi p(1-p) \exp\Big(2\big(\erfinv(p) \big)^2 \Big) \Bigg)^{-1}.
$$