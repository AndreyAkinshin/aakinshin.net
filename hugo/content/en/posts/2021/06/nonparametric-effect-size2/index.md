---
title: Customization of the nonparametric Cohen's d-consistent effect size
date: 2021-06-08
tags:
- mathematics
- statistics
- research
- Effect Size
- research-gamma-es
- MAD
- Harrell-Davis quantile estimator
features:
- math
---

One year ago, I publish a post called {{< link nonparametric-effect-size >}}.
During this year, I got a lot of internal and external feedback from
  my own statistical experiments and
  [people](https://twitter.com/ViljamiSairanen/status/1400457118340108293)
  [who](https://sherbold.github.io/autorank/autorank/)
  [tried](https://github.com/Ramon-Diaz/Thesis-Project/blob/85df6b11050c7e05c4394d873585f701a7e3f32e/_util.py#L100)
  to use the suggested approach.
It seems that the nonparametric version of Cohen's d works much better with real-life not-so-normal data.
While the classic Cohen's d based on
  the non-robust arithmetic mean and
  the [non-robust standard deviation]({{< ref misleading-stddev >}})
  can be easily [corrupted by a single outlier]({{< ref cohend-and-outliers >}}),
  my approach is much more resistant to unexpected extreme values.
Also, it allows exploring
  [the difference between specific quantiles of considered samples]({{< ref comparing-distributions-using-gamma-es >}}),
  which can be useful in the non-parametric case.

However, I wasn't satisfied with the results of all of my experiments.
While I still like the basic idea
  (replace the mean with the median; replace the standard deviation with the median absolute deviation),
  it turned out that the final results heavily depend on the used quantile estimator.
To be more specific, the original Harrell-Davis quantile estimator is not always optimal;
  in most cases, it's better to replace it with its [trimmed]({{< ref trimmed-hdqe >}}) modification.
However, the particular choice of the quantile estimators depends on the situation.
Also, the consistency constant for the median absolute deviation
  should be adjusted according to the current sample size and the used quantile estimator.
Of course, it also can be replaced by other dispersion estimators
  that can be used as consistent estimators of the standard deviation.

In this post, I want to get a brief overview of possible customizations of the suggested metrics.

<!--more-->

### The generic equations

Let's say we have two samples $x = \{ x_1, x_2, \ldots, x_{n_x} \}$ and $y = \{ y_1, y_2, \ldots, y_{n_y} \}$.
The "classic" Cohen's d can be defined as follows:

$$
d = \frac{\overline{y}-\overline{x}}{s}
$$

where $s$ is the [pooled standard deviation](https://en.wikipedia.org/wiki/Pooled_standard_deviation):

$$
s = \sqrt{\frac{(n_x - 1) s^2_x + (n_y - 1) s^2_y}{n_x + n_y - 2}}.
$$

And here is the quantile-specific effect size suggested in the [previous post]({{< ref nonparametric-effect-size >}}):

$$
\gamma_p = \frac{Q_p(y) - Q_p(x)}{\operatorname{PMAD}_{xy}}
$$

where $Q_p$ is a quantile estimator of the $p^\textrm{th}$ quantile,
  $\operatorname{PMAD}_{xy}$ is the pooled median absolute deviation:

$$
\operatorname{PMAD}_{xy} = \sqrt{\frac{(n_x - 1) \operatorname{MAD}^2_x + (n_y - 1) \operatorname{MAD}^2_y}{n_x + n_y - 2}},
$$

$\operatorname{MAD}_x$ and $\operatorname{MAD}_y$ are the median absolute deviations of $x$ and $y$:

$$
\operatorname{MAD}_x = C_{n_x} \cdot Q_{0.5}(|x_i - Q_{0.5}(x)|), \quad
\operatorname{MAD}_y = C_{n_y} \cdot Q_{0.5}(|y_i - Q_{0.5}(y)|),
$$

$C_{n_x}$ and $C_{n_y}$ are consistency constants
  that makes $\operatorname{MAD}$ a consistent estimator for the standard deviation estimation.

For the normal distribution, the Cohen's d equals to $\gamma_{0.5}$:

$$
d = \frac{\overline{y}-\overline{x}}{s} \approx \frac{Q_{0.5}(y) - Q_{0.5}(x)}{\mathcal{PMAD}_{xy}} = \gamma_{0.5}.
$$

Thus, $\gamma_{0.5}$ can be used as a robust alternative to the original Cohen's d.

### Customization

There are several things that we could customize in the above equations.

* **Quantile estimator**  
  The first thing we should define the quantile estimator $Q_p$.
  In many cases (especially in the case of light-tailed distribution),
    the traditional quantile estimator doesn't provide optimal statistical efficiency.
  The Harrell-Davis quantile estimator
    [provides great statistical efficiency in many light-tailed cases]({{< ref hdqe-efficiency >}}).
  Unfortunately, it could be [inefficient in the case of heavy-tailed distributions]({{< ref robust-statistical-efficiency >}}).
  To fix this problem, we can consider
    [trimmed]({{< ref trimmed-hdqe >}}) and [winsorized]({{< ref winsorized-hdqe >}}) modifications
    of the Harrell-Davis quantile estimator.
  These modifications are more robust, and [they have higher efficiency]({{< ref wthdqe-efficiency >}}).
  For medium-size samples, we can use a trimming/winsorizing strategy based on the highest density interval of the Beta function.
  However, [in some corner cases, advanced strategies may be required]({{< ref customized-wthdqe >}}).
  It worth noting that in all of my experiments, the trimming modification works better than the winsorizing modification.
  For some situations, we can also consider using
    the [Sfakianakis-Verginis quantile estimator]({{< ref sfakianakis-verginis-quantile-estimator >}}) or
    the [Navruz-Özdemir quantile estimator]({{< ref navruz-ozdemir-quantile-estimator >}}).
  However, if you don't have prior knowledge about the distribution form and the sample size,
    [the Harrell-Davis quantile estimator still seems to be a good default option]({{< ref hd-sv-no-efficiency >}}).
* **Consistency constant**  
  When we define the median absolute deviation, we should also define the consistency constant $C_n$.
  In the previous post, I suggested using $C_n = 1.4826$, but this value works only for large $n$ values.
  If we want to get an unbiased standard deviation estimator based on $\operatorname{MAD}_n$ for small n,
    we should adjust the consistency constant.
  The adjusting approach depends on the used quantile estimator.
  I wrote a few blog posts about that show
    [how to choose the consistency constant for the traditional quantile estimator]({{< ref unbiased-mad >}}) and
    [how to choose the consistency constant for the Harrell-Davis quantile estimator]({{< ref unbiased-mad-hd >}}).
* **Dispersion estimator**  
  $\operatorname{MAD}$ stats for the median absolute deviation around the median.
  However, we can also consider
    [the quantile absolute deviation around the given quantile]({{< ref qad >}}) ($\operatorname{QAD}$).
  Initially, I thought that $\operatorname{QAD}$ should be useful for describing quantile-specific effect size.
  I performed several experiments on applying this metric to $\gamma_p$,
    but I failed to get practically beneficial ways to do that (for now).  
  Another robust way to estimate the dispersion is to use the {{< link shamos-estimator >}}:
    $$
    \operatorname{Shamos} = C_n \cdot \operatorname{median}_{i < j} (|x_i - x_j|); \quad C_{\infty} \approx 1.0484
    $$

    $$
    \operatorname{Rousseeuw-Croux} =
    C_n \cdot \operatorname{median}_{i}
        \Big( \operatorname{median}_{j} \big( |x_i-x_j| \big) \Big); \quad C_{\infty} \approx 1.1926
    $$
  I guess these estimators *might* provide better statistical efficiency in some cases,
    but I didn't perform any experiments with them
    because they are computationally inefficient due to their algorithmic complexity (more than $O(n^2)$).

### Summary

There are three main ways to adopt the nonparametric Cohen's d-consistent effect size:

* **An easy way**  
  If you want to get the most simple solution, just use the traditional quantile estimator
    (if $n$ is odd, the median is the middle element of the sorted sample;
    if $n$ is even, the median is the arithmetic average of the two middle elements of the sorted sample).
  The $\operatorname{MAD}$ consistency constant should be taken from
    the main table of [this post]({{< ref unbiased-mad >}}).
* **A relatively easy way**  
  If you want to get a relatively simple but more efficient solution,
    use the [trimmed modifications of the Harrell-Davis quantile estimator]({{< ref trimmed-hdqe >}}) and
    the $\operatorname{MAD}$ consistency constant from the main table of [this post]({{< ref unbiased-mad-hd >}}).
* **A hard way**  
  If you want to get the most efficient solution, you should spend some time on research.
  First of all, you should explore all available options (you can find some by following the below links).
  Next, you should think about the properties of your data sets
    (what kind of distribution you have, and what are your typical sample sizes).
  Finally, you should try different approaches with your data and check which one provides the most reliable results.

### Further reading

* Effect sizes
  * {{< link nonparametric-effect-size >}}
  * {{< link cohend-and-outliers >}}
  * {{< link comparing-distributions-using-gamma-es >}}
* Quantile estimators
  * {{< link navruz-ozdemir-quantile-estimator >}}
  * {{< link sfakianakis-verginis-quantile-estimator >}}
  * {{< link winsorized-hdqe >}}
  * {{< link trimmed-hdqe >}}
  * {{< link customized-wthdqe >}}
* Statistical efficiency
  * {{< link hdqe-efficiency >}}
  * {{< link wthdqe-efficiency >}}
  * {{< link robust-statistical-efficiency >}}
* Dispersion
  * {{< link qad >}}
  * {{< link unbiased-mad >}}
  * {{< link unbiased-mad-hd >}}