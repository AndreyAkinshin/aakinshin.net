---
title: Fence-based outlier detectors, Part 2
date: 2022-04-05
tags:
- mathematics
- statistics
- research
- outlier-detection
features:
- math
---

In the [previous post]({{< ref fenced-outlier-detectors1 >}}),
  I discussed different fence-based outlier detectors.
In this post, I show some examples of these detectors with different parameters.

<!--more-->

We continue using the notation from the [previous post]({{< ref fenced-outlier-detectors1 >}}).
In order to demonstrate the different in outlier detection between different methods, we do the following:

* Enumerate different distributions: Uniform, Normal, Gumbel, Exponential, Lognormal, Frechet, Weibull.
* For each distribution, we generate a random sample of size $N=1000$.
  Next, we add elements $\{ -20, -19, \ldots, -2, -1, 1, 2, \ldots, 19, 20 \}$ to this sample.
* Draw a density plot for this sample using the normal kernel and the Sheather & Jones method.
* Enumerate different outlier detection methods and highlight detected outliers.

Here are the results:

{{< imgld unif-den >}}
{{< imgld unif >}}

{{< imgld norm-den >}}
{{< imgld unif >}}

{{< imgld gumbel-den >}}
{{< imgld gumbel >}}

{{< imgld exp-den >}}
{{< imgld exp >}}

{{< imgld lnorm-den >}}
{{< imgld lnorm >}}

{{< imgld frechet-den >}}
{{< imgld frechet >}}

{{< imgld weibull-den >}}
{{< imgld weibull >}}