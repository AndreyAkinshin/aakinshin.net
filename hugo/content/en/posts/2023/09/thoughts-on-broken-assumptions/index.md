---
title: Thoughts on automatic statistical methods and broken assumptions
date: 2023-09-05
tags:
- mathematics
- statistics
- research
- ds
- thoughts
---

In the old times of applied statistics existence, all statistical experiments used to be performed by hand.
In manual investigations, an investigator is responsible not only for interpreting the research results
  but also for the applicability validation of the used statistical approaches.
Nowadays, more and more data processing is performed automatically on enormously huge data sets.
Due to the extraordinary number of data samples,
  it is often almost impossible to verify each output individually using human eyes.
Unfortunately, since we typically have no full control over the input data,
  we cannot guarantee certain assumptions that are required by classic statistical methods.
These assumptions can be violated not only due to
  real-life phenomena we were not aware of during the experiment design stage,
  but also due to data corruption.
In such corner cases,
  we may get misleading results,
  wrong automatic decisions,
  unacceptably high Type I/II error rates,
  or even a program crash because of a division by zero or another invalid operation.
If we want to make an automatic analysis system reliable and trustworthy,
  the underlying mathematical procedures should correctly process malformed data.

<!-- more -->

The normality assumption is probably the most popular one.
There are well-known methods of robust statistics that focus only on slight deviations from normality and
  the appearance of extreme outliers.
However, it is only a violation of one specific consequence from the normality assumption: light-tailedness.
In practice, this sub-assumption is often interpreted as
  "the probability of observing extremely large outliers is negligible."
Meanwhile, there are other implicit derived sub-assumptions:
  continuity (we do not expect tied values in the input samples),
  symmetry (we do not expect highly-skewed distributions),
  unimodality (we do not expect multiple modes),
  nondegeneracy (we do not expect all sample values to be equal),
  sample size sufficiency (we do not expect extremely small samples like single-element samples),
  and [others]({{< ref insidious-assumptions >}}).

*Some* statistical methods may handle violations of *some* of these assumptions.
However, most popular approaches still have an applicability domain and a set of unsupported cases.
Some limitations may be explicitly declared
  (e.g., "We assume that the underlying distribution is continuous and no tied values are possible").
Other constraints on the input data can be too implicit so that they have no mention in the relevant papers
  (e.g., there are no remarks like
  "We assume that the underlying distribution is non-degenerate and the dispersion is non-zero").
The boundary between supported and unsupported cases is not always clear:
  we can have a grey area in which the chosen statistical method is still applicable,
  but its statistical efficiency noticeably declines.

Methods of [nonparametric and robust statistics]({{< ref parametric-nonparametric-robust-defensive >}})
  mitigate some of these issues, but not all of them.
Therefore, I develop [the concept of defensive statistics]({{< ref defensive-statistics-intro >}}) in order to handle
  [all possible violations of implicit and explicit assumptions]({{< ref insidious-assumptions >}}).
In classic statistics, there are a lot of powerful methods,
  but their hidden limitations don't always get proper attention.
When everything goes smoothly, it may be challenging to force yourself to focus on corner cases.
However, if we want to achieve a decent level of reliability and avoid potential problems,
  preparation should be performed in advance.
This may require a mindset shift:
  we should proactively search for all the implicit assumptions and plan our strategy for cases,
  in which one or several of these assumptions are violated.
