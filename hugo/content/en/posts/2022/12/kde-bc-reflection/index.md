---
title: "Kernel density estimation boundary correction: reflection (ggplot2 v3.4.0)"
date: 2022-12-06
tags:
- mathematics
- statistics
- research
features:
- math
---

Kernel density estimation (KDE) is a popular way to approximate a distribution based on the given data.
However, it has several flaws.
One of the most significant flaws is that it extends the support of the distribution.
It is pretty unfortunate: even if we know the actual range of supported values,
  KDE provides non-zero density values for the regions where no values exist.
It is obviously an inaccurate estimation.
The procedure of adjusting the KDE values according to the given boundaries is known as *boundary correction*.
As usual, there are plenty of available boundary correction strategies.

One such strategy was implemented in the
  [v3.4.0 update](https://www.tidyverse.org/blog/2022/11/ggplot2-3-4-0/#bounded-density-estimation) of
  [ggplot2](https://ggplot2.tidyverse.org/) (a popular R package for plotting)
  thanks to [pull request #4013](https://github.com/tidyverse/ggplot2/pull/4013/).
At the present moment, it supports a single boundary correction strategy called *reflection*.
In this post, we discuss this approach and see how it works in practice.

<!--more-->

### Introduction

First of all, we recall the problem.
Let us consider a random sample from the standard exponential distribution of size 100.
Here is the unbounded KDE for this sample (normal kernel, Sheather & Jones bandwidth)
  alongside the true distribution density:

{{< imgld exp1 >}}

As we can see, a significant part of the KDE is placed in the negative region,
  which does not make much sense since the exponential distribution supports only non-negative numbers.
If we specify bounds $[0; \infty]$, we can get the bounded KDE which covers only positive numbers:

{{< imgld exp2 >}}

As we can see, the negative tail is gone, and the density for small $x$ values is slightly increased.
Let us discuss how it works.

### Boundary correction: reflection

We consider the reflection boundary correction strategy
  that was [implemented](https://github.com/tidyverse/ggplot2/pull/4013/) in ggplot 3.4.0
  and proposed in [[Jones1993]](#Jones1993).

As an example, we consider a sample from the standard uniform distribution $\mathcal{U}(0, 1)$ of size 1000.
Despite a huge number of elements, the unbounded KDE (normal kernel, Sheather & Jones bandwidth)
  exceeds the natural range $[0;1]$ of this distribution:

{{< imgld unif1 >}}

The reflection boundary correction procedure contains two simple steps.
In the first step, we should reflect the KDE tails against the boundaries:

{{< imgld unif2 >}}

In the second step, we should sum the reflected tails with the rest of the KDE so that the total density area is $1$:

{{< imgld unif3 >}}

That is all!
We have just built a beautiful bounded KDE concerning the support of the uniform distribution!

### References

* <b id="Jones1993">[Jones1993]</b>  
  Jones, M. C. (1993). Simple boundary correction for kernel density estimation.
  Statistics and Computing, 3(3), 135-146. doi:[10.1007/bf00147776](https://dx.doi.org/10.1007/bf00147776)
