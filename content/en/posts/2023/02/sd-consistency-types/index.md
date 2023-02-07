---
title: Types of finite-sample consistency with the standard deviation
date: 2023-02-07
tags:
- mathematics
- statistics
- research
features:
- math
---

Let us say we have a robust dispersion estimator $\operatorname{T}(X)$.
If it is asymptotically consistent with the standard deviation,
  we can use such an estimator as a robust replacement for the standard deviation under normality.
Thanks to asymptotical consistency, we can use the estimator "as is" for large samples.
However, if the number of sample elements is small,
  we typically need finite-sample bias-correction factors to make the estimator unbiased.
Here we should clearly understand what kind of consistency we need.

There are various ways to estimate the standard deviation.
Let us consider a sample of random variables $X = \{ X_1, X_2, \ldots, X_n \}$.
The most popular equation of the standard deviation is given by

$$
s(X) = \sqrt{\frac{1}{n - 1} \sum_{i=1}^n (X_i - \overline{X})^2}.
$$

Using this definition, we can get an unbiased estimator for the population variance: $\mathbb{E}[s^2(X)] = 1$.
However, it is a biased estimator for the population standard deviation: $\mathbb{E}[s(X)] \neq 1$.
To obtain to corresponding unbiased estimator, we should use $s(\mathbf{x}) \cdot c_4(n)$,
  where $c_4(n)$ is a correction factor defined as follows:

$$
c_4(n) = \sqrt{\frac{2}{n-1}} \cdot \frac{\Gamma\left(\frac{n}{2}\right)}{\Gamma\left(\frac{n-1}{2}\right)}.
$$

When we define finite-sample bias-correction factors for a robust standard deviation replacement,
  we should choose which kind of consistency we need.
In this post, I briefly explore available options.

<!--more-->

### Types of consistency

We can consider three following types of consistency $A$, $B$, $C$
  with corresponding finite-sample bias-correction factors $C_{A,n}$, $C_{B,n}$, $C_{C,n}$.
For each type, we provide corresponding equations assuming that $X \sim \mathcal{N}(0, 1)$.

* **Type A: Consistency with the population standard deviation.**

$$
\mathbb{E}[C_{A,n} \cdot \operatorname{T}(X)] = 1
\quad\Longleftrightarrow\quad
C_{A,n} = \frac{1}{\mathbb{E}[\operatorname{T}(X)]}.
$$

* **Type B: Consistency with the population variance.**

$$
\mathbb{E}[(C_{B,n} \cdot \operatorname{T}(X))^2] = 1
\quad\Longleftrightarrow\quad
C_{B,n} = \sqrt{\frac{1}{\mathbb{E}[\operatorname{T}^2(X)]}}.
$$

* **Type C: Consistency with the sample standard deviation.**

$$
\mathbb{E}[C_{C,n} \cdot \operatorname{T}(X)] = c_4(n)
\quad\Longleftrightarrow\quad
C_{C,n} = \frac{c_4(n)}{\mathbb{E}[\operatorname{T}(X)]}.
$$

Typically, scientific papers use Type A and provide bias-correction factors to make an estimator consistent
  with the population standard deviation.
If consistency with the population variance is more important, Type B may be used.
However, both of these options do not provide consistency with $s(X)$.
If we want to get an unbiased replacement for $s(x)$, Type C can be considered.

### Case study

To illustrate the difference between different types of consistency,
  we consider an example for $n = 4$ and $\operatorname{T} = \operatorname{MAD}$,
  where $\operatorname{MAD}$ is the classic median absolute deviation around the median:

$$
\operatorname{MAD}_n(X) = C_n \cdot \operatorname{median}(|X - \operatorname{median(X)}|).
$$

Let's simulate multiple samples of size $4$ from the standard normal distribution
  and evaluate $s(X)$ and three variants of $\operatorname{MAD}$ for each sample.
Here are the density plots of the corresponding estimations and their squares:

{{< imgld e1 >}}

{{< imgld e2 >}}

And here is the summary table that shows the difference between different types of consistency:

|Estimator |   Factor| $\mathbb{E}[\operatorname{MAD}_n]$ | $\mathbb{E}[\operatorname{MAD}_n^2]$ |
|:----|--------:|---------:|--------:|
|SD      |       NA| 0.9213177 | 1|
|(A) MAD    | 2.016814| 1 | 1.329097|
|(B) MAD    | 1.753380| 0.8699103| 1 |
|(C) MAD    | 1.857393| 0.9213177 | 1.127282|

Note that $\mathbb{E}[\operatorname{MAD}_n]$ for $\operatorname{MAD}$ Type C
  is exactly $c_4(n) \approx 0.9213177$.
