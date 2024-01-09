---
title: Finite-sample Gaussian efficiency of the Harrell-Davis median estimator
thumbnail: efficiency-dark
date: 2022-11-01
tags:
- mathematics
- statistics
- research
features:
- math
---

In this post, we explore finite-sample and asymptotic Gaussian efficiency values
  of the sample median and the Harrell-Davis median.

<!--more-->

I have conducted a numerical simulation
  which enumerates various sample sizes (2..100);
  generates 1,000,000 samples from the normal distribution;
  estimates the mean, the sample median, and the Harrell-Davis median for these samples;
  calculates the finite-sample relative efficiency of the sample median and the Harrell-Davis median
    to the mean (the Gaussian efficiency).
Here are the results:

{{< imgld efficiency >}}

As we can see, on small samples the Harrell-Davis median estimator is
  noticeably more efficient than the classic sample median estimator.

Asymptotically, the Gaussian efficiency of both median estimator is $\approx 64\%$.
