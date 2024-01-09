---
title: Adaptation of continuous scale measures to discrete distributions
date: 2023-04-04
tags:
- mathematics
- statistics
- research
features:
- math
---


In statistics, it is often important to have a reliable measure of scale
  since it is required for estimating many types of the effect size and for statistical tests.
If we work with continuous distributions,
  there are plenty of available scale measures with various levels of statistical efficiency and robustness.
However, when distribution becomes discrete (e.g. because of the limited resolution of the measure tools),
  classic measures of scale can collapse to zero due to tied values in collected samples.
This can be a severe problem in the analysis
  since the scale measures are often used as denominators in various equations.
To make the calculations more reliable,
  it is important to handle such situations somehow and ensure that the target scale measure never becomes zero.
In this post,
  I discuss a simple approach to work around this problem and adapt any given measure of scale to the discrete case.

<!--more-->

### The problem

First, let us consider an example that illustrates the problem.
For two given samples, we want to estimate the [effect size]({{< ref nonparametric-effect-size2>}}) that is expressed as
  a difference between measures of central tendency divided by the pooled measure of scale.
The classic example of the effect size from this family is Cohen's d:

$$
d = \frac{\overline{\mathbf{y}}-\overline{\mathbf{x}}}{s},
$$

where
  $\mathbf{x} = \{ x_1, x_2, \ldots, x_{n_x} \}$ and $\mathbf{y} = \{ y_1, y_2, \ldots, y_{n_y} \}$
    are the given samples,
  $\overline{\mathbf{x}}$ and $\overline{\mathbf{y}}$ are the sample means,
  $s$ is the [pooled standard deviation](https://en.wikipedia.org/wiki/Pooled_standard_deviation):

$$
s = \sqrt{\frac{(n_x - 1) s^2_x + (n_y - 1) s^2_y}{n_x + n_y - 2}},
$$

where $s_x$ and $s_y$ are standard deviations of $\mathbf{x}$ and $\mathbf{y}$.

When we calculate Cohen's d for two samples from normal distributions,
  everything works smoothly.
Here are two samples from $\mathcal{N}(0, 1)$ and $\mathcal{N}(1, 1)$:

```r
Case A
x ≈ {0.474, -0.555, -0.01, 1.067, -0.712, -0.321, -1.238, -1.085, 0.869, 2.316}
y ≈ {1.315, -0.271, 1.563, 0.54, 1.81, 1.905, -0.209, 1.001, 0.543, 2.149}
```

For this case, the pooled standard deviation is $s \approx 0.993$, and Cohen's d is $d \approx 0.961$.
We are lucky enough because we got quite an accurate estimate of the true difference between distributions.

Now let us consider another example:

```r
Case B
x = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
y = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
```

In this case, the standard deviation is zero for both samples.
Therefore, the pooled standard deviation is also zero, the Cohen's d cannot be evaluated.
A convenient measure of effect size for such a discrete degenerated case is
  the absolute difference between measures of central tendency expressed in raw measurement units.

When the properties of the distribution are known in advance,
  we can choose the proper effect size measure during the design stage of the research.
But what if we don't know these properties, and we want to apply a universal approach to any given data?

### A possible solution

To tackle this issue, we can adapt the continuous scale measures to discrete data
  using a simple method that guarantees non-zero values.
The main idea is to add a small constant $\delta$ to the calculated scale measure,
  which prevents it from collapsing to zero.
This constant should be chosen based on the resolution of the measurement scale
  to avoid distorting the results significantly.
The straightforward approach to define the adapted measure of scale $s'$ may look like this:

$$
s' = s + \delta,
$$

where
  $s$ is the original scale measure,
  $\delta$ is the measurement resolution.
This ensures that $s'$ is always positive and never collapses to zero,
  allowing the calculation of effect size measures like Cohen's d.
However, in order to reduce the impact of $\delta$ on the final scale estimation, we can use the following approach:

$$
s' = \sqrt{s^2 + \delta^2}.
$$

The difference between $1/s$, $1/(s+\delta)$, and $1/\sqrt{s^2+\delta^2}$
  for $\delta=1$ is shown in the following figure:

{{< imgld s >}}

It seems that $s' = \sqrt{s^2 + \delta^2}$ is the winner:
  it gives a neglectable impact on the final estimation for large values of $s$,
  and it provides a smoother transition towards $\delta$ around $s \approx 0$ than $s'=1+\delta$.

For example, in Case A, switching from $s$ to $s'$ using $\delta = 0.001$
  will not produce any noticeable impact on the estimation:
  $d$ switches from $\approx 0.960999141$ to $\approx 0.960998654$.

In Case B, switching from $s$ to $s'$ using $\delta = 1$ will give us $s'=1$,
  which ensures a meaningful value of the effective size for this discrete case.

### Conclusion

Adapting continuous scale measures to discrete data is a simple yet effective approach to handling situations
  where classical measures may collapse to zero.
By adding a small constant based on the resolution of the measurement scale,
  we can ensure that the scale measure never becomes zero,
  allowing us to compute effect size measures for a wide range of data types.

This method can be applied to any given measure of scale,
  not just the pooled standard deviation,
  making it a versatile tool for researchers and practitioners working with discrete data.
However, it is essential to choose the constant value carefully,
  considering the context and the resolution of the measurement scale
  to avoid introducing significant distortions to the results.
