---
title: "Trimmed Hodges-Lehmann location estimator, Part 1: breakdown point"
description: Introducing a trimmed modification of the Hodges-Lehmann location estimator
  and obtaining expressions for its finite-sample and asymptotic breakdown points
date: 2023-01-03
tags:
- mathematics
- statistics
- research
- Hodges-Lehmann Estimator
features:
- math
---

For a sample $\mathbf{x} = \{ x_1, x_2, \ldots, x_n \}$,
  the Hodges-Lehmann location estimator is defined as follows:

$$
\operatorname{HL}(\mathbf{x}) =
  \underset{i < j}{\operatorname{median}}\biggl(\frac{x_i + x_j}{2}\biggr).
$$

Its asymptotic Gaussian efficiency is $\approx 96\%$,
  while its asymptotic breakdown point is $\approx 29\%$.
This makes the Hodges-Lehmann location estimator a decent robust alternative to the mean.

While the Gaussian efficiency is quite impressive (almost as efficient as the mean),
  the breakdown point is not as great as in the case of the median (which has a breakdown point of $50\%$).
Could we change this trade-off a little bit and make this estimator more robust,
  sacrificing a small portion of efficiency?
Yes, we can!

In this post, I want to present the idea of the trimmed Hodges-Lehmann location estimator
  and provide the exact equation for its breakdown point.

<!--more-->

### Trimming

The classic Hodges-Lehmann location estimator uses all the order statistics,
  including the smallest and the largest sample elements.
But do we really need all of them to estimate the location?
It does not make much sense (especially if we treat the location as a measure of central tendency).
What if we drop a bunch of order statistics from both sides?

Let us consider the trimmed modification of the Hodges-Lehmann location estimator,
  which omits the first $k$ and the last $k$ order statistics:

$$
\newcommand{\BP}{\operatorname{BP}}
\newcommand{\HL}{\operatorname{HL}}
\newcommand{\THL}{\operatorname{THL}}
\newcommand{\x}{\mathbf{x}}
\newcommand{\med}{\operatorname{median}}
\THL(\x, k) = \underset{k < i < j \leq n - k}{\med}\biggl(\frac{x_{(i)} + x_{(j)}}{2}\biggr).
$$

It is easy to see that $\HL(\x) = \THL(\x, 0)$.

### Breakdown point of the Hodges-Lehmann location estimator

First of all, let us derive the breakdown point for the classic Hodges-Lehmann location estimator.
With this approach, we estimate the location as the sample median of the following set $U$:

$$
U = \biggl\{\frac{x_i + x_j}{2}\biggr\}_{i < j}.
$$

This set contains exactly $n (n - 1) / 2$ elements.
Let $p$ be the number of contaminated elements in the original sample $\x$.
Then, the number of non-contaminated elements in $U$ is $(n-1-p)(n-p)/2$.
The median of $U$ is not contaminated if the number of non-contaminated $U$ elements is larger
  than half of the total number of $U$ elements:

$$
\frac{(n-1-p)(n-p)}{2} > \frac{n (n-1)}{4}.
$$

Simplifying this expression, we get:

$$
p^2 + p(1 - 2n) + \frac{1}{2}(n^2-n) > 0.
$$

From that, we can get the critical value of $p$:

$$
p^*_\HL(n) = n - \frac{1}{2} - \sqrt{\frac{n^2}{2} - \frac{n}{2} + \frac{1}{4}}.
$$

This gives us the breakdown point of $\HL$:

$$
\BP_\HL(n) = \frac{p^*_\HL(n)}{n} = 1 - \frac{1}{2n} - \sqrt{\frac{1}{2} - \frac{1}{2n} + \frac{1}{4n^2}}.
$$

Now it is easy to get the asymptotic breakdown point of $\HL$:

$$
\lim_{n \to \infty} \BP_\HL(n) = 1 - \sqrt{\frac{1}{2}} \approx 0.2928932.
$$

### Breakdown point of the trimmed Hodges-Lehmann location estimator

Now we derive the breakdown point for the trimmed modifications of the Hodges-Lehmann location estimator.
The corresponding critical value of $p$ can be found as the number of dropped elements from each side $k$
  plus the Hodges-Lehmann location estimator breakdown point for a sample of size $n-2k$:

$$
p^*_\THL(n, k) = k + p^*_\HL(n - 2k) =
  n - k - \frac{1}{2} - \sqrt{\frac{n^2}{2} - 2nk + 2k^2 - \frac{n}{2} + k + \frac{1}{4}}.
$$

It gives us the breakdown point of $\THL$:

$$
\BP_\THL(n, k) = \frac{p^*_\THL(n, k)}{n} =
  1 - \frac{k}{n} - \frac{1}{2n} -
    \sqrt{\frac{1}{2} - \frac{2k}{n} + \frac{2k^2}{n^2} - \frac{1}{2n} + \frac{k}{n^2} + \frac{1}{4n^2}}.
$$

Now let us express $k$ as a portion of $n$: $k = s \cdot n$.
With this substitution, $\BP_\THL(n, k)$ becomes:

$$
\BP_\THL(n, sn) = 1 - s - \frac{1}{2n} -
  \sqrt{\frac{1}{2} - 2s + 2s^2 - \frac{1}{2n} + \frac{s}{n} + \frac{1}{4n^2}}.
$$

Now we can derive the asymptotic breakdown point of $\THL$:

$$
\lim_{n \to \infty} \BP_\THL(n, sn) = 1 - s - \sqrt{\frac{1}{2} - 2s + 2s^2}.
$$

Since

$$
\frac{1}{2} - 2s + 2s^2 = \Biggl(\frac{1}{\sqrt{2}} - \sqrt{2}s \Biggr)^2,
$$

the asymptotic breakdown point of $\THL$ can be expressed as

$$
\lim_{n \to \infty} \BP_\THL(n, sn) = 1 - s - \Biggl( \frac{1}{\sqrt{2}} - \sqrt{2}s \Biggr) =
  \Biggl( \sqrt{2} - 1 \Biggr) \Biggl( s + \frac{1}{\sqrt{2}} \Biggr).
$$

As we can see, it is a linear dependency on $s$:

{{< imgld thl_abp >}}

### Conclusion

In this post, we introduced the concept of the trimmed Hodges-Lehmann location estimator
  and derived the exact expressions for its finite-sample and asymptotic breakdown point.
In the next post, we explore its Gaussian efficiency values.

### References

* <b id="Hodges1963">[Hodges1963]</b>  
  Hodges, J. L., and E. L. Lehmann. 1963. Estimates of location based on rank tests.
  The Annals of Mathematical Statistics 34 (2):598–611.  
  DOI: [10.1214/aoms/1177704172](https://dx.doi.org/10.1214/aoms/1177704172)