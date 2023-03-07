---
title: Comparing statistical power of the Mann-Whitney U test and the Brunner-Munzel test
date: 2023-03-07
tags:
- mathematics
- statistics
- research
features:
- math
---

In this post, we perform a short numerical simulation to compare the statistical power
  of the Mann-Whitney U test and the Brunner-Munzel test under normality
  for various sample sizes and significance levels.

<!--more-->

### Simulation design

We conduct a simulation according to the following scheme:

* Enumerate various pairs of the significance level $\alpha$ and the sample size $n$
* Enumerate various effect sizes $ES$ from $0.1$ to $2.0$
* For each combination of the above parameters, we generate $50\,000$ pairs of random samples of size $n$:
    one from $\mathcal{N}(0, 1)$ and one from $\mathcal{N}(ES, 1)$.
  For each pair, we perform both statistical tests (one-tailed) and get the p-value.
  Next, we calculate the statistical power for each test based on the given value of $\alpha$

### Simulation results

Here are the results for some values of $\alpha$ and $n$:

{{< imgld sp_050_05 >}}
{{< imgld sp_050_10 >}}
{{< imgld sp_050_30 >}}

{{< imgld sp_010_05 >}}
{{< imgld sp_010_10 >}}
{{< imgld sp_010_30 >}}

{{< imgld sp_005_05 >}}
{{< imgld sp_005_10 >}}
{{< imgld sp_005_30 >}}

As we can see, in the *presented* simulations,
  the Brunner-Munzel test has higher statistical power than the Mann-Whitney U test
  (especially for small $\alpha$ and small $n$).
However, it's just a single simulation, so we can't derive a generic conclusion about which test is better.
In future posts, I will explore the behavior of these tests in more contexts.
