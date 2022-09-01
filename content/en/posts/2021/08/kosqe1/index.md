---
title: "Quantile estimators based on k order statistics, Part 1: Motivation"
date: 2021-08-03
tags:
- Statistics
- Quantile Estimators
- Quantile estimators based on k order statistics
- research-thdqe
features:
- math
---

It's not easy to choose a good quantile estimator.
In my previous posts, I considered several groups of quantile estimators:

* Quantile estimators based 1 or 2 order statistics (Hyndman-Fan Type1-9)
* Quantile estimators based on all order statistics
    (the Harrell-Davis quantile estimator,
    the [Sfakianakis-Verginis quantile estimator]({{< ref sfakianakis-verginis-quantile-estimator >}}), and
    the [Navruz-Özdemir quantile estimator]({{< ref navruz-ozdemir-quantile-estimator >}}))
* Quantile estimators based on a variable number of order statistics
    (the [trimmed]({{< ref trimmed-hdqe >}}) and [winsorized]({{< ref winsorized-hdqe >}}) modifications
    of the Harrell-Davis quantile estimator)

Unfortunately, all of these estimators have significant drawbacks
  (e.g., poor statistical efficiency or poor robustness).
In this post, I want to discuss all of the advantages and disadvantages of each approach
  and suggest another family of quantile estimators that are based on k order statistics.

<!--more-->

All posts from this series:

{{< tag-list "Quantile estimators based on k order statistics" >}}

### Properties of quantile estimators

First of all, we should define the properties of quantile estimators that are important in practice.

* **Statistical efficiency**  
  This metric is one of the most important because the main task of a quantile estimator is to provide
    quantile estimators that are closed to the true quantile values.
  *Note that the classic definition of statistical efficiency*
    *doesn't always provide a reliable measure of an estimator.*
  *Since it's based on the mean square error (MSE), it's not robust, and it could be easily corrupted in the case*
    *of heavy-tailed distributions.*
  *As an alternative, we could consider*
    *[the whole distribution of absolute estimation errors]({{< ref robust-statistical-efficiency >}}).*
  *This approach is not so convenient as the classic one because we have to operate*
    *with a function instead of a single number.*
  *Nevertheless, this function provides much more stable values that are mostly not so sensitive to outliers.*
* **Robustness**  
  Heavy-tailedness is a frequent property of real-life distributions.
  With such a property, we could expect to have extreme outliers that could corrupt the estimations.
  With a low breakdown point, even a few outliers may distort estimations for all required quantiles
    and significantly reduce the statistical efficiency.
  That's why it's so important to have robust estimators.
* **Customizability of the trade-off between efficiency and robustness**  
  Unfortunately, it's impossible to get the maximum statistical efficiency in the light-tailed case
    (which means that we should use more order statistics)
    and get a low breakdown point that protects us against outliers in the heavy-tailed case
    (which means that we should use fewer order statistics)
    at the same time.
  We always have to deal with a trade-off between statistical efficiency and robustness.
  It's important to have the ability to customize this trade-off.
  If we could control the breakdown point,
    we would adjust the estimator settings using the a priori knowledge about distribution properties.
