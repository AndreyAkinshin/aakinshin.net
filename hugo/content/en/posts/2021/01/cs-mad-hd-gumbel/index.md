---
title: "Case study: Accuracy of the MAD estimation using the Harrell-Davis quantile estimator (Gumbel distribution)"
date: "2021-01-05"
tags:
- mathematics
- statistics
- case-study
- Quantile
- MAD
- Harrell-Davis quantile estimator
features:
- math
---

In some of my previous posts, I used
  the [median absolute deviation](https://en.wikipedia.org/wiki/Median_absolute_deviation) (MAD)
  to describe the distribution dispersion:

* [DoubleMAD outlier detector based on the Harrell-Davis quantile estimator]({{< ref harrell-davis-double-mad-outlier-detector>}})
* [Nonparametric Cohen's d-consistent effect size]({{< ref nonparametric-effect-size >}})
* [Quantile absolute deviation: estimating statistical dispersion around quantiles]({{< ref qad >}})

The MAD estimation depends on the chosen median estimator:
  we may get different MAD values with different median estimators.
To get better accuracy,
  I always encourage readers to use the Harrell-Davis quantile estimator
  instead of the classic Type 7 quantile estimator.

In this case study, I decided to compare these two quantile estimators using
  the [Gumbel distribution](https://en.wikipedia.org/wiki/Gumbel_distribution)
  (it's a good model for slightly right-skewed distributions).
According to the performed Monte Carlo simulation,
  the Harrell-Davis quantile estimator always has better accuracy:

{{< imgld summary >}}

<!--more-->

### The case study

We are going to calculate the median absolute deviation (with the consistency constant = $1$):

$$
\mathcal{MAD} = \textrm{Median}(|X - \textrm{Median}(X)|).
$$

We estimate the median using two quantile estimators:

* **The Type 7 quantile estimator**  
  It's the most popular quantile estimator which is used by default in
    R, Julia, NumPy, Excel (`PERCENTILE`, `PERCENTILE.INC`), Python (`inclusive` method).
  We call it "Type 7" according to notation from {{< link hyndman1996 >}}, 
    where Rob J. Hyndman and Yanan Fan described nine quantile algorithms which are used in statistical computer packages.
* **The Harrell-Davis quantile estimator**  
  It's my favorite option in real life because
    it's more efficient than classic quantile estimators based on linear interpolation,
    and it provides more reliable estimations on small samples.
  This quantile estimator is described in {{< link harrell1982 >}}.

We take random samples from the [Gumbel distribution](https://en.wikipedia.org/wiki/Gumbel_distribution) ($\mu = 0,\; \beta = 1$).
The true median absolute deviation [is known]({{< ref gumbel-mad >}}): `0.767049251325708`.

Let's perform the following Monte Carlo simulation:

* Enumerate different sample sizes from 3 to 60
* Perform 1000 iterations for each sample size
* Generate random sample from the gumbel distribution ($\mu = 0,\; \beta = 1$).
* Estimate the median absolute deviation using two quantile estimators
* Evaluate the absolute error for both estimation
* Calculate the portion of cases ("score") when the Harrell-Davis quantile estimator provides better MAD estimations
    than the Type 7 quantile estimator.

You can find an R script with the simulation at the end of this post.

In this case study, we got a statistically significant result that shows the superiority of the Harrell-Davis quantile estimator:

{{< imgld summary >}}

The benefits of the Harrell-Davis quantile estimator are most noticeable on small sample sizes ($\textrm{SampleSize} < 20$).

### Density plots

Here are some of the density plots for the absolute errors of the median absolute deviation:

{{< imgld results-03 >}}

{{< imgld results-04 >}}

{{< imgld results-05 >}}

{{< imgld results-06 >}}

{{< imgld results-07 >}}

{{< imgld results-08 >}}

{{< imgld results-09 >}}

{{< imgld results-10 >}}

### The script

The data set has been generated using the following R script:

{{< src study.R >}}

### References

* <b id="Harrell1982">[Harrell1982]</b>  
  Harrell, F.E. and Davis, C.E., 1982. A new distribution-free quantile estimator.
  *Biometrika*, 69(3), pp.635-640.  
  https://pdfs.semanticscholar.org/1a48/9bb74293753023c5bb6bff8e41e8fe68060f.pdf
* <b id="Hyndman1996">[Hyndman1996]</b>  
  Hyndman, R. J. and Fan, Y. 1996. Sample quantiles in statistical packages, *American Statistician* 50, 361–365.  
  https://doi.org/10.2307/2684934  