---
title: Merging extended P² quantile estimators, Part 1
date: 2024-01-02
tags:
- mathematics
- statistics
- research
- research-p2qe
features:
- math
---

[P² quantile estimator]({{< ref research-p2qe >}}) is a streaming quantile estimator
  with $\mathcal{O}(1)$ memory footprint and an extremely fast update procedure.
Several days ago, I learned that it was [adopted](https://twitter.com/rickbrewPDN/status/1740233421673349544) for
  the new Paint.NET GPU-based Median Sketch effect
  (the description is [here](https://forums.getpaint.net/topic/124261-median-sketch-gpu/)).
While P² meets the basic problem requirement (streaming median approximation without storing all the values),
  the algorithm performance is still not acceptable without additional adjustments.
A significant performance improvement [can be obtained](https://twitter.com/rickbrewPDN/status/1740422610545234153)
  if we split the input stream, process each part separately with a separate P², and merge the results.
Unfortunately, the merging procedure is a tricky thing to implement.
I enjoy such challenges, so I decided to attempt to build such a merging approach.
In this post, I describe my first attempt.

<!--more-->

### The problem

Let us start with a simplified problem statement in which we have two streams of numbers of equal size:
  $\mathbf{x} = (x_1, x_2, \ldots, x_n)$ and $\mathbf{y} = (y_1, y_2, \ldots, y_n)$.
We can perform a single pass over each stream, but we cannot store the values.
We can store some intermediate calculation results, but the storage size should still be $\mathcal{O}(1)$.
We want to know the median of the combined stream $\mathbf{z} = (x_1, y_1, x_2, y_2, \ldots, x_n, y_n)$.
The exact median value is not required, a reasonable approximation is enough.
However, the expected approximation error should be reasonable and not depend on the input stream values.

### Speculations

Let us think about what we can do here.

One may be tempted to calculate the median of each stream separately and then aggregate the results somehow.
While this approach may produce an acceptable answer in some cases, it doesn't work in general.
Let us show a generic counterexample parametrized by the variable $R$:

$$
\mathbf{x} = \bigl(
  \underbrace{0, 0, \ldots, 0, 0}_{100\%}
\bigr),
$$

$$
\mathbf{y} = \bigl(
  \underbrace{0, 0, \ldots, 0, 0}_{40\%},
  \underbrace{R, R, R, \ldots, R, R, R}_{60\%}
\bigr),
$$

$$
\mathbf{z} = \bigl(
  \underbrace{0, 0, 0, 0, \ldots, 0, 0, 0}_{70\%},
  \underbrace{R, R, \ldots, R}_{30\%}
\bigr),
$$

It is easy to see that

$$
\operatorname{Median}(x) = 0,\quad
\operatorname{Median}(y) = R,\quad
\operatorname{Median}(z) = 0.
$$

The straightforward aggregation of $\operatorname{Median}(x)$ and $\operatorname{Median}(y)$ is $R/2$,
  which may be arbitrarily larger than $\operatorname{Median}(z) = 0$ depending on $R$.
Therefore, this approach is not workable.

Another idea is to use a streaming quantile estimator that supports merging out of the box.
A good example is [t-digest](https://github.com/tdunning/t-digest).
However, while it is natively designed for such kinds of problems, its implementation is not so trivial:
  it may be challenging to come up with a proper GPU-friendly implementation.
Also, the performance overhead of t-digest is noticeably higher than the P² overhead.
It may be worth trying this idea (we can't say anything for sure without actual measurements),
  but this is an effortful venture that we postpone for the future.
Now, we try to find a simpler solution.

The final idea is to support the merging operations for the P² quantile estimators.
In general, it feels tangible.
However, the classic P² maintains only five markers
  (minimum, $(p/2)^\textrm{th}$ quantile, $p^\textrm{th}$ quantile,
  $((1+p)/2)^\textrm{th}$ quantile, maximum; where $p$ is the target quantile order).
It doesn't feel like enough data for accurate merging implementation.
Fortunately, we have [the extended P² quantile estimator]({{< ref ex-p2-quantile-estimator >}}) (ExP²),
  which maintains more markers.
What if we evaluate ExP² on each stream and use all their marker values to build an aggregated median approximation?
This looks implementable.
Let's try it!

### Setting up ExP²

For simplicity, we will not build the generic implementation but rather focus on the median case $p=0.5$
  (if the idea works, we can generalize it later).
Let us define an ExP² that evaluates $m=2k+1$ uniformly distributed quantiles:

$$
\mathbf{p} = \left(
  \frac{1}{m + 1}, \frac{2}{m + 1}, \ldots, \frac{k+1}{m+1}, \ldots, \frac{m-1}{m+1}, \frac{m}{m+1}
\right).
$$

It is easy to see that the middle quantile is the median:

$$
p_{k+1} = \frac{k+1}{m+1} = \frac{k+1}{2k+2} = 0.5.
$$

The corresponding ExP² will be based on $2m+3$ markers.
Let us evaluate the memory overhead.
We need two `double` arrays for the marker desired positions and their values and
  one `int` array for the actual marker positions.
The target quantile orders are fixed, so we don't need to store them.
The marker count can be a predefined constant.
Therefore, we get

$$
(2m+3) \cdot \bigl( 2 \cdot \operatorname{sizeof}(\texttt{double}) + \operatorname{sizeof}(\texttt{int}) \bigr) =
(2m+3) \cdot 20~\textrm{bytes}.
$$

Plus array overheads (depends on the language/runtime and the current processor architecture),
  plus one variable for the current observation count.
TODO: example

### Merging ExP²

The idea we are going to try today is extremely simple.
We take two ExP² results and treat their markers as the true sub-stream quantile values.
Next, we join these two lists of markers,
  using linear interpolation to determine the quantile orders for the given quantiles
  (it could be upgraded to parabolic interpolation later).
Finally, we use linear interpolation one more time to get the median based on determined values.
See `CustomP2MedianEstimator.GetMedian` for details.

Since it's an experiment, I have written a quick-and-dirty proof-of-concept implementation in C# (do not use it as-is!).

### Demo Time

Here is my hacky proof-of-concept implementation (adjustments are needed)
  and the corresponding results:

{{< src Program.cs >}}

```txt
True:  0.00 | Approx:  0.00 | X:  0.00 | Y:  0.54 | ApproxErr:  0.00 | MeanXYErr:  0.27 | ApproxGain:  0.27
True:  0.00 | Approx:  0.00 | X:  0.54 | Y:  0.00 | ApproxErr:  0.00 | MeanXYErr:  0.27 | ApproxGain:  0.27

*** Uniform ***
True:  0.51 | Approx:  0.51 | X:  0.50 | Y:  0.52 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.51 | Approx:  0.50 | X:  0.51 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.51 | Approx:  0.51 | X:  0.51 | Y:  0.52 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.48 | Approx:  0.49 | X:  0.50 | Y:  0.47 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.51 | Approx:  0.51 | X:  0.51 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.50 | Approx:  0.51 | X:  0.50 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.49 | Approx:  0.50 | X:  0.47 | Y:  0.52 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.47 | Approx:  0.46 | X:  0.47 | Y:  0.46 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.51 | Approx:  0.51 | X:  0.50 | Y:  0.52 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.51 | Approx:  0.50 | X:  0.52 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.50 | Approx:  0.50 | X:  0.50 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.49 | Approx:  0.49 | X:  0.49 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.48 | Approx:  0.49 | X:  0.47 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.51 | Approx:  0.51 | X:  0.52 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.50 | Approx:  0.50 | X:  0.51 | Y:  0.49 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.50 | Approx:  0.50 | X:  0.51 | Y:  0.48 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.49 | Approx:  0.49 | X:  0.47 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.51 | Approx:  0.51 | X:  0.52 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.49 | Approx:  0.49 | X:  0.50 | Y:  0.48 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.48 | Approx:  0.49 | X:  0.49 | Y:  0.48 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.49 | Approx:  0.49 | X:  0.49 | Y:  0.49 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.49 | Approx:  0.49 | X:  0.48 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.51 | Approx:  0.51 | X:  0.51 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.49 | Approx:  0.49 | X:  0.49 | Y:  0.49 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.50 | Approx:  0.50 | X:  0.52 | Y:  0.49 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.50 | Approx:  0.50 | X:  0.50 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.50 | Approx:  0.50 | X:  0.49 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.49 | Approx:  0.49 | X:  0.47 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.50 | Approx:  0.50 | X:  0.50 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.50 | Approx:  0.50 | X:  0.49 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.51 | Approx:  0.51 | X:  0.53 | Y:  0.49 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.52 | Approx:  0.52 | X:  0.52 | Y:  0.52 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.50 | Approx:  0.50 | X:  0.49 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.51 | Approx:  0.51 | X:  0.53 | Y:  0.49 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.49 | Approx:  0.49 | X:  0.47 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.51 | Approx:  0.51 | X:  0.52 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.50 | Approx:  0.50 | X:  0.52 | Y:  0.48 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.51 | Approx:  0.51 | X:  0.53 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.47 | Approx:  0.47 | X:  0.47 | Y:  0.48 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.49 | Approx:  0.49 | X:  0.48 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.49 | Approx:  0.49 | X:  0.48 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.51 | Approx:  0.51 | X:  0.52 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.49 | Approx:  0.49 | X:  0.48 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.47 | Approx:  0.48 | X:  0.47 | Y:  0.48 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.49 | Approx:  0.49 | X:  0.50 | Y:  0.48 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.50 | Approx:  0.50 | X:  0.49 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.50 | Approx:  0.50 | X:  0.50 | Y:  0.49 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.49 | Approx:  0.49 | X:  0.48 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.49 | Approx:  0.49 | X:  0.47 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain: -0.00
True:  0.53 | Approx:  0.52 | X:  0.51 | Y:  0.54 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.50 | Approx:  0.50 | X:  0.50 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.51 | Approx:  0.51 | X:  0.51 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.52 | Approx:  0.52 | X:  0.52 | Y:  0.52 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.50 | Approx:  0.50 | X:  0.50 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.51 | Approx:  0.51 | X:  0.52 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.51 | Approx:  0.51 | X:  0.52 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.50 | Approx:  0.50 | X:  0.52 | Y:  0.49 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.50 | Approx:  0.50 | X:  0.48 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.49 | Approx:  0.50 | X:  0.50 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.49 | Approx:  0.49 | X:  0.48 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.50 | Approx:  0.50 | X:  0.48 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.50 | Approx:  0.50 | X:  0.48 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.49 | Approx:  0.49 | X:  0.49 | Y:  0.49 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.51 | Approx:  0.51 | X:  0.50 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.52 | Approx:  0.52 | X:  0.51 | Y:  0.53 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.49 | Approx:  0.49 | X:  0.48 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.54 | Approx:  0.54 | X:  0.53 | Y:  0.55 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.50 | Approx:  0.50 | X:  0.47 | Y:  0.52 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.50 | Approx:  0.50 | X:  0.49 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.49 | Approx:  0.49 | X:  0.50 | Y:  0.49 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.50 | Approx:  0.50 | X:  0.48 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.51 | Approx:  0.51 | X:  0.50 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.51 | Approx:  0.51 | X:  0.51 | Y:  0.52 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.51 | Approx:  0.51 | X:  0.52 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.51 | Approx:  0.50 | X:  0.51 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.51 | Approx:  0.51 | X:  0.51 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.51 | Approx:  0.51 | X:  0.53 | Y:  0.49 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.51 | Approx:  0.51 | X:  0.51 | Y:  0.52 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.51 | Approx:  0.51 | X:  0.51 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.48 | Approx:  0.48 | X:  0.48 | Y:  0.48 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.49 | Approx:  0.49 | X:  0.48 | Y:  0.49 | ApproxErr:  0.00 | MeanXYErr:  0.01 | ApproxGain:  0.00
True:  0.52 | Approx:  0.52 | X:  0.51 | Y:  0.52 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.50 | Approx:  0.50 | X:  0.51 | Y:  0.49 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.51 | Approx:  0.51 | X:  0.54 | Y:  0.49 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.50 | Approx:  0.50 | X:  0.51 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.49 | Approx:  0.49 | X:  0.47 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.50 | Approx:  0.50 | X:  0.50 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.52 | Approx:  0.52 | X:  0.50 | Y:  0.54 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.50 | Approx:  0.50 | X:  0.51 | Y:  0.48 | ApproxErr:  0.00 | MeanXYErr:  0.01 | ApproxGain:  0.00
True:  0.52 | Approx:  0.52 | X:  0.52 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.52 | Approx:  0.52 | X:  0.51 | Y:  0.53 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.50 | Approx:  0.51 | X:  0.51 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.00 | ApproxGain:  0.00
True:  0.48 | Approx:  0.48 | X:  0.46 | Y:  0.48 | ApproxErr:  0.00 | MeanXYErr:  0.01 | ApproxGain:  0.00
True:  0.52 | Approx:  0.51 | X:  0.47 | Y:  0.55 | ApproxErr:  0.00 | MeanXYErr:  0.01 | ApproxGain:  0.00
True:  0.50 | Approx:  0.49 | X:  0.47 | Y:  0.53 | ApproxErr:  0.00 | MeanXYErr:  0.01 | ApproxGain:  0.00
True:  0.48 | Approx:  0.49 | X:  0.50 | Y:  0.46 | ApproxErr:  0.00 | MeanXYErr:  0.01 | ApproxGain:  0.00
True:  0.50 | Approx:  0.51 | X:  0.52 | Y:  0.50 | ApproxErr:  0.01 | MeanXYErr:  0.01 | ApproxGain:  0.00
True:  0.51 | Approx:  0.50 | X:  0.52 | Y:  0.48 | ApproxErr:  0.00 | MeanXYErr:  0.01 | ApproxGain:  0.00
True:  0.51 | Approx:  0.51 | X:  0.51 | Y:  0.51 | ApproxErr:  0.00 | MeanXYErr:  0.01 | ApproxGain:  0.00
True:  0.50 | Approx:  0.50 | X:  0.52 | Y:  0.50 | ApproxErr:  0.00 | MeanXYErr:  0.01 | ApproxGain:  0.01

*** Bimodal ***
True:  1.00 | Approx:  5.40 | X:  3.49 | Y:  0.89 | ApproxErr:  4.40 | MeanXYErr:  1.19 | ApproxGain: -3.21
True:  0.99 | Approx:  6.73 | X:  4.56 | Y:  3.64 | ApproxErr:  5.74 | MeanXYErr:  3.11 | ApproxGain: -2.63
True:  0.97 | Approx:  4.86 | X:  3.63 | Y:  0.98 | ApproxErr:  3.90 | MeanXYErr:  1.34 | ApproxGain: -2.55
True: 10.00 | Approx:  4.37 | X:  8.14 | Y:  5.21 | ApproxErr:  5.63 | MeanXYErr:  3.33 | ApproxGain: -2.30
True: 10.01 | Approx:  7.41 | X:  9.88 | Y:  9.06 | ApproxErr:  2.60 | MeanXYErr:  0.54 | ApproxGain: -2.06
True: 10.02 | Approx:  6.98 | X: 10.06 | Y:  7.72 | ApproxErr:  3.04 | MeanXYErr:  1.13 | ApproxGain: -1.91
True:  0.99 | Approx:  5.35 | X:  5.94 | Y:  1.30 | ApproxErr:  4.36 | MeanXYErr:  2.63 | ApproxGain: -1.74
True:  0.98 | Approx:  3.51 | X:  2.39 | Y:  1.21 | ApproxErr:  2.53 | MeanXYErr:  0.82 | ApproxGain: -1.71
True: 10.01 | Approx:  7.11 | X:  7.63 | Y:  9.94 | ApproxErr:  2.90 | MeanXYErr:  1.22 | ApproxGain: -1.67
True:  1.00 | Approx:  4.37 | X:  3.73 | Y:  1.67 | ApproxErr:  3.37 | MeanXYErr:  1.71 | ApproxGain: -1.67
True: 10.01 | Approx:  5.80 | X:  5.14 | Y:  9.71 | ApproxErr:  4.21 | MeanXYErr:  2.58 | ApproxGain: -1.63
True: 10.01 | Approx:  7.86 | X:  9.52 | Y:  9.34 | ApproxErr:  2.16 | MeanXYErr:  0.58 | ApproxGain: -1.57
True: 10.01 | Approx:  4.95 | X:  4.98 | Y:  7.96 | ApproxErr:  5.05 | MeanXYErr:  3.54 | ApproxGain: -1.52
True:  0.99 | Approx:  6.16 | X:  5.28 | Y:  4.35 | ApproxErr:  5.17 | MeanXYErr:  3.82 | ApproxGain: -1.35
True: 10.02 | Approx:  6.31 | X:  5.36 | Y:  9.92 | ApproxErr:  3.72 | MeanXYErr:  2.38 | ApproxGain: -1.34
True:  0.98 | Approx:  4.13 | X:  3.81 | Y:  1.84 | ApproxErr:  3.15 | MeanXYErr:  1.85 | ApproxGain: -1.30
True: 10.02 | Approx:  5.84 | X:  8.49 | Y:  5.54 | ApproxErr:  4.18 | MeanXYErr:  3.00 | ApproxGain: -1.18
True: 10.03 | Approx:  8.23 | X:  8.71 | Y: 10.02 | ApproxErr:  1.80 | MeanXYErr:  0.67 | ApproxGain: -1.13
True: 10.00 | Approx:  5.56 | X:  3.41 | Y:  9.94 | ApproxErr:  4.44 | MeanXYErr:  3.33 | ApproxGain: -1.12
True:  1.00 | Approx:  4.57 | X:  4.20 | Y:  2.71 | ApproxErr:  3.57 | MeanXYErr:  2.45 | ApproxGain: -1.11
True: 10.03 | Approx:  8.73 | X: 10.01 | Y:  9.66 | ApproxErr:  1.30 | MeanXYErr:  0.19 | ApproxGain: -1.11
True: 10.01 | Approx:  5.98 | X:  4.40 | Y:  9.72 | ApproxErr:  4.02 | MeanXYErr:  2.94 | ApproxGain: -1.08
True: 10.00 | Approx:  5.08 | X:  6.53 | Y:  5.68 | ApproxErr:  4.92 | MeanXYErr:  3.89 | ApproxGain: -1.03
True:  1.00 | Approx:  7.05 | X:  3.59 | Y:  8.48 | ApproxErr:  6.05 | MeanXYErr:  5.03 | ApproxGain: -1.02
True: 10.01 | Approx:  6.28 | X:  4.47 | Y:  9.81 | ApproxErr:  3.73 | MeanXYErr:  2.87 | ApproxGain: -0.86
True: 10.03 | Approx:  7.13 | X:  9.88 | Y:  5.98 | ApproxErr:  2.91 | MeanXYErr:  2.11 | ApproxGain: -0.80
True:  0.98 | Approx:  2.48 | X:  1.05 | Y:  2.33 | ApproxErr:  1.50 | MeanXYErr:  0.71 | ApproxGain: -0.79
True:  0.99 | Approx:  3.19 | X:  3.28 | Y:  1.70 | ApproxErr:  2.21 | MeanXYErr:  1.50 | ApproxGain: -0.71
True: 10.00 | Approx:  5.00 | X:  4.37 | Y:  6.88 | ApproxErr:  5.00 | MeanXYErr:  4.38 | ApproxGain: -0.62
True: 10.00 | Approx:  6.69 | X:  9.38 | Y:  5.23 | ApproxErr:  3.31 | MeanXYErr:  2.70 | ApproxGain: -0.61
True:  1.00 | Approx:  6.01 | X:  9.24 | Y:  1.66 | ApproxErr:  5.01 | MeanXYErr:  4.45 | ApproxGain: -0.56
True:  5.50 | Approx:  6.29 | X:  1.83 | Y:  9.66 | ApproxErr:  0.79 | MeanXYErr:  0.24 | ApproxGain: -0.55
True:  0.95 | Approx:  4.66 | X:  6.68 | Y:  1.56 | ApproxErr:  3.71 | MeanXYErr:  3.17 | ApproxGain: -0.54
True: 10.02 | Approx:  8.74 | X:  8.57 | Y:  9.58 | ApproxErr:  1.28 | MeanXYErr:  0.95 | ApproxGain: -0.34
True:  0.99 | Approx:  5.16 | X:  1.08 | Y:  8.57 | ApproxErr:  4.17 | MeanXYErr:  3.84 | ApproxGain: -0.33
True: 10.02 | Approx:  6.95 | X:  4.84 | Y:  9.70 | ApproxErr:  3.07 | MeanXYErr:  2.75 | ApproxGain: -0.32
True:  0.96 | Approx:  5.20 | X:  5.84 | Y:  3.94 | ApproxErr:  4.24 | MeanXYErr:  3.93 | ApproxGain: -0.31
True: 10.05 | Approx:  9.76 | X:  9.97 | Y: 10.10 | ApproxErr:  0.29 | MeanXYErr:  0.01 | ApproxGain: -0.28
True:  0.99 | Approx:  5.98 | X:  5.63 | Y:  5.92 | ApproxErr:  4.99 | MeanXYErr:  4.79 | ApproxGain: -0.20
True: 10.01 | Approx:  5.55 | X:  1.61 | Y:  9.72 | ApproxErr:  4.45 | MeanXYErr:  4.34 | ApproxGain: -0.11
True:  0.99 | Approx:  5.46 | X:  1.71 | Y:  9.01 | ApproxErr:  4.47 | MeanXYErr:  4.37 | ApproxGain: -0.10
True: 10.06 | Approx:  9.79 | X:  9.92 | Y:  9.84 | ApproxErr:  0.27 | MeanXYErr:  0.18 | ApproxGain: -0.09
True:  0.99 | Approx:  5.47 | X:  9.06 | Y:  1.79 | ApproxErr:  4.48 | MeanXYErr:  4.43 | ApproxGain: -0.05
True:  0.99 | Approx:  5.55 | X:  1.52 | Y:  9.60 | ApproxErr:  4.56 | MeanXYErr:  4.57 | ApproxGain:  0.01
True:  0.98 | Approx:  5.22 | X:  0.95 | Y:  9.54 | ApproxErr:  4.24 | MeanXYErr:  4.27 | ApproxGain:  0.03
True:  0.98 | Approx:  4.98 | X:  0.92 | Y:  9.29 | ApproxErr:  4.00 | MeanXYErr:  4.12 | ApproxGain:  0.12
True:  1.00 | Approx:  4.16 | X:  6.94 | Y:  1.65 | ApproxErr:  3.16 | MeanXYErr:  3.29 | ApproxGain:  0.13
True: 10.02 | Approx:  5.76 | X:  9.69 | Y:  1.52 | ApproxErr:  4.26 | MeanXYErr:  4.41 | ApproxGain:  0.15
True:  0.99 | Approx:  5.31 | X:  9.78 | Y:  1.20 | ApproxErr:  4.32 | MeanXYErr:  4.50 | ApproxGain:  0.18
True: 10.00 | Approx:  4.99 | X:  3.82 | Y:  5.75 | ApproxErr:  5.01 | MeanXYErr:  5.22 | ApproxGain:  0.20
True:  5.50 | Approx:  3.56 | X:  7.67 | Y:  7.82 | ApproxErr:  1.94 | MeanXYErr:  2.24 | ApproxGain:  0.31
True:  0.96 | Approx:  4.01 | X:  1.00 | Y:  7.66 | ApproxErr:  3.05 | MeanXYErr:  3.37 | ApproxGain:  0.32
True: 10.02 | Approx:  6.52 | X:  6.01 | Y:  6.37 | ApproxErr:  3.49 | MeanXYErr:  3.83 | ApproxGain:  0.34
True:  0.98 | Approx:  4.96 | X:  0.90 | Y:  9.70 | ApproxErr:  3.98 | MeanXYErr:  4.32 | ApproxGain:  0.34
True:  0.97 | Approx:  5.03 | X:  1.16 | Y:  9.58 | ApproxErr:  4.06 | MeanXYErr:  4.40 | ApproxGain:  0.34
True:  0.98 | Approx:  5.01 | X:  2.39 | Y:  8.39 | ApproxErr:  4.03 | MeanXYErr:  4.41 | ApproxGain:  0.38
True: 10.02 | Approx:  5.97 | X:  5.55 | Y:  5.57 | ApproxErr:  4.05 | MeanXYErr:  4.46 | ApproxGain:  0.41
True: 10.02 | Approx:  8.09 | X:  6.08 | Y:  9.17 | ApproxErr:  1.93 | MeanXYErr:  2.39 | ApproxGain:  0.47
True: 10.02 | Approx:  6.49 | X:  9.91 | Y:  2.12 | ApproxErr:  3.53 | MeanXYErr:  4.01 | ApproxGain:  0.48
True:  1.00 | Approx:  6.94 | X:  9.97 | Y:  4.87 | ApproxErr:  5.94 | MeanXYErr:  6.42 | ApproxGain:  0.48
True: 10.00 | Approx:  6.10 | X:  1.51 | Y:  9.71 | ApproxErr:  3.90 | MeanXYErr:  4.39 | ApproxGain:  0.49
True:  0.97 | Approx:  3.85 | X:  1.09 | Y:  7.87 | ApproxErr:  2.88 | MeanXYErr:  3.51 | ApproxGain:  0.63
True:  0.99 | Approx:  3.47 | X:  1.52 | Y:  6.95 | ApproxErr:  2.48 | MeanXYErr:  3.25 | ApproxGain:  0.76
True: 10.04 | Approx:  8.54 | X:  9.47 | Y:  6.07 | ApproxErr:  1.50 | MeanXYErr:  2.27 | ApproxGain:  0.77
True: 10.02 | Approx:  6.44 | X:  9.25 | Y:  1.93 | ApproxErr:  3.58 | MeanXYErr:  4.43 | ApproxGain:  0.85
True:  0.97 | Approx:  4.77 | X:  2.89 | Y:  8.34 | ApproxErr:  3.80 | MeanXYErr:  4.65 | ApproxGain:  0.85
True:  0.97 | Approx:  3.67 | X:  6.64 | Y:  2.52 | ApproxErr:  2.70 | MeanXYErr:  3.61 | ApproxGain:  0.91
True:  0.94 | Approx:  4.01 | X:  1.00 | Y:  8.87 | ApproxErr:  3.06 | MeanXYErr:  3.99 | ApproxGain:  0.93
True: 10.06 | Approx:  7.27 | X: 10.20 | Y:  2.38 | ApproxErr:  2.79 | MeanXYErr:  3.77 | ApproxGain:  0.98
True: 10.01 | Approx:  5.07 | X:  2.81 | Y:  5.36 | ApproxErr:  4.94 | MeanXYErr:  5.93 | ApproxGain:  0.99
True: 10.00 | Approx:  7.51 | X:  3.41 | Y:  9.51 | ApproxErr:  2.50 | MeanXYErr:  3.54 | ApproxGain:  1.04
True: 10.02 | Approx:  5.20 | X:  6.16 | Y:  1.99 | ApproxErr:  4.82 | MeanXYErr:  5.95 | ApproxGain:  1.13
True:  0.98 | Approx:  4.41 | X:  7.19 | Y:  3.91 | ApproxErr:  3.43 | MeanXYErr:  4.57 | ApproxGain:  1.14
True:  0.98 | Approx:  3.10 | X:  1.61 | Y:  6.99 | ApproxErr:  2.12 | MeanXYErr:  3.32 | ApproxGain:  1.20
True: 10.03 | Approx:  7.39 | X:  9.11 | Y:  3.23 | ApproxErr:  2.65 | MeanXYErr:  3.86 | ApproxGain:  1.21
True: 10.00 | Approx:  5.27 | X:  3.17 | Y:  4.69 | ApproxErr:  4.74 | MeanXYErr:  6.07 | ApproxGain:  1.33
True:  0.96 | Approx:  3.27 | X:  1.06 | Y:  8.17 | ApproxErr:  2.31 | MeanXYErr:  3.66 | ApproxGain:  1.35
True: 10.02 | Approx:  6.95 | X:  7.81 | Y:  3.25 | ApproxErr:  3.07 | MeanXYErr:  4.49 | ApproxGain:  1.42
True: 10.03 | Approx:  8.05 | X:  9.80 | Y:  3.11 | ApproxErr:  1.99 | MeanXYErr:  3.58 | ApproxGain:  1.59
True: 10.05 | Approx:  8.11 | X: 10.06 | Y:  2.51 | ApproxErr:  1.94 | MeanXYErr:  3.77 | ApproxGain:  1.82
True:  1.00 | Approx:  5.58 | X:  5.34 | Y:  9.55 | ApproxErr:  4.58 | MeanXYErr:  6.45 | ApproxGain:  1.87
True:  0.98 | Approx:  5.10 | X:  8.00 | Y:  5.96 | ApproxErr:  4.11 | MeanXYErr:  5.99 | ApproxGain:  1.88
True:  0.98 | Approx:  6.98 | X:  9.28 | Y:  8.55 | ApproxErr:  5.99 | MeanXYErr:  7.93 | ApproxGain:  1.94
True:  0.98 | Approx:  4.47 | X:  7.62 | Y:  5.45 | ApproxErr:  3.49 | MeanXYErr:  5.56 | ApproxGain:  2.07
True:  0.98 | Approx:  5.42 | X:  5.92 | Y:  9.26 | ApproxErr:  4.44 | MeanXYErr:  6.60 | ApproxGain:  2.17
True: 10.01 | Approx:  5.46 | X:  4.11 | Y:  2.44 | ApproxErr:  4.54 | MeanXYErr:  6.73 | ApproxGain:  2.19
True: 10.01 | Approx:  5.21 | X:  1.91 | Y:  3.69 | ApproxErr:  4.79 | MeanXYErr:  7.20 | ApproxGain:  2.41
True: 10.03 | Approx:  6.25 | X:  4.32 | Y:  3.35 | ApproxErr:  3.77 | MeanXYErr:  6.19 | ApproxGain:  2.42
True:  0.97 | Approx:  4.36 | X:  7.37 | Y:  6.24 | ApproxErr:  3.38 | MeanXYErr:  5.83 | ApproxGain:  2.45
True: 10.02 | Approx:  7.25 | X:  3.24 | Y:  6.21 | ApproxErr:  2.78 | MeanXYErr:  5.30 | ApproxGain:  2.52
True:  0.98 | Approx:  5.02 | X:  8.02 | Y:  7.82 | ApproxErr:  4.04 | MeanXYErr:  6.94 | ApproxGain:  2.90
True: 10.01 | Approx:  5.86 | X:  2.13 | Y:  3.68 | ApproxErr:  4.15 | MeanXYErr:  7.10 | ApproxGain:  2.95
True:  0.97 | Approx:  3.37 | X:  7.12 | Y:  6.04 | ApproxErr:  2.40 | MeanXYErr:  5.60 | ApproxGain:  3.21
True: 10.02 | Approx:  6.29 | X:  3.84 | Y:  1.81 | ApproxErr:  3.73 | MeanXYErr:  7.19 | ApproxGain:  3.46
True: 10.04 | Approx:  6.61 | X:  2.58 | Y:  3.38 | ApproxErr:  3.43 | MeanXYErr:  7.06 | ApproxGain:  3.62
True: 10.02 | Approx:  8.25 | X:  5.16 | Y:  3.82 | ApproxErr:  1.77 | MeanXYErr:  5.53 | ApproxGain:  3.76
True: 10.01 | Approx:  8.43 | X:  4.16 | Y:  5.15 | ApproxErr:  1.57 | MeanXYErr:  5.36 | ApproxGain:  3.78
True: 10.02 | Approx:  8.49 | X:  3.45 | Y:  5.03 | ApproxErr:  1.52 | MeanXYErr:  5.77 | ApproxGain:  4.25
True: 10.02 | Approx:  7.92 | X:  3.14 | Y:  3.89 | ApproxErr:  2.10 | MeanXYErr:  6.51 | ApproxGain:  4.40
True: 10.05 | Approx:  8.50 | X:  3.84 | Y:  3.80 | ApproxErr:  1.55 | MeanXYErr:  6.23 | ApproxGain:  4.67
```

### Conclusion

In general, the suggested merging procedure works well, the experiment is successful.
It perfectly handles the corner case we discussed in the beginning.
However, I wouldn't say that is noticeably superior to the average of separate sub-stream medians.
Fortunately, we have room for improvement.
Here is my plan for further idea development:

* Check the correctness of the current implementation and fix bugs.
  It is worth debugging cases when the suggested approach works much worse than the average of the medians.
* Use parabolic interpolation instead of the linear one.
* Add more different distributions to the dataset to make proper exploration research.
* Investigate how we should choose the appropriate number of markers based on the expected stream length.
* Generalize the algorithms and support all the corner cases
  (e.g., streams of unequal lengths, evaluation of arbitrary quantiles, merging multiple estimators, etc.).

### References

* <b id="Jain1985">[Jain1985]</b>  
  Jain, Raj, and Imrich Chlamtac.
  "The P² algorithm for dynamic calculation of quantiles and histograms without storing observations."
  Communications of the ACM 28, no. 10 (1985): 1076-1085.  
  https://doi.org/10.1145/4372.4378
* <b id="Raatikainen1987">[Raatikainen1987]</b>  
  Raatikainen, Kimmo EE. "Simultaneous estimation of several percentiles."
  Simulation 49, no. 4 (1987): 159-163.  
  https://doi.org/10.1177/003754978704900405
