---
title: "Better moving quantile estimations using the partitioning heaps"
description: "Improvements of the Hardle-Steiger method that allows estimating moving quantiles using linear interpolation"
date: "2021-01-19"
tags:
- mathematics
- statistics
- research
- Quantile
- Moving Quantile
features:
- math
---

In one of the previous posts, I [have discussed]({{< ref partitioning-heaps-quantile-estimator >}}) the Hardle-Steiger method.
This algorithm allows estimating [the moving median](https://en.wikipedia.org/wiki/Moving_average#Moving_median)
  using $O(L)$ memory and $O(log(L))$ element processing complexity (where $L$ is the window size).
Also, I have shown how to adapt this approach to estimate *any* moving quantile.

In this post, I'm going to present further improvements.
The Hardle-Steiger method always returns the [order statistics](https://en.wikipedia.org/wiki/Order_statistic)
  which is the $k\textrm{th}$ smallest element from the sample.
It means that the estimated quantile value always equals one of the last $L$ observed numbers.
However, many of the classic quantile estimators use two elements.
For example, if we want to estimate the median for $x = \{4, 5, 6, 7\}$,
  some estimators return $5.5$ (which is the arithmetical mean of $5$ and $6$)
  instead of $5$ or $6$ (which are order statistics).

Let's learn how to implement a moving version of such estimators using
  the partitioning heaps from the Hardle-Steiger method.

<!--more-->

### The Hyndman-Fan classification

There are many different quantile estimators.
In [[Hyndman1996]](#Hyndman1996), Rob Hyndman and Yanan Fan have described
  nine estimators that are used in popular statistical packages.
They are based on a single order statistic or on linear interpolation
  of two subsequent order statistics.
Below you can see equations for each type that
  estimate $p^\textrm{th}$ quantile for a sorted sample $x$ of size $N$.

| Type | h              | Equation                                                                                     |
| ---- | -------------- | -------------------------------------------------------------------------------------------- |
| 1    | $Np+1/2$       | $x_{\lceil h - 1/2 \rceil}$                                                                  |
| 2    | $Np+1/2$       | $(x_{\lceil h - 1/2 \rceil} + x_{\lceil h + 1/2 \rceil})/2$                                  |
| 3    | $Np$           | $x_{\lfloor h \rceil}$                                                                       |
| 4    | $Np$           | $x_{\lfloor h \rfloor}+(h-\lfloor h \rfloor)(x_{\lfloor h \rfloor+1})-x_{\lfloor h \rfloor}$ |
| 6    | $(N+1)p$       | $x_{\lfloor h \rfloor}+(h-\lfloor h \rfloor)(x_{\lfloor h \rfloor+1})-x_{\lfloor h \rfloor}$ |
| 5    | $Np+1/2$       | $x_{\lfloor h \rfloor}+(h-\lfloor h \rfloor)(x_{\lfloor h \rfloor+1})-x_{\lfloor h \rfloor}$ |
| 7    | $(N-1)p+1$     | $x_{\lfloor h \rfloor}+(h-\lfloor h \rfloor)(x_{\lfloor h \rfloor+1})-x_{\lfloor h \rfloor}$ |
| 8    | $(N+1/3)p+1/3$ | $x_{\lfloor h \rfloor}+(h-\lfloor h \rfloor)(x_{\lfloor h \rfloor+1})-x_{\lfloor h \rfloor}$ |
| 9    | $(N+1/4)p+3/8$ | $x_{\lfloor h \rfloor}+(h-\lfloor h \rfloor)(x_{\lfloor h \rfloor+1})-x_{\lfloor h \rfloor}$ |

As you can see, only Type 1 and Type 3 estimators use a single order statistic.
The other types use an equation based on linear interpolation.

Type 7 is the most popular quantile estimator which is used by default in
    R, Julia, NumPy, Excel (`PERCENTILE`, `PERCENTILE.INC`), Python (`inclusive` method).

### The partitioning heaps data structure

In [[Hardle1995]](#Hardle1995), W. Hardle and W. Steiger have described a method
  of estimating the moving median.
Their approach uses a data structure based on two [heaps](https://en.wikipedia.org/wiki/Heap_(data_structure))
  which they call *partitioning heaps*:

{{< img src="double-heap" width="400" >}}

In this figure, you see an example for $L=21$ ($L$ is the window size).
It contains:

* $H_1 .. H_{10}$: min heap
* $H_{-1} .. H_{-10}$: max heap
* $H_0$: a node that joins two heaps

The $H$ array contain the last $L$ elements of the time series and satisfy the following conditions:

* $\max(H_{-2i},\; H_{-2i-1}) \leq H_{-i} \leq H_0$
* $\min(H_{2i},\; H_{2i+1}) \geq H_{i} \geq H_0$

Thus, $H_0$ is
  less than all elements in the upper heap (positive indexes) and
  greater than all elements in the lower heap (negative indexes).
Since we have an equal number of elements in both heaps,
  $H_0$ represents the median value.

Once we get a new number in our stream,
  we should replace the "oldest" number in this data structure with the new one.
Next, we should normalize the heaps to satisfy the above conditions.
This operation's algorithmic complexity is $O(log(L))$.

If we modify the number of elements in the min heap or the max heap,
  we can get any quantile value instead of the median
  (see [previous post]({{< ref partitioning-heaps-quantile-estimator >}}) for details).

### Applying the Hyndman-Fan equations for the partitioning heaps

All of the equations described by Rob Hyndman and Yanan Fan use
  no more than two subsequent order statistics.
Let's look closely at the figure with the partitioning heaps.
We may notice that we already have values of the required elements.
If $H_0$ is the $k^\textrm{th}$ smallest element,
  $H_{-1}$ is the $(k-1)^\textrm{th}$ smallest element!
Indeed, $H_{-1} \leq H_0 \leq H_i$ for $i>0$
  and $H_{-1} \geq H_i$ for $i < -1$.
By analogy, $H_1$ is the $(k+1)^\textrm{th}$ smallest element.

Since we already have both required element values,
  we can apply the Hyndman-Fan equations without any changes in the data structure.
It's a super-simple improvement, but it allows achieving consistency between
  the moving quantile estimator based on the partitioning heaps
  and the classic quantile estimators from the Hyndman-Fan classification.

### Reference implementation

If you use C#, you can take an implementation from
  the latest nightly version (0.3.0-nightly.86+) of [Perfolizer](https://github.com/AndreyAkinshin/perfolizer)
  (you need `PartitioningHeapsMovingQuantileEstimator`).

### Conclusion

In this post, we improved the Hardle-Steiger method ([[Hardle1995]](#Hardle1995)).
Now it's able to estimate any moving quantiles
  using any of the equations described in the Hyndman-Fan classification ([[Hyndman1996]](#Hyndman1996)).
The suggested approach has the following characteristics ($L$ is the window size):

* Memory: $O(L)$
* Element processing complexity: $O(log(L))$
* Quantile estimating complexity: $O(1)$

### References

* <b id="Hyndman1996">[Hyndman1996]</b>  
  Hyndman, R. J. and Fan, Y. 1996. Sample quantiles in statistical packages, *American Statistician* 50, 361–365.  
  https://doi.org/10.2307/2684934
* <b id="Hardle1995">[Hardle1995]</b>  
  Hardle, W., and William Steiger. "Algorithm AS 296: Optimal median smoothing." Journal of the Royal Statistical Society. Series C (Applied Statistics) 44, no. 2 (1995): 258-264.  
  https://doi.org/10.2307/2986349