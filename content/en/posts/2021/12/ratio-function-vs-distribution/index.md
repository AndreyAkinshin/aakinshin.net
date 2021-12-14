---
title: Ratio function vs. shift distribution
date: 2021-12-14
tags:
- Statistics
features:
- math
---

Let's say we have two distributions $X$ and $Y$.
In the [previous post]({{< ref shift-function-vs-distribution >}}),
  we discussed how to express the "absolute difference" between them
  using the shift function and the shift distribution.
Now let's discuss how to express the "relative difference" between them.
This abstract term also could be expressed in various ways.
My favorite approach is to build the [ratio function]({{< ref shift-and-ratio-functions >}}).
In order to do this, for each quantile $p$, we should calculate $Q_Y(p)/Q_X(p)$ where $Q$ is the quantile function.
However, some people prefer using the [ratio distribution](https://en.wikipedia.org/wiki/Ratio_distribution) $Y/X$.
While both approaches may provide similar results for narrow positive non-overlapping distributions,
  they are not equivalent in the general case.
In this post, we briefly consider examples of both approaches.

<!--more-->

### Equal standard normal distributions

Let's start with a simple case when both $X$ and $Y$ are the standard normal distributions:
  $X=Y=\mathcal{N}(0,1)$.
Since distributions are equal, they have equal quantile functions: $Q_X=Q_Y$.
Thus $Q_Y(p)/Q_X(p)$ is $1$ for all $p$ values except $p=0$ (because $Q_Y(0)=Q_X(0)=0$).
Here is the corresponding [ratio function]({{< ref shift-and-ratio-functions >}}):

{{< imgld ratio1 >}}

Such a ratio function tells us that there is no difference between $X$ and $Y$.
If we want to build the ratio function for samples, we should just estimate quantiles for both samples.
As a robust and statistically efficient quantile estimator we can use
  [the trimmed Harrell-Davis quantile estimator]({{< ref preprint-thdqe >}}) (see [[Akinshin2021]](#Akinshin2021)).

We can also build the ratio distribution $Y/X$.
It's well-known that the ratio of two standard normal distributions is
  the [Cauchy distribution](https://en.wikipedia.org/wiki/Cauchy_distribution):

{{< imgld distr1 >}}

Having the Cauchy distribution in your experiments could bring some trouble.
Firstly, this distribution has heavy tails, so that we could expect extremely high outliers.
Secondly, the variance of the Cauchy distribution is undefined so that
  [the Central limit theorem](https://en.wikipedia.org/wiki/Central_limit_theorem) could not be applied there.

### Equal standard uniform distributions

Now let's build both plots for two standard uniform distributions:
  $X=Y=\mathcal{U}(0,1)$.
Obviously, the ratio function is defined as $Q_Y(p)/Q_X(p)=1$ for all $p$ values except $p=0$:

{{< imgld ratio2 >}}

The ratio of two uniform distributions [is defined as follows](https://stats.stackexchange.com/q/185683/261747):

$$
f(x) = \begin{cases}
1/2, & \text{if } 0 \le x \le 1 \\
1/(2x^2), & \text{if } x > 1 \\ 
0, & \text{otherwise}.
\end{cases}
$$

Here is the corresponding plot:

{{< imgld distr2 >}}

This picture describes the actual distribution of $Y/X$, but it doesn't provide useful insights about
  the actual difference between $X$ and $Y$.

### Conclusion

Both the ratio function and the shift distribution may provide
  useful insights about the properties of the difference between $X$ and $Y$.
However, if we want to get a clear picture that shows the actual relative difference between distribution PDFs,
  the ratio function works much better.

### References

* <b id="Akinshin2021">[Akinshin2021]</b>  
  Andrey Akinshin (2021)
  Trimmed Harrell-Davis quantile estimator based on the highest density interval of the given width,  
  [arXiv:2111.11776](https://arxiv.org/abs/2111.11776)
