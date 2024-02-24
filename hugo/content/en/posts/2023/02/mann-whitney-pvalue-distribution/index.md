---
title: p-value distribution of the Mann–Whitney U test in the finite case
date: 2023-02-28
tags:
- mathematics
- statistics
- research
- mann-whitney
features:
- math
---

When we work with null hypothesis significance testing and the null hypothesis is true,
  the distribution of observed p-value is asymptotically uniform.
However, the distribution shape is not always uniform in the finite case.
For example, when we work with rank-based tests like the Mann–Whitney U test,
  the distribution of the p-values is discrete with a limited set of possible values.
This should be taken into account when we design a testing procedure for small samples
  and choose the significance level.

Previously, we already discussed the [minimum reasonable significance level]({{< ref mann-whitney-min-stat-level >}})
  of the Mann-Whitney U test for small samples.
In this post, we explore the full distribution of the p-values for this case.

<!--more-->

### Student's t-test

We start with the Student's t-test to check the p-value distribution in the "simple" case.
Let's generate $10\,000$ pairs of samples of size $5$ from the standard normal distribution,
  calculate the p-value using the two-sided Student's t-test,
  and build the density plot for the observed p-values:

{{< imgld t >}}

As we can see, the distribution looks uniform.
And this is the desired property of a statistical test.
Indeed, the specified significant level $\alpha$ is used to specify the desired false-positive rate.
Mathematically, it can be expressed as $\mathbb{P}(p \leq \alpha) = \alpha$,
  which is a definition of the uniform distribution.
Now let us see what would happen if we switch to the Mann–Whitney U test.

### Mann–Whitney U test

Now we generate $10\,000$ pairs of samples of size $n$ from the standard normal distribution,
  calculate the p-value using the two-sided Mann–Whitney U test,
  and build the density plot for the observed p-values.
Here is the result for $n=3$:

{{< imgld mw3 >}}

As we can see, if both samples contain exactly three elements each,
   the p-value always belongs to the following set
  (assuming the distribution is continuous, the samples do not contain ties):
  $\{ 0.1, 0.2, 0.4, 0.7, 1.0 \}$.
Based on the above plot, we can even guess the probability of observing each p-value:

$$
\mathbb{P}(p = 0.1) = 0.1,
$$

$$
\mathbb{P}(p = 0.2) = 0.1,
$$

$$
\mathbb{P}(p = 0.4) = 0.2,
$$

$$
\mathbb{P}(p = 0.7) = 0.3,
$$

$$
\mathbb{P}(p = 1.0) = 0.3.
$$

Thus, $\mathbb{P}(p \leq \alpha) = \alpha$ is true only for $\alpha$ values from the same set.
However, it is not true for other $\alpha$ values.
Thus,

$$
\mathbb{P}(p \leq \alpha) = 0,\quad\textrm{for}\quad \alpha \in [0;0.1),
$$

$$
\mathbb{P}(p \leq \alpha) = 0.1,\quad\textrm{for}\quad \alpha \in [0.1;0.2),
$$

$$
\mathbb{P}(p \leq \alpha) = 0.2,\quad\textrm{for}\quad \alpha \in [0.2;0.4),
$$

$$
\mathbb{P}(p \leq \alpha) = 0.4,\quad\textrm{for}\quad \alpha \in [0.4;0.7),
$$

$$
\mathbb{P}(p \leq \alpha) = 0.7,\quad\textrm{for}\quad \alpha \in [0.7;1.0),
$$

If changes of $\alpha$ within any of these intervals (e.g., from $\alpha = 0.19$ to $\alpha = 0.11$)
  will not affect the test result.

Now let us look at the same distribution for $n=5$, $n=7$, and $n=15$:

{{< imgld mw5 >}}

{{< imgld mw7 >}}

{{< imgld mw15 >}}

As we can see, as $n$ grows, we get more distinct values in the observed distribution of p-values,
  but the list of the exact values is always limited.
It can also be easily shown that when we compare two samples of sizes $n$ and $m$ using
  the two-sided Mann–Whitney U test, all possible p-values can be expressed as
  $2k/C_{n+m}^n,\;k\in \mathbb{N}$, and $2/C_{n+m}^n$ is the minimum possible value.