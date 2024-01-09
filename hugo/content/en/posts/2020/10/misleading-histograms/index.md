---
title: "Misleading histograms"
date: "2020-10-20"
tags:
- mathematics
- statistics
- research
- Multimodality
- Histograms
features:
- math
---

Below you see two histograms.
What could you say about them?

{{< imgld hist-riddle >}}

Most likely, you say that the first histogram is based on a uniform distribution,
  and the second one is based on a multimodal distribution with four modes.
Although this is not obvious from the plots,
  both histograms are based on the same sample:

```cs
20.13, 19.94, 20.03, 20.06, 20.04, 19.98, 20.15, 19.99, 20.20, 19.99, 20.13, 20.22, 19.86, 19.97, 19.98, 20.06,
29.97, 29.73, 29.75, 30.13, 29.96, 29.82, 29.98, 30.12, 30.18, 29.95, 29.97, 29.82, 30.04, 29.93, 30.04, 30.07,
40.10, 39.93, 40.05, 39.82, 39.92, 39.91, 39.75, 40.00, 40.02, 39.96, 40.07, 39.92, 39.86, 40.04, 39.91, 40.14,
49.95, 50.06, 50.03, 49.92, 50.15, 50.06, 50.00, 50.02, 50.06, 50.00, 49.70, 50.02, 49.96, 50.01, 50.05, 50.13
```

Thus, the only difference between histograms is the offset!

Visualization is a simple way to understand the shape of your data.
Unfortunately, this way may easily become a slippery slope.
In the [previous post]({{< ref "kde-bw" >}}), I have shown how density plots may deceive you when the bandwidth is poorly chosen.
Today, we talk about histograms and why you can't trust them in the general case.

<!--more-->

## Histograms

A histogram is one of the simplest ways to present the shape of your data.
Let's say we have a sample $\{ 1.1, 2.1, 2.2, 2.3, 3.1, 3.2 \}$.
It can be presented using the following histogram:

{{< imgld hist-simple >}}

