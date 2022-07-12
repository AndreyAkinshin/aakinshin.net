---
title: Degenerate point of dispersion estimators
date: 2022-07-12
tags:
- Statistics
features:
- math
---

Recently, I have been working on searching for a robust statistical dispersion estimator
  that doesn't become zero on samples with a huge number of tied values.
I have already created a few of such estimators like
  the *middle non-zero quantile absolute deviation* ([part 1]({{< ref mnzqad >}}), [part 2]({{< ref mnzqad2 >}})) and
  the *[untied quantile absolute deviation]({{< ref uqad >}})*.
Having several options to compare, we need a proper metric that allows us to perform such a comparison.
Similar to the breakdown point (that is used to describe estimator robustness),
  we could introduce the *degenerate point* that describes the resistance of a dispersion estimator to the tied values.
In this post, I will briefly describe this concept.

<!--more-->

For better understanding, we start with a brief recall of the breakdown point ($\operatorname{BP}$) approach.
In simple words,
  the breakdown point of an estimator describes the minimum portion of sample elements which should be corrupted
  (replaced by arbitrarily large values) to corrupt the estimation (make it arbitrarily large).
In this post, we focus on the asymptotic breakdown point
  (the corresponding finite-sample breakdown point could be easily obtained).
Let's consider a few examples:

| Estimator                 | Asymptotic breakdown point |
|--------------------------:|---------------------------:|
| Standard deviation        | 0.00                       |
| Interdecile range         | 0.10                       |
| Interquartile range       | 0.25                       |
| Median absolute deviation | 0.50                       |

The median absolute deviation ($\operatorname{MAD}$) is extremely robust because its breakdown point is 0.5.
It's the best possible $\operatorname{BP}$ value since if we corrupt more than $50\%$ of the sample elements,
  it would be impossible to distinguish the actual distribution from the corrupted values.
Thus, $\operatorname{MAD}$ is one of the most robust measures of statistical dispersion,
 it's extremely resistant to outliers.
Unfortunately, it has some issues with tied values.
For example, let's consider the the [Poisson distribution](https://en.wikipedia.org/wiki/Poisson_distribution)
  $\operatorname{Pois}(\lambda)$.
It's probability mass function is defined as $p(k)=\lambda^k e^{-\lambda} / k!$.
It's easy to see that when $\lambda < \lambda_0 = -\ln(0.5) \approx 0.6931$,
  $p(0) > 0.5$ (more than half of the distribution gives zero elements).
In this case, the median absolute deviation becomes zero.
It means that it's impossible to compare the statistical dispersion of
  $\operatorname{Pois}(\lambda_1)$ and $\operatorname{Pois}(\lambda_2)$
  using the median absolute deviation when $\lambda_1, \lambda_2 < -\ln(0.5)$:
  in both cases, the median absolute deviation equals zero.

It brings an important question: what's the minimum portion of sample elements
  that should be replaced by zeros (or some other default values) to get zero dispersion?
Let's name this portion as *degenerate point* ($\operatorname{DP}$).
Here are some examples of degenerate point values:

| Estimator                 | Asymptotic breakdown point | Asymptotic degenerate point |
|--------------------------:|---------------------------:|----------------------------:|
| Standard deviation        | 0.00                       | 1.00                        |
| Interdecile range         | 0.10                       | 0.80                        |
| Interquartile range       | 0.25                       | 0.50                        |
| Median absolute deviation | 0.50                       | 0.50                        |

It's worth noting that this concept is useful only for discrete distributions and
  mixtures of discrete and continuous distributions.
In theory, the probability of observing tied values in the pure continuous case is zero.
However, in practice, the resolution of the measurement tools is limited,
  so that tied values may appear in the samples from distributions that we tend to consider as continuous
  (e.g., see {{< link discrete-performance-distributions >}})

Since measures of dispersion are often used as denominators in various equations,
  the degenerate point may become an important estimator property
  since it defines the domain in which such equations could be actually used.

We can also write the following relationship between the breakdown point and the degenerate point:

$$
\operatorname{BP}+\operatorname{DP} \leq 1.
$$

The intuition behind this inequality is quite trivial.
If the breakdown point of an estimator equals $u$, the estimator should "ignore" $100\cdot u\%$
  of the sample elements (e.g., by omitting or winsorizing them).
Let's assume that $100\cdot u\%$ of the sample elements is contaminated.
It gives us only $100\cdot (1-u)\%$ of the sample elements from the actual distribution
  that should be used to calculate the estimation.
It's the upper bound for the number of elements that should be replaced by zeros to get the zero estimation value.

There is a practical corner case for this rule.
Let's consider a patched version of the median absolute deviation defined as follows:

$$
\operatorname{MAD}^*(x) = \max(\operatorname{MAD}(x), \operatorname{MAD}_{\min}),
$$

where $\operatorname{MAD}_{\min} > 0$.
Such $\operatorname{MAD}^*(x)$ never becomes less than $\operatorname{MAD}_{\min}$.
It could be a practically useful patch for equations that use dispersion as a denominator
  so that we avoid a division by zero.
Even if more than $50\%$ of the sample elements are zeros, $\operatorname{MAD}^*$
  gives $\operatorname{MAD}_{\min}$ as a result.
However, this result doesn't actually describe our actual distribution anymore,
  it's just the default value for the degenerate case.
In order to support the analysis of such "patched" estimators,
  we can redefine the degenerate point as the minimum portion of sample elements
  that should be replaced by zeros (or some other default values) to get the minimum dispersion value
    (in the case of $\operatorname{MAD}^*(x)$, it's $\operatorname{MAD}_{\min}$).