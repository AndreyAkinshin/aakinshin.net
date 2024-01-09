---
title: Insidious implicit statistical assumptions
date: 2023-08-01
tags:
- mathematics
- statistics
- research
- ds
features:
- math
---

Recently, I was rereading "Robust Statistics: The Approach Based on Influence Functions" by Frank Hampel et al.
  and I found this quote about the difference between robust and nonparametric statistics (page 9):

> Robust statistics considers the effects of only approximate fulfillment of assumptions,
>   while nonparametric statistics makes rather weak but nevertheless strict assumptions
>   (such as continuity of distribution or independence).

This statement may sound obvious.
Unfortunately, facts that are presumably obvious in general are not always so obvious at the moment.
When a researcher works with specific types of distributions for a long time,
  the properties of these distributions may be transformed into implicit assumptions.
This implicitness can be pretty dangerous.
If an assumption is explicitly declared,
  it can become a starting point for a discussion on how to handle violations of this assumption.
The implicit assumptions are hidden and
  therefore conceal potential issues in cases when the collected data do not meet our expectations.

A switch from parametric to nonparametric methods is sometimes perceived as a rejection of all assumptions.
Such a perception can be hazardous.
While the original parametric assumption is actually neglected,
  many researchers continue to act like the implicit consequences of this assumption are still valid.

Since normality is the most popular parametric assumption,
  I would like to briefly discuss connected implicit assumptions
  that are often perceived not as non-validated hypotheses, but as essential properties of the collected data.

<!--more-->

* **Light-tailedness.**  
  Assumption: the underlying distribution is light-tailed;
    the probability of observing extremely large outliers is negligible.
  Fortunately, the biggest part of robust statistics is trying to address violations of these assumptions.
* **Unimodality.**  
  Assumption: the distribution is unimodal; no low-density regions in the middle part of the distribution are possible.
  When such regions appear (e.g., due to multimodality), most classic estimators may stop behaving acceptably.
  In such cases, we should evaluate the [resistance to the low-density regions]({{< ref research-rldr >}})
    of the selected estimators.
* **Symmetry.**  
  Assumption: the distribution (including the tails) is absolutely symmetric; the skewness is zero.
  The side effects of assumption violation are not always tangible.
  E.g., the classic Tukey fences are implicitly designed to catch outliers in the symmetric case.
  While this method is still applicable to highly skewed distributions,
    the discovered outliers may significantly differ from our expectations.
* **Continuity.**  
  Assumption: the underlying distribution continues and therefore, no tied values in the collected data are possible.
  Even if the true distribution is actually a continuous one,
    discretization may appear due to the limited resolution of the selected measurement devices.
* **Non-degeneracy.**  
  Assumption: in any collected sample, we have at least two different observations.
  In real life, some distributions can degenerate to the Dirac delta function, which leads to zero dispersion.
* **Unboundness.**  
  Assumption: all values from $-\infty$ to $\infty$ are possible.
  This assumption may significantly reduce the accuracy of the used estimator
    since they do not account for the actual domain of the underlying distribution.
  The classic example is the kernel density estimation based on the normal kernel
    that always returns the probability density function defined on $[-\infty; \infty]$.
* **Independency.**  
  Assumption: observations are independent of each other.
  In real life, the observations can have hidden correlations
    that are so hard to evaluate that researchers prefer to pretend that all the measurements are independent.
* **Stationarity.**  
  Assumption: the properties of the distribution do not change over time.
  The old Greek saying goes "You can't step in the same river twice" (attributed to Heraclitus of Ephesus).
  But can you draw a sample from the same distribution twice?
  For the sake of simplicity, researchers often tend to neglect variable external factors that affect the distribution.
  However, the real world is always a fluke.
* **Plurality.**  
  Assumption: the collected samples always contain at least two observations.
  Sometimes, we have to deal with samples that contain a single element (e.g., in sequential analysis).
  In such a case, equations that use $n-1$ in a denominator stop being valid.

I believe that it is important to think and speculate about the behavior of the statistical methods in corner cases
  of violated assumptions.
Clear explanations of how to handle these corner cases for each statistical approach help
  to implement reliable automatic analysis procedures
  following the principles of [defensive statistics]({{< ref defensive-statistics-intro>}}).