It consists of three bins: $[0.5; 1.5]$, $[1.5; 2.5]$, $[2.5; 3.5]$.
The height of each bin is the number of elements in the corresponding interval.
Small strokes under the histogram is an optional adornment that shows values of the elements
  (it's called [rug plot](https://en.wikipedia.org/wiki/Rug_plot)).

Here we have no tricky equations with integrals, no complex algorithms, no 200 pages user manual.
This is one of the most straightforward approaches in mathematical statistics.
It's easy to build and interpret such plots.
What could go wrong?

## Histogram offset

Despite the simplicity, this approach is not entirely straightforward.
We have to define two parameters to build a histogram.
The first one is the *offset* which is the location of the first bin.
Let's consider another sample: $\{ 18, 19, 21, 22, 38, 39, 41, 42 \}$.
First, we build a histogram with $\textrm{offset} = 15$:

{{< imgld hist-offset1 >}}

Here we have three bins: $[15; 25]$, $[25; 35]$, $[35; 45]$.
The first one and the last one contains four elements each; the middle one is empty.

Next, we build another histogram with $\textrm{offset} = 10$ based on the same sample:

{{< imgld hist-offset2 >}}

Here we have four bins: $[10; 20]$, $[20; 30]$, $[30; 40]$, $[40; 50]$.
Each of them contains exactly two elements.

We have the same sample in both cases, but the histogram shapes are different because of different offsets.
It may lead us to the idea that we need a smart algorithm to choose the perfect offset.
Unfortunately, it's not always possible.
Let's consider another sample: $\{ 18, 19, 21, 22, 38, 39, 41, 42, 53, 54, 56, 57 \}$.
It looks like a trimodal distribution:
```cs
18, 19, 21, 22, // First mode
38, 39, 41, 42, // Second mode
53, 54, 56, 57  // Third mode
```

And here is a few attempt to build a histogram (with $\textrm{offset} = 10$, $\textrm{offset} = 15$):

{{< imgld hist-offset3 >}}

The problem arises when we have at least three modes with different distances between them.
For this particular example, you can find an offset that highlights all three modes.
But it will not be a perfect trimodal shape because gaps will not be empty.
In more complicated cases, it's almost impossible to get a histogram that presents the actual shape of the data.

You may think that statistical packages that you use should help you to automatically choose a good value.
It's not true.
Usually, they use the most simple heuristics to choose the offset.
Most of them don't allow controlling the offset at all.

OK, if we can't find a good offset, maybe we can get a better histogram shape by reducing the *bandwidth* (the width of the bins)?

## Histogram bandwidth

Let's consider below histograms for another bimodal sample with different bandwidth values:

{{< imgld hist-bandwidth1 >}}

By [analogy with kernel density estimation]({{< ref "kde-bw" >}}#how-bandwidth-selection-affects-plot-smoothness),
 we have two unwanted effects of poorly chosen bandwidths:

* **Oversmoothing**  
  The bandwidth is too big, the true shape of the data is hidden.
* **Undersmoothing**  
  The bandwidth is too small, the histogram looks like a combination of separated spikes.

Thus, we want to get a perfect bandwidth value.
Let's go back to the first 64-element sample from the beginning of the post and try some most popular formulas that define the number of bins $k$:

* **Square-root choice**: $k = \lceil \sqrt{n} \rceil = \lceil \sqrt{64} \rceil = 8$
* **Sturges' formula**: $k = \lceil \log_2 n \rceil = \lceil \log_2 64 \rceil = 6$
* **Rice Rule**: $k = \lceil 2 \sqrt[3]{n} \rceil = \lceil 2 \sqrt[3]{64} \rceil = 8$
* **Doane's formula**: $k = \lceil 2 \sqrt[3]{n} \rceil = \lceil 2 \sqrt[3]{64} \rceil = 8$
* **Scott's normal reference rule**: $k = \lceil (\max(x) - \min(x)) / (3.49 \hat{\sigma}/\sqrt[3]{n})\rceil = 4$
* **Freedman–Diaconis' choice**: $k = \lceil (\max(x) - \min(x)) / ( 2 \cdot \textrm{IQR}(x)/\sqrt[3]{n} )\rceil = 4$

It's not a perfect competition because most of these equations assume normally distributed data.
However, even non-parametric rules give us pretty small values (usually, in the range $4..8$).
As we can see in the first image, 8 bins are not enough to resolve the offset problem.

In most cases, people rely on the default bandwidth selection algorithm, which is not optimal in multimodal cases.
Of course, it's always possible to manually set a proper bandwidth, but this challenging task is often neglected.

Thus, you should always be a little be distrustful of classic histograms with fixed bandwidth
  that are drawn by your favorite statistical package.

## Improving histograms

There are two popular ways to improve your histograms and reduce the risk of incorrect presentation:
  add the *rug plot* and add the *kernel density estimation*.
Let's look at how they can help us with the first 64-element sample from the beginning of the post.

* **Rug plot**  
  {{< imgld hist-riddle-rug >}}
  Here we added a rug plot below the histogram.
  We see that most of the strokes are close to the bin borders.
  In such situations, we can understand that something is wrong with the histograms and try to adjust offset/bandwidth values.

* **Kernel density estimation**  
  {{< imgld hist-riddle-kde >}}
  Here we added a kernel density estimation (KDE) as an overlay using the Sheather & Jones method.
  We see that the density is not consistent with the histogram.
  This is also a sign to adjust offset/bandwidth values.
  Remember, that KDE may also [easily deceive you]({{< ref "kde-bw" >}}).
  It's not affected by the offset problem, but it's still hard to choose the proper kernel and bandwidth.
  Also, note that here we have a mix of two different kinds of visualization.
  Histograms try to present the shape of *your actual data*,
    while KDE tries to present the shape of the *estimated underlying distribution*.
  These two concepts may sound similar, but they can have very different representations.
  Thus, you *can improve* your histogram using KDE, but you *can't replace* it with KDE.

## Alternative approaches

So, if classic histograms and kernel density plots may easily deceive us, what should we use to get an idea of the data shape?
As usual, there is no universal magic answer that fits all the situations.
But I can suggest two interesting directions:

* **Histograms with variable bandwidth**  
  The idea is simple: instead of fixed width for all bins, we can define its own width for each bin.
  The implementation is not so simple.
  I didn't find any good-looking papers/implementations of this approach, so I come up with my own.
  The detailed description can be found in the fourth chapter of [Pro .NET Benchmarking]({{< ref prodotnetbenchmarking >}}).
  It's implemented in [perfolizer](https://github.com/AndreyAkinshin/perfolizer) (look for `AdaptiveHistogramBuilder`) and it has been used by default in [BenchmarkDotNet](https://github.com/dotnet/BenchmarkDotNet) for several years.
  So far, it works well, but I'm still not completely satisfied: I know some corner cases in which the output is far from perfect.
* **Empirical probability density plots**  
  Such plots are similar to kernel density estimations plots,
    but they are based on the sample instead of the distribution estimate.
  Thus, they accurately describe the actual data and don't have the offset/bandwidth problems which are hard to solve using histograms.
  In future posts, I will show how to build and use such plots.

## Conclusion

Despite its simplicity, classic histograms with fixed bandwidth may deceive you and present data in the wrong way.

If you want to build a good histogram, it's crucial to choose proper offset and bandwidth.
Most statistical packages use a naive approach to set these values.
Usually, it's OK for unimodal distributions: poorly chosen parameters don't produce a noticeable impact in most cases.
A series of properly constructed histograms may create a false sense of security.
However, one day you may try to build a histogram for a multimodal distribution, get a distorted picture, and even don't notice it.

You can reduce the chances of such situations by adding the *rug plot* or the *kernel density estimation* to your histogram.
Alternatively, you can look for more reliable ways to present the shape of your data like *histograms with variable bandwidth* or the *empirical probability density plots*.