---
title: Trinal statistical thresholds
description: Comparison of shift, ratio, and effect size as the measures of statistical changes
date: 2023-01-17
tags:
- mathematics
- statistics
- research
features:
- math
---

When we design a test for practical significance, which compares two samples,
  we should somehow express the threshold.
The most popular options are the shift, the ratio, and the effect size.
Unfortunately, if we have little information about the underlying distributions,
  it's hard to get a reliable test based only on a single threshold.
And it's almost impossible to define a generic threshold that fits all situations.
After struggling with a lot of different thresholding approaches,
  I came up with the idea of setting a trinal threshold
    that includes three individual thresholds for the shift, the ratio, and the effect size.

In this post, I show some examples in which a single threshold is not enough.

<!--more-->

The situation with picking the threshold values is especially tricky,
  but the described problem can be illustrated only with the Normal distributions.

When we know the domain area and the measurement units, we can set the shift thresholds.
For example, the shift between $\mathcal{N}(10, 1)$ and $\mathcal{N}(11, 1)$ is $1$, which may look quite significant:

{{< imgld ex1 >}}

However, if the dispersion is huge, the same shift can be practically insignificant.
Here is an example for $\mathcal{N}(1000, 100^2)$ and $\mathcal{N}(1001, 100^2)$:

{{< imgld ex2 >}}

As we can see, the shift value is also $1$, but both distributions are almost the same.
The difference of $1$ is almost negligible on such a scale.
The next idea we can try is to express the difference as a ratio.
In the above example, the difference between the means is only $0.1%$,
  which can be declared as practically insignificant with proper thresholds.

Unfortunately, the ratio itself is not always an indicative value if we ignore the dispersion.
In the next example, the shift and the ratio match the previous example, but the dispersion is much lower:

{{< imgld ex3 >}}

Another common issue with ratios arises when the absolute values approach zero:

{{< imgld ex4 >}}

In the above example, the ratio between the means is 100x (+9900%),
  but the actual practical difference is insignificant.

The classic response to the described problems of the shift and the ratio is the effect size,
  which is often defined as the shift normalized by the dispersion.

Unfortunately, it is not always possible to reliably get a proper dispersion value.
The classic standard deviation is not robust, so it can be easily distorted by a single outlier.
When we switch to robust dispersion measures like the median absolute deviation,
  we can easily get a degenerate case when the dispersion is estimated as zero
  (e.g., on mixtures of discrete and continuous distributions or distributions with
  [discretization effects]({{< ref discrete-performance-distributions>}}) due to insufficient measurement resolution).
This problem can be illustrated even with the Normal distribution if we set $\sigma = 0$:

{{< imgld ex5 >}}

As we can see, the shift and the ratio have meaningful values, but the effect size goes to infinity and
  does not provide a reliable measure of the change between distributions.

### Conclusion

In this post, we briefly checked several examples that show the limitations of different single-threshold approaches.
I believe that a more safe and more reliable approach is to set
  a trinal threshold that covers minimum values of the shift, the ratio, and the effect size at the same time.