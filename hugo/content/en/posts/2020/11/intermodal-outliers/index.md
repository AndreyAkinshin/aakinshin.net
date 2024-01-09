---
title: "Intermodal outliers"
description: "In this post, we cover outliers that appear between modes of multimodal distributions"
date: "2020-11-10"
tags:
- mathematics
- statistics
- research
- Multimodality
- QRDE
- Harrell-Davis quantile estimator
- Outliers
features:
- math
---

[Outlier](https://en.wikipedia.org/wiki/Outlier) analysis is a typical step in distribution exploration.
Usually, we work with the "lower outliers" (extremely low values) and the "upper outliers" (extremely high values).
However, outliers are not always extreme values.
In the general case, an outlier is a value that significantly differs from other values in the same sample.
In the case of multimodal distribution, we can also consider outliers in the middle of the distribution.
Let's call such outliers that we found between modes the "*intermodal outliers*."

{{< imgld step4 >}}

Look at the above density plot.
It's a bimodal distribution that is formed as a combination of two unimodal distributions.
Each of the unimodal distributions may have its own lower and upper outliers.
When we merge them, the upper outliers of the first distribution and the lower outliers of the second distribution
  stop being lower or upper outliers.
However, if these values don't belong to the modes, they still are a subject of interest.
In this post, I will show you how to detect such intermodal outliers
  and how they can be used to form a better distribution description.

<!--more-->

### Intermodal outlier detection

The intermodal outliers can be easily detected using multimodality detection and outlier detection algorithms.

1. **Mode detection**  
   First of all, we should detect the location of each mode.
   It can be done via the [lowland multimodality detector]({{< ref lowland-multimodality-detection >}}) which uses the [quantile-respectful density estimation based on the Harrell-Davis quantile estimator]({{< ref qrde-hd>}}) (QRDE-HD)
   {{< imgld step1 >}}
2. **Sample splitting**  
   Next, we should split the distribution into ranges where each range contains a single mode.
   Let's call them "mode ranges."
   With the lowland multimodality detector, we can use the lowest points of QRDE-HD in lowlands that separate modes.
   {{< imgld step2 >}}
3. **Outlier detection**  
   Now we have to find lower and upper outliers in each mode range.
   The distribution inside mode is most likely unimodal, but we can have sub-modes in some complicated cases.
   Also, they can be skewed and heavy-tailed.
   To find outliers in such tricky asymmetric distributions, we need a non-parametric and robust outlier detector.
   I suggest using the [DoubleMAD outlier detector based on the Harrell-Davis quantile estimator]({{< ref harrell-davis-double-mad-outlier-detector>}}), but it can be easily replaced by your favorite algorithm.
   {{< imgld step3 >}}
4. **Result gathering**  
   The lower outliers of the first mode become the lower outliers of the whole distribution.
   The upper outliers of the last mode become the upper outliers of the whole distribution.
   To find the whole set of intermodal outliers between two modes,
     we should combine the upper outliers of the first mode with the lower outliers of the second mode.
   {{< imgld step4 >}}

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
data.AddRange(new[] {19.0, 21.0}); // Intermodal outliers
data.AddRange(new NormalDistribution(30, 1).Random(random).Next(100)); // Mode #2
data.AddRange(new[] {38.0, 39.0}); // Upper outliers

// Find modes and outliers
var modalityData = LowlandModalityDetector.Instance.DetectModes(data);
Console.WriteLine(AutomaticModalityDataFormatter.Instance.Format(modalityData));
```

This prints the following:

```cs
{1.00, 2.00} + [7.16; 13.12]_100 + {19.00, 21.00} + [27.69; 32.34]_100 + {38.00, 39.00}
```

The code presents the sample as a combination of five groups:

* *Lower outliers*: `{1.00, 2.00}` (two elements)
* *Mode #1*: `[7.16; 13.12]_100` (100 elements between 7.16 and 13.12)
* *Intermodal outliers*: `{19.00, 21.00}` (two elements)
* *Mode #2*: `[27.69; 32.34]_100` (100 elements between 27.69 and 32.34)
* *Upper outliers*: `{38.00, 39.00}` (two elements)

I will explain this notation in detail in future posts.

### Conclusion

In this post, we discussed the concept of intermodal outliers.
Unlike "classic" lower and upper outliers, these values are located in the middle of a distribution.
However, they still can be considered outliers if they significantly differ from most of the other values.

Such outliers may appear in multimodal distributions as lower or upper outliers of unimodal sub-distributions.
To find these values, we can detect mode range using the [lowland multimodality detector]({{< ref lowland-multimodality-detection >}}),
  and discover outliers in each mode independently.
To find the whole set of intermodal outliers between two modes,
  we should combine the upper outliers of the first mode with the lower outliers of the second mode.

The knowledge of intermodal outlier locations helps to clean up the sample values.
It significantly reduces the risk of getting distorted statistical metric values.