---
title: "Median of the shifts vs. shift of the medians, Part 2: Gaussian efficiency"
description: Evaluating gaussian efficiency of the shifts of the median and the Hodges-Lehmann location shift estimator
thumbnail: efficiency-dark
date: 2022-12-27
tags:
- mathematics
- statistics
- research
- hodges-lehmann
features:
- math
---

In the [previous post]({{< ref median-shift-vs-shift-median1 >}}),
  we discussed the difference between shifts of the medians
  and the Hodges-Lehmann location shift estimator.
In this post, we conduct a simple numerical simulation
  to evaluate the Gaussian efficiency of these two estimators.

<!--more-->

### Estimators

We consider two samples of equal size $n$:
  $x = \{ x_1, x_2, \ldots, x_n \}$,
  $y = \{ y_1, y_2, \ldots, y_n \}$.
We define the shifts of the medians as

$$
\newcommand{\DSM}{\Delta_{\operatorname{SM}}}
\DSM = \operatorname{median}(y) - \operatorname{median}(x).
$$

and the Hodges-Lehmann location shift estimator as

$$
\newcommand{\DHL}{\Delta_{\operatorname{HL}}}
\DHL = \operatorname{median}(y_j - x_i).
$$

We also consider the classic estimator that estimates the difference of means:

$$
\newcommand{\Dbase}{\Delta_{\operatorname{0}}}
\Dbase = \operatorname{mean}(y) - \operatorname{mean}(x).
$$

The Gaussian efficiency of $\DSM$ and $DHL$ can be defined as follows:

$$
e(\DSM) = \frac{\mathbb{V}[\Dbase]}{\mathbb{V}[\DSM]},\quad
e(\DHL) = \frac{\mathbb{V}[\Dbase]}{\mathbb{V}[\DHL]}.
$$

### Numerical simulations

We conduct the following simulation:

* Enumerate the sample size $n$ from $3$ to $100$.
* For each $n$, generate $100\,000$ pairs of random samples from $\mathcal{N}(0, 1)$.
* For each pair of samples, estimate the shift between them using $\Dbase$, $\DSM$, and $\DHL$.
* Calculate the Gaussian efficiency of $\DSM$ and $DHL$ using the above equations.

Here are the results:

{{< imgld efficiency >}}

As we can see, the Hodges-Lehmann location shift estimator is much more efficient than
  the shift of the medians.

### References

* <b id="Hodges1963">[Hodges1963]</b>  
  Hodges, J. L., and E. L. Lehmann. 1963. Estimates of location based on rank tests. The Annals of Mathematical Statistics 34 (2):598–611.  
  DOI:[10.1214/aoms/1177704172](https://dx.doi.org/10.1214/aoms/1177704172)