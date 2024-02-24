---
title: "Quantile confidence intervals for weighted samples"
description: "How to modify the Maritz-Jarrett method to estimate confidence intervals around given quantiles on weighted samples"
date: "2020-12-08"
tags:
- mathematics
- statistics
- research
- research-wqe
- Quantile
- Confidence Interval
features:
- math
---

**Update 2021-07-06:
  the approach was updated using the [Kish's effective sample size]({{< ref kish-ess-weighted-quantiles >}}).**

When you work with non-parametric distributions,
  quantile estimations are essential to get the main distribution properties.
Once you get the estimation values, you may be interested in measuring the accuracy of these estimations.
Without it, it's hard to understand how trustable the obtained values are.
One of the most popular ways to evaluate accuracy is confidence interval estimation.

Now imagine that you collect some measurements every day.
Each day you get a small sample of values that is not enough to get the accurate daily quantile estimations.
However, the full time-series over the last several weeks has a decent size.
You suspect that past measurements should be similar to today measurements,
  but you are not 100% sure about it.
You feel a temptation to extend the up-to-date sample by the previously collected values,
  but it may spoil the estimation (e.g., in the case of recent change points or positive/negative trends).

One of the possible approaches in this situation is to use *weighted samples*.
This assumes that we add past measurements to the "today sample,"
  but these values should have smaller weight.
The older measurement we take, the smaller weight it gets.
If you have consistent values across the last several days,
  this approach works like a charm.
If you have any recent changes, you can detect such situations by huge confidence intervals
  due to the sample inconsistency.

So, how do we estimate confidence intervals around quantiles for the weighted samples?
In one of the previous posts, I have already shown how to [estimate quantiles on weighted samples]({{< ref weighted-quantiles >}}).
In this post, I will show how to estimate quantile confidence intervals for weighted samples.

<!--more-->

### Quantile confidence interval estimators

There are many different ways to estimate quantiles.
Here are some of the popular approaches:

* **Density estimation**  
  The exact equation for the standard error of the $p^\textrm{th}$ quantile is well-known,
    it equals $\sqrt{p(1-p)}/(\sqrt{n} f(q_p))$ where $f$ is the [probability density function](https://en.wikipedia.org/wiki/Probability_density_function).
  Unfortunately, this equation [requires the knowledge](https://xkcd.com/688/)
    of the density function, which we are actually trying to estimate using quantile.
  Although we can still try to estimate it in different ways.
  For example, we can use Rosenblatt's shifted histogram (see [[Wilcox2017]](#Wilcox2017)).
  However, these approaches don't provide good confidence interval estimation on non-normal distribution.
* **Bootstrap**  
  I'm not a fan of the [bootstrap](https://en.wikipedia.org/wiki/Bootstrapping_(statistics)) method.
  Firstly, it uses randomization, so its results are not repeatable by default.
  Secondly, it's often inefficient: you should spend some time to get reasonable estimations.
  Finally, it works poorly on small samples.
  While bootstrapping is a good option when you don't have any alternatives,
    but we will try to find a better approach.
* **Jackknife**  
  In comparison with bootstrap, the [jackknife](https://en.wikipedia.org/wiki/Jackknife_resampling)
    doesn't have the repeatability problem and can be used to estimate different distribution parameters.
  However, it works poorly in the case of quantile estimation (e.g., see [[Martin1990]](#Martin1990))

I tried different variations of the above approaches,
  but I wasn't satisfied with the results.
Based on my experience, the most optimal approach in terms of accuracy and performance
  is **the Maritz-Jarrett method** ([[Maritz1979]](#Maritz1979)).
Also, it works as a natural extension of the Harrell-Davis quantile estimator ({{< link harrell1982 >}})
  which is my favorite way to estimate quantiles.
Let's discuss how we can adopt the Maritz-Jarrett method to the weighted samples.

### The Maritz-Jarrett method

First of all, let's introduce the following notation:

* $x = \{ x_1, x_2, \ldots x_n \}$: original sample. Assuming that it's always contain sorted real numbers.
* $w = \{ w_1, w_2, \ldots w_n \}$: a vector of weights. It has the same length as $x$. Assuming $w_i \geq 0$, $\sum_{i=1}^n w > 0$.
* $s_i(w)$: partial sum of weights, $s_i(w) = \sum_{j=1}^{i} w_j$. Assuming $s_0(w) = 0$.
* $q_p$: estimation of the $p^\textrm{th}$ quantile based on $x$.

Next, let's recall the basic equations of the Harrell-Davis quantile estimator:

$$
q_p = \sum_{i=1}^{n} W_{n,i} \cdot x_i,\quad
W_{n,i} = I_{r_i}(a, b) - I_{l_i}(a, b),
$$

where

* $I_t(a, b)$ is the [regularized incomplete beta function](https://en.wikipedia.org/wiki/Beta_function#Incomplete_beta_function),
* $a = p \cdot (n + 1), \;\; b = (1-p) \cdot (n + 1)$,
* $l_i = (i - 1) / n, \;\; r_i = i / n$.

Now we introduce notation for the $k^\textrm{th}$ [moment](https://en.wikipedia.org/wiki/Moment_(mathematics)) of the $p^\textrm{th}$ quantile:

$$
C_k = \sum_{i=1}^n W_{n,i} \cdot x_i^k
$$

Thus, $p^\textrm{th}$ quantile estimation $q_p$ is just the first moment $C_1$.

Using the first and the second moments, we can express the standard error as:

$$
s_{q_p} = \sqrt{C_2 - C_1^2}
$$

Here we apply the same idea that we use to express the variance of $X$ as the difference between
  the mean of the square of $X$ and the square of the mean of $X$:

$$
\begin{align}
\operatorname{Var}(X) &= \operatorname{E}\left[(X - \operatorname{E}[X])^2\right] \\
  &= \operatorname{E}\left[X^2 - 2X\operatorname{E}[X] + \operatorname{E}[X]^2\right] \\
  &= \operatorname{E}\left[X^2\right] - 2\operatorname{E}[X]\operatorname{E}[X] + \operatorname{E}[X]^2 \\
  &= \operatorname{E}\left[X^2 \right] - \operatorname{E}[X]^2
\end{align}
$$

### The weighted version of the Maritz-Jarrett method

To adopt the Maritz-Jarrett method to the weighted samples,
  we can use [the same trick]({{< ref weighted-quantiles >}}) we used for the Harrell-Davis quantile estimator (see {{< link harrell1982 >}}).
First, we should replace the sample size by the weighted sample size using the [Kish's effective sample size]({{< ref kish-ess-weighted-quantiles >}}):

$$
n^* = \frac{\Big( \sum_{i=1}^n w_i \Big)^2}{\sum_{i=1}^n w_i^2 }.
$$

Next, we should redefine $a$ and $b$ as follows:

$$
\left\{
\begin{array}{rccl}
a^* = & p     & \cdot & (n^* + 1),\\
b^* = & (1-p) & \cdot & (n^* + 1).
\end{array}
\right.
$$

The segment borders of $I_t(a, b)$ should be updated as well:

$$
\left\{
\begin{array}{rcc}
l^*_i & = & \dfrac{s_{i-1}(w)}{s_n(w)},\\
r^*_i & = & \dfrac{s_i(w)}{s_n(w)}.
\end{array}
\right.
$$

With all the replacements, we get a version of Harrell-Davis quantile estimator adopted for the weighted case:

$$
q^*_p = \sum_{i=1}^{n} W^*_{n,i} \cdot x_i,\quad
W^*_{n,i} = I_{r^*_i}(a^*, b^*) - I_{l^*_i}(a^*, b^*).
$$

At this point, we can introduce a generalized version of the quantile moments:

$$
C^*_k = \sum_{i=1}^n W^*_{n,i} \cdot x_i^k
$$

Finally, we get the formula for the standard error in the weighted case:

$$
s^*_{q_p} = \sqrt{C^*_2 - (C^*_1)^2}
$$

### Building the confidence interval

Based on the given sample, we can get only an estimation of the quantile standard error
  instead of the true standard error.
It means that it would be better to use the Student's t-distribution to estimate
  the confidence interval instead of the normal distribution.

Since we have a weighted sample, we should also use the weighted sample size $n^*$
  instead of the original sample size $n$ to determine the degree of freedom:

$$
\nu^* = n^* - 1.
$$

Thus, the confidence interval with confidence level $\alpha$ may be estimated as follows:

$$
q^*_p \pm t_{\alpha, \nu^*} s^*_{q_p}
$$

### Reference implementation

If you use R, here are functions that you can use in your scripts:

{{< src "mj.R" >}}

If you use C#, you can take an implementation from
  the latest nightly version (0.3.0-nightly.72+) of [Perfolizer](https://github.com/AndreyAkinshin/perfolizer)
  (you need `HarrellDavisQuantileEstimator`).

### References

* <b id="Harrell1982">[Harrell1982]</b>  
  Harrell, F.E. and Davis, C.E., 1982. A new distribution-free quantile estimator.
  *Biometrika*, 69(3), pp.635-640.  
  https://pdfs.semanticscholar.org/1a48/9bb74293753023c5bb6bff8e41e8fe68060f.pdf
* <b id="Maritz1979">[Maritz1979]</b>  
  Maritz, J. S., and R. G. Jarrett. 1978.
  “A Note on Estimating the Variance of the Sample Median.”
  Journal of the American Statistical Association 73 (361): 194–196.  
  https://doi.org/10.1080/01621459.1978.10480027
* <b id="Wilcox2017">[Wilcox2017]</b>  
  Wilcox, Rand R. 2017. Introduction to Robust Estimation and Hypothesis Testing. 4th edition. Waltham, MA: Elsevier. ISBN 978-0-12-804733-0
* <b id="Martin1990">[Martin1990]</b>  
  Martin, Michael A. "On using the jackknife to estimate quantile variance." Canadian Journal of Statistics 18, no. 2 (1990): 149-153.