---
title: "Trimmed Hodges-Lehmann location estimator, Part 2: Gaussian efficiency"
description: Evaluating finite-sample Gaussian efficiency of the trimmed Hodges-Lehman location estimator
date: 2023-01-10
tags:
- mathematics
- statistics
- research
features:
- math
---

In the [previous post]({{< ref thl-bp >}}), we introduced
  the trimmed Hodges-Lehman location estimator.
For a sample $\mathbf{x} = \{ x_1, x_2, \ldots, x_n \}$,
  it is defined as follows:

$$
\operatorname{THL}(\mathbf{x}, k) = \underset{k < i < j \leq n - k}{\operatorname{median}}\biggl(\frac{x_{(i)} + x_{(j)}}{2}\biggr).
$$

We also derived the exact expression for its asymptotic and finite-sample breakdown point values.
In this post, we explore its Gaussian efficiency.

<!--more-->

### Gaussian efficiency

Here is the plot with Gaussian efficiency values for $3 \leq n \leq 25$:

{{< imgld efficiency >}}

### References

* <b id="Hodges1963">[Hodges1963]</b>  
  Hodges, J. L., and E. L. Lehmann. 1963. Estimates of location based on rank tests.
  The Annals of Mathematical Statistics 34 (2):598–611.  
  DOI: [10.1214/aoms/1177704172](https://dx.doi.org/10.1214/aoms/1177704172)