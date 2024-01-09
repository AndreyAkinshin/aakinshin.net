---
title: Thoughts about robustness and efficiency
date: 2023-11-07
tags:
- mathematics
- statistics
- research
features:
- math
---

Statistical efficiency is an essential characteristic,
  which has to be taken into account when we choose between different estimators.
When the underlying distribution is a normal one or at least light-tailed,
  evaluation of the statistical efficiency typically is not so hard.
However, when the underlying distribution is a heavy-tailed one, problems appear.
The statistical efficiency is usually expressed via the mean squared error or via variance, which are not robust.
Therefore, heavy-tailedness may lead to distorted or even infinite efficiency, which is quite impractical.

So, how do we compare the efficiency of estimators under a heavy-tailed distribution?

Let's say we want to compare the efficiency of the mean and the median distribution.
Under the normal distribution (so-called Gaussian efficiency), this task is trivial:
  we build the sampling mean distribution and the sampling median distribution,
  estimate the variance for each of them,
  and then get the ratio of these variances.
However, if we are interested in the median, we are probably expecting some outliers.
Most of the significant real-life outliers come from the heavy-tailed distributions.
Therefore, Gaussian efficiency is not the most interesting metric.
It makes sense to evaluate the efficiency of the considered estimators under various heavy-tailed distributions.
Unfortunately, the variance is not a robust measure and is too sensitive to tails:
  if the sampling distribution is also not normal or even heavy-tailed,
  the meaningfulness of the true variance value decreases.
It seems reasonable to consider alternative robust measures of dispersion.
Which one should we choose?
Maybe Median Absolute Deviation (MAD)?
Well, the asymptotic Gaussian efficiency of MAD is only ~37%.
And here we have the same problem: should we trust the Gaussian efficiency under heavy-tailedness?
Therefore, we should first evaluate the efficiency of dispersion estimators.
But we can't do it without a previously chosen dispersion estimator!
And could we truly express the actual relative efficiency between
  two estimators under tricky asymmetric multimodal heavy-tailed distributions using a single number?
A single number may be appropriate in the parametric case, but it doesn't always work in the nonparametric case.
Some estimators can be more efficient in one situation,
  while other estimators can be more efficient in other situations.
Some of them may be more sensitive to heavy tails, and some of them may be less sensitive.
We need a more detailed picture if we want to compare estimators.
Before we build such a picture, let us recall some of the popular dispersion estimators:

* Standard Deviation (Variance) - non-robust
* Median Absolute Deviation - not so efficient, assumes symmetry
* Shamos Estimator: $\operatorname{Median}(|X_i-X_j|_{i < j}) \cdot C_1$ - interesting option
* Rousseeuw–Croux Qn estimator: $\operatorname{Quantile}(|X_i-X_j|_{i < j}, 0.25) \cdot C_2$ - interesting option

Two listed interesting options operate with 25th and 50th quantiles of the $|X_i-X_j|_{i < j}$ distribution.
But why do we operate only with a single quantile of this distribution?
What if we consider the whole distribution?
The distribution of an absolute difference between two random values — looks like a good dispersion measure.
Such distributions could be compared stochastically:
  we can say that one estimator is more efficient than another estimator
  under the given distribution if the distribution of absolute pairwise differences
  of the sampling distribution is stochastically less for the first estimator compared to the second one.

In future posts,
  I will share some more specific examples of how these speculations can be applied to real-life analysis:

* {{< link robust-eff-median-hl >}}