* **Computational efficiency**  
  In practice, it's important to estimate quantiles fast.
  A slow quantile estimator could easily become a bottleneck of software that analyzes your data.
  If we need a single order statistics, we could get it using O(n) algorithmic complexity
    (e.g., using the [Fast Deterministic Selection](http://erdani.com/research/sea2017.pdf) by Andrei Alexandrescu).
  If we need more order statistics, we may need O(n*log(n)) complexity to sort the whole sample.
  Don't forget that complexity is not the only measure of performance; the computational constant is also important.
  For example, the Harrell-Davis quantile estimator involves getting values of the Beta function,
    which is not a fast operation.

Now let's discuss different groups of quantile estimators according to the above properties.

### Quantile estimators based on 1 or 2 order statistics

In this group, we have "traditional" quantile estimators which
  peak a single element from a sample (Hyndman-Fan Type1-3)
  or calculate a linear interpolation of two subsequent order statistics (Hyndman-Fan Type4-9).

* **Statistical efficiency**  
  In simple cases, quantile estimators from the Hyndman-Fan classification provide "good enough" efficiency.
  However, it's not always optimal since these estimators use at most two sample elements and ignore the rest.
  The efficiency could be noticeably improved if we take the other sample elements into account.
* **Robustness**  
  The asymptotical breakdown point of the $p^\textrm{th}$ quantile is min(p, 1-p).
  Thus, these estimators are robust.
* **Customizability of the trade-off between efficiency and robustness**  
  It's impossible to change the trade-off.
* **Computational efficiency**  
  These estimators are fast because a single order statistic could be obtained using O(n) algorithmic complexity
    using the [Fast Deterministic Selection](http://erdani.com/research/sea2017.pdf) by Andrei Alexandrescu.

### Quantile estimators based on all order statistics

In this group, we have
  the Harrell-Davis quantile estimator,
  the [Sfakianakis-Verginis quantile estimator]({{< ref sfakianakis-verginis-quantile-estimator >}}), and
  the [Navruz-Özdemir quantile estimator]({{< ref navruz-ozdemir-quantile-estimator >}}).
All of them estimate a quantile as a weighted sum of *all* order statistics.
This means that it's not a good idea to use them with samples from heavy-tailed distribution:
  a single extreme outlier could corrupt estimated values of all quantiles.

* **Statistical efficiency / Robustness**  
  These estimators typically have a decent statistical efficiency with samples from light-tailed distributions.
  Unfortunately, the breakdown point is zero for all of the estimators because
   the estimation involves all sample elements with non-zero weights.
  Thus, these estimators are not robust, which means extremely low statistical efficiency for samples
    from heavy-tailed distributions.
* **Customizability of the trade-off between efficiency and robustness**  
  It's impossible to change the trade-off.
* **Computational efficiency**  
  These estimators are pretty slow.
  In addition to the O(n*log(n)) sorting complexity,
    we have to perform O(n) summation (that involves heavy calculations of the Beta or Binomial function).

### Quantile estimators based on a variable number of order statistics

In this group, we have
  the [trimmed]({{< ref trimmed-hdqe >}}) and [winsorized]({{< ref winsorized-hdqe >}}) modifications
  of the Harrell-Davis quantile estimator (THD and WHD).
The idea behind them is simple: we should drop all the order statistics with small weight coefficients.
In the case of light-tailed distributions, these terms don't have a noticeable impact on the result.
In the case of heavy-tailed distributions, these terms could corrupt the result
  regardless of how small the corresponding weight coefficient is.

* **Statistical efficiency / Robustness / Customizability**  
  The trade-off between statistical efficiency and robustness could be customized using the trimming percentage.
  In special cases, the above estimators could become
    the classic Harrell-Davis quantile estimator (the trimming percentage is zero) or
    a traditional quantile estimator (the trimming percentage is one).
  Unfortunately, it's easy to achieve the required robustness because the breakdown point depends not only
    on the trimming percentage but also on the required quantile position.
* **Computational efficiency**  
  These quantile estimators are much faster than the classic Harrell-Davis quantile estimator
    because they require only several values of the Beta function (instead of O(n) values).

While these estimators is a good step forward in terms of customizability,
  they have an **important drawback: the quantile function is not continuous**.
This introduces some troubles with:

* Statistical efficiency around the discontinuities
* Building the [quantile-respectful density function (QRDE)]({{< ref qrde-hd >}})
* Using it in QRDE-based algorithms like the
    [lowland multimodality detector]({{< ref lowland-multimodality-detection >}}).

Thus, it would be nice to have another customizable quantile estimator without the above drawbacks.

### Quantile estimators based on k order statistics

One of the main problems of the winsorized and trimmed modifications of the Harrell-Davis quantile estimator
  is the lack of ability to directly customize the breakdown point.
This issue could be resolved using an approach that always uses k order statistics around the required quantile.
Let's briefly discuss the properties of such an estimator.

* **Statistical efficiency / Robustness / Customizability**  
  Using the known k value, we could easily get the asymptotical breakdown point: $\max(\min(p, 1-p) - k/2n), 0)$.
  The higher k we use, the higher efficiency (in the light-tailed case) we have
    (because we use more data from the sample).
  The smaller k we use, the higher robustness we have
    (because several corrupted measurements typically will not be able to spoil the estimation).
  By setting k=n, we can get the Harrell-Davis quantile estimator.
  By setting k=1 or k=2, we can get the traditional quantile estimators from the Hyndman-Fan classification.
* **Computational efficiency**  
  The performance of the suggested approach is similar to the previous section:
    using the sorted data, we have to perform O(k) operations.

Thus, quantile estimators based on k order statistics could be a bridge between
  the traditional quantile estimators and the Harrell-Davis quantile estimators.
However, with a proper weight function, we could avoid the disadvantages of the THD/WHD and
  obtain a continuous and smooth quantile function (more about it in the next post).

### Conclusion

In the scope of this post, we discussed only an idea of a quantile estimator based on k order statistics.
It looks like it could resolve issues related to other popular quantile estimators listed above.
In the next post, we will continue exploring the possibilities of using this approach.
We will discuss the weight function that allows transforming k order statistics to a single estimation number.
As usual, we will also perform Monte-Carlo simulations
  that evaluate the actual statistical efficiency of the suggested estimators.
