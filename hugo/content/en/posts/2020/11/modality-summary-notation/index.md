---
title: "Plain-text summary notation for multimodal distributions"
description: "In this post, we consider a plain-text notation for multimodal distributions that highlights modes and outliers"
date: "2020-11-17"
tags:
- Mathematics
- Statistics
- Research
- Multimodality Detection
- Multimodality Detection Based on Density
- QRDE
- Harrell-Davis quantile estimator
- Outliers
features:
- math
---

Let's say you collected a lot of data and want to explore the underlying distributions of collected samples.
If you have only a few distributions, the best way to do that is to look at the density plots
  (expressed via histograms, kernel density estimations, or [quantile-respectful density estimations]({{< ref qrde-hd >}})).
However, it's not always possible.

Suppose you have to process dozens, hundreds, or even thousands of distributions.
In that case,
  it may be extremely time-consuming to manually check visualizations of each distribution.
If you analyze distributions from the command line or send notifications about suspicious samples,
  it may be impossible to embed images in the reports.
In these cases, there is a need to present a distribution using plain text.

One way to do that is plain text histograms.
Unfortunately, this kind of visualization may occupy o lot of space.
In complicated cases, you may need 20 or 30 lines per a single distribution.

Another way is to present classic [summary statistics](https://en.wikipedia.org/wiki/Summary_statistics)
  like mean or median, standard deviation or median absolute deviation, quantiles, skewness, and kurtosis.
There is another problem here:
  without experience, it's hard to reconstruct the true distribution shape based on these values.
Even if you are an experienced researcher, the statistical metrics may become misleading in the case of multimodal distributions.
Multimodality is one of the most severe challenges in distribution analysis because it distorts basic summary statistics.
It's important to not only find such distribution but also have a way to present brief information about multimodality effects.

So, how can we condense the underlying distribution shape of a given sample to a short text line?
I didn't manage to find an approach that works fine in my cases, so I came up with my own notation.
Most of the interpretation problems in my experiments arise from multimodality and outliers,
  so I decided to focus on these two things and specifically highlight them.
Let's consider this plot:

{{< imgld thumbnail >}}

I suggest describing it like this:

```bash
{1.00, 2.00} + [7.16; 13.12]_100 + {19.00} + [27.69; 32.34]_100 + {37.00..39.00}_3
```

Let me explain the suggested notation in detail.

<!--more-->

### Getting summary numbers

I explained how to find modes and outliers in previous blog posts:

* ["Lowland multimodality detection"]({{< ref lowland-multimodality-detection >}}) explains how to find the exact number of modes and their locations based on the given sample
* ["Intermodal outliers"]({{< ref intermodal-outliers >}}) explains how to find mode ranges and detect intermodal outliers together with the global lower and upper outliers

Once we finished the calculations, we get a series of subsets of the given samples like this:

* Lower outliers
* Mode range #1
* Intermodal outliers
* Mode range #2
* Intermodal outliers
* ...
* Intermodal outliers
* Mode range #N
* Upper outliers

In the case of the unimodal distribution, we have only three subsets:

* Lower outliers
* Mode range
* Upper outliers

Note that some of the outlier subsets may be empty.
Meanwhile, mode ranges are always non-empty.

### Mode ranges

On the first step of the distribution exploration, we are often most interested in the range of values.
So, we can present a mode range as an interval from the minimum to the maximum sample element inside the mode range:

```bash
[7.16; 13.12]
```

If we want more details, we may also want to know the central tendency.
In the case of a single mode, the most reasonable metric is the mode location itself.
We can present it between the minimum and the maximum values:

```bash
[7.16 | 10.03 | 13.12]
```

The next thing that is also good to know is accuracy.
Unfortunately, it's hard to find a good metric that describes the accuracy of all three numbers at the same time.
Even if we focus only on the mode value, we can try to introduce a confidence interval for the mode value,
  but it will be hard to present it in an easily interpreted form without a long legend.
Since we describe the raw sample, it makes sense to present the number of elements in the range.
It provides a basic idea of accuracy.
For example, if a range contains only 5 elements, we can assume that the presented values are rough and untrustable.
If a range contains 10000 elements, we can assume that the presented values are pretty accurate.
If we are interested in more sophisticated metrics, we can always check them later.
However, the raw number of elements in the range is usually enough on the first step of exploration.
We can add this number as follows:

```bash
[7.16; 13.12]_100
[7.16 | 10.03 | 13.12]_100
```

### Outlier ranges

When we have no more than two outliers, we can present them as a set:

```bash
{1.00}
{1.00, 2.00}
```

If the number of outliers is more than two, we can skip the middle outliers using `..`:

```bash
{1.00..3.00}
```

Thus, we get the value of the minimum and maximum outlier in the given group.
We can also show the number of outliers in this group as we did for mode ranges:

```bash
{1.00..3.00}_5
```

The outlier and mode ranges are easy to distinguish because they use different symbols
  (`{A..B}` for outliers and `[A; B]` for modes).

### Range combination

Once we presented the mode ranges and the outliers group, we can just concatenate them using the `+` sign:

```bash
{1.00, 2.00} + [7.16; 13.12]_100 + {19.00} + [27.69; 32.34]_100 + {37.00..39.00}_3
```

This notation can be interpreted as follows:

* *Lower outliers*: `{1.00, 2.00}` (two elements)
* *Mode #1*: `[7.16; 13.12]_100` (100 elements between 7.16 and 13.12)
* *Intermodal outliers*: `{19.00}` (one element)
* *Mode #2*: `[27.69; 32.34]_100` (100 elements between 27.69 and 32.34)
* *Upper outliers*: `{37.00..39.00}_3` (three elements)

### Compaction vs. detailing

This notation aims to provide the most important information about the distribution in a very short way.
Some optional details like the number of elements in the ranges and the mode location may be useful for a unimodal distribution:

```bash
{3.12} + [12.56 | 15.91 | 25.03]_100 + {74.92..82.31}_5
```

However, if we describe a bimodal distribution, such detailing may be quite long:

```bash
{1.00, 2.00} + [7.16 | 10.02 | 13.12]_100 + {19.00} + [27.69 | 29.92 | 32.34]_100 + {37.00..39.00}_3
```

In this case, the mode location can be omitted since it's not so useful on the first step of exploration.
Mode ranges are much more important.
Thus, we can remove this value and make the notation shorter.
Optionally, the number of elements can be also omitted:

```bash
{1.00, 2.00} + [7.16; 13.12] + {19.00} + [27.69; 32.34] + {37.00..39.00}
```

In this case, we still keep the most important high-level information about modality and outliers.

However, if we describe a distribution with many modes, the notation may become long again:

```bash
{1.00, 2.00} + [7.16; 13.12] + {19.00} + [27.69; 32.34] + {37.00..39.00} +
               [47.12; 52.41] + {61.00} + [66.91; 73.12] + {78.00, 79.00}
```

In this case, we are not interested in the exact range of each node.
For the brief overview, it would be enough to get the idea of the overall range and the number of modes.
So, we can omit the middle nodes like this:

```bash
{1.00, 2.00} + [7.16; 13.12] + <2 modes> + [66.91; 73.12] + {78.00, 79.00}
```

Using these tricks, we can always compact this notation to a form of the reasonable size
  that highlights the most important information for the first look exploration.

### Missing metrics

The suggested notation doesn't contain some of the metrics usually included in such a kind of summaries.
Below you can find my reasoning that shows why I excluded some common metrics.

* **Global median**  
  In the multimodal case, the global median value without a density plot
    may be misleading when it's located between modes.
  {{< imgld median1 >}}
* **Mode range median**  
  The median often leads to a wrong impression about the skewness.
  Based on my experience, when people see a combination of a range and a central tendency,
    they imagine the central tendency matches the mode.
  It's OK for symmetric distributions, but it may be misleading for skewed distributions.
  {{< imgld median2 >}}
* **Skewness**  
  The raw value of skewness may be useful for an experienced researcher,
    but it useless for most people.
  Meanwhile, the range with the mode value allows imagining the mode shape without special skills.
  {{< imgld skewness >}}
* **Quartiles**  
  The first and third quartiles are an essential part of the [five number summary](https://en.wikipedia.org/wiki/Five-number_summary).
  While it may be useful to see these values on the box plots,
    it's not so useful in a plain text report.
  In the five-number summary, we also have the minimum and the maximum value,
    but they can be spoiled by outliers,
    so Q1 and Q3 provide the value of the range that contains the middle 50% of elements in the given sample.
  In our case, we already removed the outliers; it's enough to present just the mode ranges
    (it plays the role of [highest density interval](https://en.wikipedia.org/wiki/Credible_interval)).
  The values of Q1 and Q3 will create visual noise, but they will not provide additional meaningful information
    that helps to imagine a distribution on the first exploration step.
  {{< imgld quartiles >}}
* **Dispersion**  
  The measures of dispersion like
    [standard deviation](https://en.wikipedia.org/wiki/Standard_deviation) or
    [median absolute deviation](https://en.wikipedia.org/wiki/Median_absolute_deviation)
    are very handy when we work with symmetric distributions.
  Unfortunately, they may be misleading in the case of asymmetric distributions.
  When we have a central tendency (e.g., mean, median, or mode) and a measure of dispersion,
    we tend to reconstruct a range using a simple formula like `<CentralTendency> ± k * <Dispersion>` where `k` is a random factor.
  In this thought reconstruction, we always get a symmetric interval around the central tendency.
  If we want to get an idea of asymmetry, we need two dispersion values: for the left and the right parts of the distribution.
  Unfortunately, it makes the thought reconstruction even more challenging because we have more numbers to process.
  Since we have the mode range, we already have an idea about the spread; we don't need an additional dispersion value.

### Reference implementation

You can find a reference C# implementation of this algorithm in
  the latest nightly version (0.3.0-nightly.59+) of [perfolizer](https://github.com/AndreyAkinshin/perfolizer)
  (see `LowlandModalityDetector`, `DoubleMadOutlierDetector`, `ManualModalityDataFormatter`).
Here is a code sample:

```cs
// Generate sample
var random = new Random(42);
var data = new List<double>();
data.AddRange(new[] {1.0, 2.0}); // Lower outliers
data.AddRange(new NormalDistribution(10, 1).Random(random).Next(100)); // Mode #1
data.AddRange(new[] {19.0}); // Intermodal outliers
data.AddRange(new NormalDistribution(30, 1).Random(random).Next(100)); // Mode #2
data.AddRange(new[] {37.0, 38.0, 39.0}); // Upper outliers

// Find modes and outliers
var modalityData = LowlandModalityDetector.Instance.DetectModes(data);
Console.WriteLine(AutomaticModalityDataFormatter.Instance.Format(modalityData));
```

This prints the following:

```cs
{1.00, 2.00} + [7.16; 13.12]_100 + {19.00} + [27.69; 32.34]_100 + {37.00..39.00}_3
```

### Conclusion

In this post, I showed a notation that provides a summary of a multimodal distribution shape.
It uses the following concepts:

* The primary focus is on the mode and outlier ranges.
* Optionally, we can show more details using the mode locations in the number of elements in each sample subset.
* If we get too many numbers, we notation can be shortified by omitting optional data or middle modes.

Of course, we can modify the set of signs (`{}[];..|+`),
  but I believe that the above concepts satisfy the original goal
  (present the essential parameters of a multimodal distribution in a short plain-text form).

Personally, I use this notation to process sets of performance measurements.
In performance analysis, multimodality may be a severe problem,
  so I would like to be aware of multimodal distributions in my data sets.
I prefer getting a plain text summary in two primary use cases:

* Getting an overview of a multimodal distribution in terminal
* Sending slack notifications about suspicious samples

Once I get the idea of the distribution shape, I can go deeper and check out the density and timeline plots.
In most cases, I don't do that because I already have the most important information from the summary.

At the first few tries, it may be hard to quickly interpret this notation.
However, when you get used to it,
  you will be able to instantly get the idea of the distribution shape using this short plain text description.

If you have any suggestions for improvements, feedback is welcome!