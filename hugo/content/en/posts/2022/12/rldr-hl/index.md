---
title: "Resistance to the low-density regions: the Hodges-Lehmann location estimator"
date: 2022-12-13
tags:
- mathematics
- statistics
- research
- research-rldr
- Hodges-Lehmann Estimator
features:
- math
---

In the previous posts, I discussed the concept of a resistance function
  that shows the sensitivity of the given estimator to the low-density regions.
I already showed how this function behaves for [the mean, the sample median]({{< ref rldr-mean-median >}}),
  and [the Harrell-Davis median]({{< ref rldr-hdmedian >}}).
In this post, I explore this function for the Hodges-Lehmann location estimator.

<!--more-->

### The resistance function

As was shown in the [previous post]({{< ref rldr-mean-median >}}),
  we define the function of resistance to the low-density regions as follows:

$$
R(T, n, s) = \max_{s \leq k \leq n} R(T, n, s, k),
$$

$$
R(T, n, s, k) = |T(\mathbf{x}_k) - T(\mathbf{x}_{k-s})|,
$$

$$
\mathbf{x}_k = \{ \underbrace{0, 0, \ldots, 0}_{k}, \underbrace{1, 1, \ldots, 1}_{n-k} \},
$$

where
  $T$ is an estimator,
  $n$ is the sample size,
  $s$ is the number of sample values that jump from the first mode to the second one.

### Resistance of the Hodges-Lehmann location estimator

For a sample $\mathbf{x} = \{ x_1, x_2, \ldots, x_n \}$,
  the Hodges-Lehmann location estimator is defined as follows:

$$
\newcommand{\HL}{\operatorname{HL}}
\HL(\mathbf{x}) = \underset{i < j}{\textrm{median}} \Bigg( \frac{x_i + x_j}{2} \Bigg).
$$

Now it's time to build the plot of $R(T, n, s)$ that compares
  the mean, the sample median, and the Harrell-Davis median.
In this experiment, we consider $n \leq 100$, $s \in \{1, 2, 3, 4, 5, 6\}$.
Here are the plots:

{{< imgld resistance >}}

As we can see, the resistance function value for the Hodges-Lehmann location estimator is $0.5$
  when the sample size $n$ is sufficiently large.

### Deep view of the Hodges-Lehmann location estimator resistance function

Now we explore how $R(\HL, n, s, k)$ depends on $k$:

{{< imgld resistance_hl49 >}}
{{< imgld resistance_hl50 >}}
{{< imgld resistance_hl99 >}}
{{< imgld resistance_hl100 >}}

As we can see, most of the $R(\HL, n, s, k)$ values are zeros
  expect two regions of $k$ values in which the value is $0.5$.
These values correspond to the breakdown point of the Hodges-Lehmann location estimator
  (its asymptotic value is 29%).
Thus, $R(\HL, n, s, k) = 0.5$ for the $k$ values around $0.29 \cdot n$ and $0.71 \cdot n$.

### Deep view of various resistance functions

In the previous section, we got interesting plots describing $R(\HL, n, s, k)$.
Now let us compare it with similar plots for other previously covered estimators
  ([the mean, the sample median]({{< ref rldr-mean-median >}}),
  and [the Harrell-Davis median]({{< ref rldr-hdmedian >}})):

{{< imgld resistance_all49 >}}
{{< imgld resistance_all50 >}}
{{< imgld resistance_all99 >}}
{{< imgld resistance_all100 >}}

Compared to the sample median,
  the Hodges-Lehmann location estimator has two $R=0.5$ regions instead of one, but it never reaches $R=1$.
Compared to the Harrell-Davis median,
  the Hodges-Lehmann location estimator has much higher $R(\HL, n, s) = 0.5$,
  but $R(\HL, n, s, k) = 0$ for the middle part of $k$ values
    (which is much better than the positive values of the Harrell-Davis median).
Considering the extremely high Gaussian efficiency of the Hodges-Lehmann location estimator ($94\%$)
  and its low breakdown point ($29\%$),
  this estimator can be a good choice for estimating the location of multimodal distributions.