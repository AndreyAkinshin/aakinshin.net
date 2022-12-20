---
title: Median of the shifts vs. shift of the medians
description: An example of opposite signs of the median of the shifts and the shift of the medians on multimodal distributions
thumbnail: z-dark
date: 2022-12-20
tags:
- mathematics
- statistics
- research
features:
- math
---

Let us say that we have two samples
  $x = \{ x_1, x_2, \ldots, x_n \}$,
  $y = \{ y_1, y_2, \ldots, y_m \}$,
  and we want to estimate the shift of locations between them.
In the case of the normal distribution, this task is quite simple
  and has a lot of straightforward solutions.
However, in the nonparametric case, the location shift is an ambiguous metric
  which heavily depends on the chosen estimator.
In the context of this post, we consider two approaches that may look similar.
The first one is the **s**hift of the **m**edians:

$$
\newcommand{\DSM}{\Delta_{\operatorname{SM}}}
\DSM = \operatorname{median}(y) - \operatorname{median}(x).
$$

The second one of the median of all pairwise shifts,
  also known as the **H**odges-**L**ehmann location shift estimator:

$$
\newcommand{\DHL}{\Delta_{\operatorname{HL}}}
\DHL = \operatorname{median}(y_j - x_i).
$$

In the case of the normal distributions, these estimators are consistent.
However, this post will show an example of multimodal distributions
  that lead to opposite signs of $\DSM$ and $\DHL$.

<!--more-->

Here are the density plots (normal kernel, Sheather & Jones bandwidth, $n=m=1000$):

{{< imgld density >}}

For these distributions, we have the following estimation values:

$$
\DSM \approx 2.3, \quad \DHL \approx -4.7.
$$

The cause of such a situation can be understood better if we plot the density plot of $Y-X$:

{{< imgld z >}}

Here, we have:

$$
\operatorname{median}(Y-X) \approx 2.7, \quad
\operatorname{mean}(Y-X) = \mathbb{E}[Y-X] \approx -8.9.
$$

The particular choice between $\DSM$ and $\DHL$ should depend on our goals.
If we are interested in the exact value of the median, $\DSM$ should be chosen.
If we are interested in the difference between $Y$ and $X$ in the long run,
  $\DHL$ will provide a more relevant estimation.


### References

* <b id="Hodges1963">[Hodges1963]</b>  
  Hodges, J. L., and E. L. Lehmann. 1963. Estimates of location based on rank tests. The Annals of Mathematical Statistics 34 (2):598–611.  
  DOI:[10.1214/aoms/1177704172](https://dx.doi.org/10.1214/aoms/1177704172)