---
title: Asymmetric decile-based outlier detector, Part 1
date: 2022-03-08
tags:
- mathematics
- statistics
- research
- outliers
features:
- math
aliases:
- asymmetric-decile-outliers
---

In the [previous post]({{< ref tukey-outlier-probability >}}), I covered some problems with the outlier detector
  based on Tukey fences.
Mainly, I discussed the probability of observing outliers using Tukey's fences
  with different factors under different distributions.
However, it's not the only problem with this approach.

Since Tukey's fences are based on quartiles,
  under multimodal distributions, we could get a situation
  when 50% of all sample elements are marked as outliers.
Also, Tukey's fences are designed for symmetric distributions,
  so we could get strange results with asymmetric distributions.

In this post, I want to suggest an asymmetric outlier detector based on deciles
  which mitigates this problem.

<!--more-->

Let $Q_p$ be a quantile estimation of the $p^\textrm{th}$ quantile for the given sample.
With this notation, Tukey's fences introduce the following range:

$$
[Q_{0.25} - k (Q_{0.75} - Q_{0.25}),\, Q_{0.75} + k (Q_{0.75} - Q_{0.25})]
$$

All the sample elements outside this range are marked as outliers.
We are going to keep the fences approach, but we will change the way of forming this range.
The first improvement is simple: we replace quartiles with deciles:

$$
[Q_{0.1} - k (Q_{0.9} - Q_{0.1}),\, Q_{0.9} + k (Q_{0.9} - Q_{0.1})]
$$

With this improvement, only 20% of the sample elements could be marked as outliers
  (10% on each tail).

The second improvement makes this interval asymmetric:

$$
[Q_{0.1} - k (Q_{0.5} - Q_{0.1}),\, Q_{0.9} + k (Q_{0.9} - Q_{0.5})]
$$

The new interval is much more adaptive to asymmetric distributions.

In the [next blog post]({{< ref asymmetric-decile-outliers2 >}}), I will provide some examples that show the difference
  between the classic Tukey's fences and the suggested asymmetric decile-based outlier detector.
I will also provide some guidance about proper default value for $k$.