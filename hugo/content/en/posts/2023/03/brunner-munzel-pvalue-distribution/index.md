---
title: p-value distribution of the Brunner–Munzel test in the finite case
date: 2023-03-14
tags:
- mathematics
- statistics
- research
features:
- math
---

In our of the previous post, I explored the
  [distribution of observed p-values for the Mann–Whitney U test]({{< ref mann-whitney-pvalue-distribution >}})
  in the finite case when the null hypothesis is true.
It is time to repeat the experiment for the Brunner–Munzel test.

<!--more-->

We generate $100\,000$ pairs of samples of size $n$ from the standard normal distribution,
  calculate the p-value using the two-sided Brunner–Munzel test,
  and build the density plot for the observed p-values.
We use a test implementation that is extended for the [corner case]({{< ref brunner-munzel-corner-case >}})
  with values $0$ and $1$.
Here is the result for $n=3$:

{{< imgld bm3 >}}

Similarly to other rank-based tests, we get a discrete distribution
  with a limited set of different p-values.
The probabilities of each p-value are the following:

$$
\mathbb{P}(p = 0.0000) = 0.1,
$$

$$
\mathbb{P}(p \approx 0.0686) = 0.1,
$$

$$
\mathbb{P}(p \approx 0.3465) = 0.2,
$$

$$
\mathbb{P}(p \approx 0.5734) = 0.1,
$$

$$
\mathbb{P}(p \approx 0.6667) = 0.2,
$$

$$
\mathbb{P}(p \approx 0.8683) = 0.1,
$$

$$
\mathbb{P}(p \approx 0.8727) = 0.2.
$$

As we can see, the observed distribution is not as nice as in the
  [the Mann–Whitney U test]({{< ref mann-whitney-pvalue-distribution >}}) case.
In particular, the expectations of influence of the specified statistical significance level
  to the actual false positive rate ($\mathbb{P}(p \leq \alpha) = \alpha$) are distorted:

$$
\mathbb{P}(p \leq \alpha)= 0.1 \quad\textrm{for}\quad \alpha \in [0.0000;0.0686),
$$

$$
\mathbb{P}(p \leq \alpha) = 0.2 \quad\textrm{for}\quad \alpha \in [0.0686;0.3465),
$$

$$
\mathbb{P}(p \leq \alpha) = 0.4 \quad\textrm{for}\quad \alpha \in [0.3465;0.5734),
$$

$$
\mathbb{P}(p \leq \alpha) = 0.5 \quad\textrm{for}\quad \alpha \in [0.5734;0.6667),
$$

$$
\mathbb{P}(p \leq \alpha) = 0.7 \quad\textrm{for}\quad \alpha \in [0.6667;0.8683),
$$

$$
\mathbb{P}(p \leq \alpha) = 0.9 \quad\textrm{for}\quad \alpha \in [0.8683;0.8727),
$$

$$
\mathbb{P}(p \leq \alpha) = 1.0 \quad\textrm{for}\quad \alpha \in [0.8727;1.0000).
$$

Therefore, the test should be used cautiously when considering small samples.
For example, if we set the statistical significance level $\alpha = 0.07$,
  the actual false-positive rate will be $\mathbb{P}(p \leq \alpha) = 0.2$.

Now let us look at the same distribution for $n=5$, $n=7$, and $n=15$:

{{< imgld bm5 >}}

{{< imgld bm7 >}}

{{< imgld bm15 >}}

Asymptotically, it becomes uniform as for other statistical tests.
However, on small samples, it has a strange sawtooth-like shape that alter our expectations of the false-positive rate.
