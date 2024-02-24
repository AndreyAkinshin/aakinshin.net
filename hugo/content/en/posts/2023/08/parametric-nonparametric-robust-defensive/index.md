---
title: Parametric, Nonparametric, Robust, and Defensive statistics
date: 2023-08-08
thumbnail: compare-light
tags:
- mathematics
- statistics
- research
- ds
features:
- math
---

Recently, I started writing about [defensive statistics]({{< ref ds >}}).
The methodology allows having parametric assumptions,
  but it adjusts statistical methods so that they continue working even in the case
  of huge deviations from the declared assumptions.
This idea sounds quite similar to nonparametric and robust statistics.
In this post, I briefly explain the difference between different statistical methodologies.

{{< imgld compare >}}

<!--more-->

* **Parametric statistics**  
  Parametric statistics always have a strong parametric assumption about the distribution form.
  The most common example is the normality assumptions so that all the corresponding methods
    heavily rely on the fact that the true target distribution is a normal one.
  The methods of parametric statistics stop working even in the case of small deviations from the declared assumptions.
  The classic examples of relevant problems are the sample mean and the sample standard deviation
    which do not provide reliable estimations in the case of extreme outliers caused by a heavy-tailed distribution.
* **Nonparametric statistics**  
  While pure parametric methods are well-known and well-developed, they are not always applicable in practice.
  Unfortunately, perfect parametric distributions are mental constructions:
    they exist only in our imagination, but not in the real world.
  That is why the usage of parametric methods in their classic form is rarely a smart choice.
  Fortunately, we have a handy alternative: the nonparametric statistic.
  This methodology rejects consider any parametric assumptions.
  While some [implicit assumptions]({{< ref insidious-assumptions >}}), like continuity or independence, still
    may be required, nonparametric statistics avoid considering any parametric models.
  Such methods are great when we have no prior knowledge about target distributions.
  However, if the majority of collected data samples follow some patterns
    (which can be expressed in the form of parametric assumptions),
    nonparametric statistics do not look advantageous compared to the parametric methods
    because it is not capable of exploiting this prior knowledge to increase statistical efficiency.
* **Robust statistics**  
  Unlike parametric statistics, robust methods allow slight deviations from the declared parametric model.
  This gives reliable results even if some of the collected measurements do not meet our expectations.
  Unlike nonparametric statistics, robust methods do not fully reject parametric assumptions.
  This gives higher statistical efficiency compared to classic nonparametric statistics.
  Unfortunately, classic robust statistics have issues in the case of huge deviations from the assumptions.
  Usually, robust statistical methods are not capable of handling extreme corner cases,
    which also can arise in practice.
* **Defensive statistics**  
  Defensive statistics tries to get benefits from all the above methodologies.
  Like parametric statistics,
    it accepts the fact that the majority of the collected data samples may follow specific patterns.
  If we express these patterns in the form of assumptions,
    we can significantly increase statistical efficiency in most cases.
  Like robust statistics,
    it accepts small deviations from the assumptions and
    continues to provide reliable results in the corresponding cases.
  Like nonparametric statistics,
    it accepts huge deviations from the assumptions and
    tries to continue to provide reasonable results even in the cases of malformed or corrupted data.
  However, unlike nonparametric statistics, it doesn't stop acknowledging the original assumptions.
  Therefore, defensive statistics ensures not only high reliability
    but also high efficiency in the majority of cases.

### Notes

The front picture was inspired by Figure 5 (Page 7) from {{< link hampel1986 >}}.
