---
title: "Lowland multimodality detection"
date: "2020-11-03"
tags:
- Statistics
- Multimodality
- QRDE
- Harrell-Davis
features:
- math
---

{{< imgld data5 >}}

Multimodality is an essential feature of a distribution, which may create many troubles during automatic analysis.
One of the best ways to work with such distributions is to detect all the modes in advance based on the given samples.
Unfortunately, this problem is much harder than it looks like.

I tried many different approaches for multimodality detection, but none of them was good enough.
During the past several years, my approach of choice was the [mvalue-based modal test](http://www.brendangregg.com/FrequencyTrails/modes.html) by Brendan Gregg.
It works nicely in simple cases, but I was constantly stumbling over noisy samples where this algorithm doesn't produce reliable results.
Also, it has some limitations that make it unapplicable to some corner cases.

So, I needed a better approach.
Here are my main requirements:
* It should detect the exact mode locations and ranges
* It should provide reliable results even on noisy samples
* It should be able to detect multimodality even when some modes are extremely close to each other
* It should work out of the box without tricky parameter tuning for each specific distribution

I failed to find such an algorithm anywhere, so I came up with my own!
The current working title is "the lowland multimodality detector."
It takes an estimation of the probability density function (PDF) and tries to find "lowlands" (areas that are much lower than neighboring peaks).
Next, it splits the plot by these lowlands and detects modes between them.
For the PDF estimation, it uses the [quantile-respectful density estimation based on the Harrell-Davis quantile estimator]({{< ref qrde-hd>}}) (QRDE-HD).
Let me explain how it works in detail.

<!--more-->

### The problem

{{< imgld riddle >}}

How many modes do you see in the above image?
It's a trick question because it depends on the "mode" definition and on the kind of plot we have.
Here are some possible options:

* *The plot is an exact probability density function; the mode is the global [maxima](https://en.wikipedia.org/wiki/Maxima_and_minima).*  
  In this case, we have only a single mode (0.02).
* *The plot is an exact probability density function; the mode is a local maxima.*  
  In this case, we have seven modes (-2.38, -1.11, 0.02, 0.41, 0.91, 1.61, 1.99).
* *The plot is an estimated probability density function based on a sample; the mode is a local maxima on the underlying distribution.*  
  In this case, it's impossible to answer the question based on the given plot.
  Meanwhile, the correct answer is "one": the samples were collected from the normal distribution $\mathcal{N}(0, 1^2)$ (the picture presents a kernel density estimation with bandwidth = 0.1 based on the normal kernel).

In this post, we will work with the most practical case.
Let's say that we have a sample, and we want to provide an estimation of the modes in the underlying distribution.
There is an important nuance here.
If we define the mode as the local maxima, we can easily get bunches of noisy modes that are close to each other,
  but have no clear separation.
Typically, the true density of real-life distributions is very noisy and wobbly.

However, we are not interested in most of "close to each other noisy modes" in practice.
When we work with such distributions, we tend to make the density smoother.
We tend to reduce the impact of noise patterns, even if such patterns are integral parts of the original distribution.
We tend to group each bunch of nearby local maxima to a single mode.

During basic distribution exploration,
  we are interested only in "major" modes that make sense to us from the practical point of view.
Here I have some good news and some bad news.
The bad news: we don't have a strict mathematical definition, so we can't verify and compare different approaches.
The good news: we are free to choose our own definition, which will be optimal for our use cases.

During my research, I often ask my colleagues: "How many modes do you see in this plot?"
Typically, I get identical answers for the same plot, which makes me think that there is a common understanding of this concept.
In this post, we focus on such "practically significant" modes which often look obvious for most people.

### The mvalue approach

To get a better understanding of the problem, we start with the analysis of the mvalue approach.
It's described by Brendan Gregg in [[Gregg2015]](#Gregg2015).
It worth reading the original post, but I briefly describe the main idea.
Basically, the mvalue is the [total variation](https://en.wikipedia.org/wiki/Total_variation) of a histogram or a density plot normalized by the plot height.
The modal test compares the mvalue with a predefined threshold and makes a decision about multimodality.
The easiest way to understand the idea is to just look at some examples.

Here is a visualization of a perfect unimodal distribution:

{{< imgld mvalue1 >}}

Here we have three local extrema: the left corner point, the central peak, and the right corner point.
For each extremum, we should calculate the density value normalized by the global maxima.
For the left and right corner points, this value equals zero.
For the central peak, it equals one (because it's the highest peak).
The total variation is the sum of absolute differences between consecutive values.
In this case, it equals
  (1.0 for ascent from the left corner point to the central peak) +
  (1.0 for descent from the central peak to the right corner point).
Thus, the mvalue equals 2.
It's the minimum possible value of mvalue.

Here is a visualization of a perfect bimodal distribution:

{{< imgld mvalue2 >}}

The mvalue equals 4 (1 for ascent + 1 for descent + 1 for ascent + 1 for descent).
It's the default value of the etalon bimodal distribution.

Here is a visualization of a perfect trimodal distribution:

{{< imgld mvalue3 >}}

The mvalue equals 6 (1 for ascent + 1 for descent + 1 for ascent + 1 for descent + 1 for ascent + 1 for descent).
It's the default value of the etalon trimodal distribution.

You may think that we can get the number of modes by dividing mvalue by 2.
Unfortunately, it's not so simple.
Could you guess the mvalue of the below plot?

{{< imgld mvalue4a >}}

It equals 4:

{{< imgld mvalue4b >}}

It's hard to make an unequivocal conclusion about modality here, but it's definitely not a bimodal distribution.

And what could you say about the next plot?

{{< imgld mvalue5a >}}

It equals 6:

{{< imgld mvalue5b >}}

This distribution is most probably unimodal.
But because of the noise, the mvalue-based modal test thinks that it's a trimodal distribution.
Although mvalues allows detecting multimodal distributions in simple cases,
  they have some serious disadvantages:

* **High false-positive rate**  
  Many noisy distributions may be considered as multimodal.
* **No clear mode separation**  
  We get only a single number that expresses the measure of multimodality.
  But we don't have the exact number of modes and their locations and ranges.
* **Tricky tuning**  
  This approach provides too many degrees of freedom:
  * We should choose the basis for mvalues: a histogram or a density plot.
  * If we use a histogram, we should choose the bandwidth and offset values
      (which is [not easy]({{< ref misleading-histograms >}})).
    If we use a kernel density estimation, we should choose the kernel bandwidth
      (which is also [not easy]({{< ref kde-bw >}}))
  * We should manually remove outliers, so we have to choose an appropriate outlier detection algorithm.
  * We should specify adequate thresholds.
    Brendan Gregg recommends using 2.4 as a signal that it worth manually investigate the distribution.
    In [perfolizer](https://github.com/AndreyAkinshin/perfolizer), I currently use 2.8 as a lower threshold for multimodal distribution to reduce the false-positive rate.
    It's hard to say which value is the best one in the general case.

Despite all these problems, this approach works and can be used in practice.
I have been using it in [BenchmarkDotNet](https://github.com/dotnet/BenchmarkDotNet) for the past two years (it's available since v0.10.14), but there are still cases when it doesn't help to automatically make a reliable conclusion about multimodality.
So, I decided to find another approach that will work better.

### Introducing lowlands

Firstly, we will use the [QRDE-HD]({{< ref qrde-hd >}}) instead of histograms and kernel density estimations.
The approach provides a much better estimation of the shape of the *collected data*, and it doesn't require parameter tuning.
Now imagine that this function describes a mountain relief (side view):

{{< imgld data1 >}}

Next, it's starting to rain[^1].
The rain fills the mountain hollows with water and forms a bunch of ponds.
The area of the mountain strictly below the ponds saturated with water.
Now let's introduce the following definitions:

* **Groundwater**: the area below a pond saturated with water
* **Shallow Water**: a pond with an area *smaller* than the area of the corresponding underwater
* **Deep Water**: a pond with an area *larger* than the area of the corresponding underwater
* **Lowland**: a part of the mountain that is covered by a deep water  
  (we also assume that there are hidden lowlands on the right and on the left side of the visible mountain)
* **Peak**: a local maxima of the mountain relief (a point that is higher than its neighbors)
* **Mode**: the highest peak between two deep water ponds (including hidden ponds)

For better understanding, let's see how this classification works in the bimodal case:

{{< imgld data2 >}}

We can do the following observations:

* Here we have five ponds.
* Only the second pond consists of deep water (because its area is larger than the area of the corresponding underwater). It's the only lowland that we see here.
* Also, we have six peaks: two on the left side of the central lowland and four on the right side.
* The second peak is the first mode because it's the highest peak between the central lowland and the left hidden lowland.
* The third peak is the second mode because it's the highest peak between the central lowland and the right hidden lowland.
* It's a bimodal distribution because we discovered exactly two modes.

I hope that you got the idea.
Now it's time to formalize this schema.

### Lowland detection algorithm

To find the number of modes and their locations for the given samples, we should do the following:

1. Build the [QRDE-HD]({{< ref qrde-hd >}})
2. Find all local maxima of the QRDE-HD except border points (peaks)
3. Enumerate all the segments between neighboring peaks in ascending order of size
4. For each segment, we try to fill it with "water."
   The water level is determined by the lowest peak.
   If the water area is larger than the area under the water, we mark it as "lowland."
   Once we found a lowland, we don't touch it anymore: it can't be flooded by a larger pond.
   If the water area is smaller than the area under the water, this pond can be merged with other ponds.
5. Once we found all the lowland areas, we split the whole plot by them to not-lowland areas.
6. In each not-lowland area, we choose the highest peek and mark them as a mode.

{{< imgld data3 >}}

### Extreme case

Now consider a case of a bimodal distribution where two modes are very close to each other but still strictly separated.
Let's take two huge samples from the uniform distribution $\{x_{1..1000}\}, \{y_{1..1000}\} \in \mathcal{U}(0, 1)$ and build a bimodal sample of the following form: $\{ -\delta - x^3_{1..1000}, +\delta +y^3_{1..1000} \}$.
It contains two modes ($-\delta$ and $+\delta$), and it doesn't include any sample elements between them.
The distance between modes equals $2\delta$.

Let's check out how the lowland detector works in such a case.
We start with $\delta = 0.5$:

{{< imgld data-close-05 >}}

It wasn't so hard to detect two modes here.
Let's try $\delta = 0.1$:

{{< imgld data-close-01 >}}

Not bad.
Now let's try an extreme case: $\delta = 0.01$.

{{< imgld data-close-001 >}}

We are still able to detect bimodality here!
Note that it's only possible thanks to the [QRDE-HD]({{< ref qrde-hd >}}).
If we use classic histograms or kernel density estimations here, we will not be able to see multimodality:

{{< imgld data-close-001-comparison >}}

### More examples

Below you can find some additional cases of applying this algorithm to multimodal distributions.

{{< imgld data4 >}}

{{< imgld data6 >}}

{{< imgld data7 >}}

{{< imgld data8 >}}

{{< imgld data9 >}}

{{< imgld data10 >}}

### Implementation notes

You can find a reference C# implementation of this algorithm in
  the latest nightly version (0.3.0-nightly.54+) of [perfolizer](https://github.com/AndreyAkinshin/perfolizer)
  (you need [`LowlandModalityDetector`](https://github.com/AndreyAkinshin/perfolizer/blob/dc9d9a3997c0b395575cff06ec8af2a98b3b2bb7/src/Perfolizer/Perfolizer/Mathematics/Multimodality/LowlandModalityDetector.cs)).
As I said in the beginning, it doesn't require any parameter tuning.
It should just work without any adjustments.
However, there are a few points of customization that you can use to adopt this algorithm to some very specific corner cases.

* **Sensitivity**  
  By default, we mark a pond as deep water when its area is larger than the area of the groundwater beneath it.
  We can express this via the following equations: `Area(DeepWater) > 0.5 * (Area(DeepWater)+Area(Groundwater))`.
  Let's call `0.5` in this equation *sensitivity*.
  It defines how large the water area should be to be considered as deep water.
  By manipulating this parameter, you can tune how sensitive the algorithm is.
  However, based on my experience, `0.5` looks like an optimal value.
* **Precision**  
  It's typically enough to calculate 101 quantile values (99 percentiles + minimum + maximum) to build the QRDE-HD as a step function.
  However, if you expect an extremely large number of modes
    (e.g., 200 modes and extremely large data sets that clearly highlights all of these modes),
    you can increase the number of evaluated quantiles.
  Note that it may significantly reduce the algorithm performance.
* **PDF**  
  I suggest using the QRDE-HD to estimate the PDF.
  However, other kinds of estimations may be considered.
  I do not recommend using classic histograms and kernel density estimations because of the smoothness problems.
  However, it may make sense to experiment with other kinds of the PDF estimators (e.g., QRDE based on other smooth quantile estimators).
  In general, the algorithm supports any kind of density plots or histograms.

### Conclusion

The suggested algorithm allows detecting multimodality phenomena based on the given sample.
You can try to use it via [perfolizer](https://github.com/AndreyAkinshin/perfolizer) or implement it yourself.
Here are some of the main advantages of this approach:

* **Detailing**  
  It not only detects the exact number of modes but also provides their exact locations.
* **Just works without tuning**  
  It works out of the box, and it doesn't require parameter tuning
* **Close peak support**  
  It allows detecting modes even when they are extremely close to each other
* **Robustness and reliability**  
  It's pretty robust, and it works reliably even on noisy samples (at least, on my data sets ☺)
* **Natural results**  
  The set of detected modes matches thoughts of real people when they manually explore distribution plots

If you decide to try this algorithm on your data sets, I will be happy to get your feedback!

### References

* <b id="Gregg2015">[Gregg2015]</b>  
  B. Gregg, 2015.
  Frequency Trails: Modes and Modality.  
  http://www.brendangregg.com/FrequencyTrails/modes.html
* <b id="Harrell1982">[Harrell1982]</b>  
  Harrell, F.E. and Davis, C.E., 1982. A new distribution-free quantile estimator.
  *Biometrika*, 69(3), pp.635-640.  
  https://pdfs.semanticscholar.org/1a48/9bb74293753023c5bb6bff8e41e8fe68060f.pdf

[^1]: Inspired by the problem "Rain" from XIV All-Russian Olympiad for schoolchildren in computer science a.k.a. ROI-2002 (Day 1, Problem 2).
The problem description can be found [here](https://neerc.ifmo.ru/school/archive/2001-2002.html) (In Russian). The problem solution can be found [here](http://svgimnazia1.grodno.by/sinica/Book_ABC/Book_ABC_pascal/olimp_resh/olimp_resh55.htm) (In Russian).
