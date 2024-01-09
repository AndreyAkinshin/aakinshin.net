---
title: "Nonparametric effect size: Cohen's d vs. Glass's delta"
date: 2023-01-24
tags:
- mathematics
- statistics
- research
- research-gamma-es
features:
- math
---

In the [previous posts]({{< ref research-gamma-es >}}),
  I discussed the idea of nonparametric effect size measures
  consistent with Cohen's d under normality.
However, Cohen's d is not always the best effect size measure, even in the normal case.

In this post, we briefly discuss a case study in which a nonparametric version of Glass's delta is preferable
  than the [previously suggested]({{< ref nonparametric-effect-size >}}) Cohen's d-consistent measure.

<!--more-->

### Nonparametric versions of Cohen's d and Glass's delta

In the scope of this post, we use the following nonparametric modifications of Cohen's d and Glass's delta:

$$
d(x, y) = \frac{\operatorname{median}(y) - \operatorname{median}(x)}{\operatorname{PMAD}(x, y)},
$$

$$
\Delta(x, y) = \frac{\operatorname{median}(y) - \operatorname{median}(x)}{\operatorname{MAD}(x)},
$$

where $\operatorname{MAD}$ is the median absolute deviation:

$$
\operatorname{MAD}(x) = \operatorname{median}(x - |\operatorname{median}(x)|),
$$

$\operatorname{PMAD}(x, y)$ is the pooled version of $\operatorname{MAD}$:

$$
\operatorname{PMAD}(x, y) = \sqrt{\frac{(n_x - 1) \operatorname{MAD}^2_x + (n_y - 1) \operatorname{MAD}^2_y}{n_x + n_y - 2}},
$$

$\operatorname{median}$ is the traditional sample median,

### Case study

Let us consider the following three samples (inspired by a real set of data samples):

$$
\begin{split}
x = \{
  & 298, 297, 314, 312, 299, 301, 295, 295, 293, 293, 293, 293, 293, 292, 295,\\
  & 293, 295, 293, 292, 295, 293, 293, 293, 299, 295, 304, 301, 296, 327, 294,\\
  & 294, 293, 293, 293, 293, 293, 293, 292, 293, 292, 293, 294, 292, 294, 294,\\
  & 294, 293, 293, 293, 293, 292, 294, 293, 296, 294, 299, 292, 293, 293, 294,\\
  & 292, 293, 293, 292, 294, 292, 292, 293, 293, 292, 292, 292, 294, 293, 293\},
\end{split}
$$

$$
\begin{split}
y_A = & \{ 2641, 30293, 27648 \},\\
y_B = & \{ 2641, 175631, 532991 \}.
\end{split}
$$

We may expect that
  the effect size between $x$ and $y_B$ should be larger than
  the effect size between $x$ and $y_A$.
However, it is not true for the previously defined $d(x, y)$ measure:

$$
d(x, y_A) \approx 63.8, \quad d(x, y_B) \approx 6.2.
$$

Surprisingly, $d(x, y_B)$ is actually ten times smaller than $d(x, y_A)$.
Moreover, $d(x, y_B) \approx 6.2$ does not always mean
  a truly significant change between medians in the nonparametric case.
Such a situation arises because of the enormous median absolute deviation of $y_B$:
  $\operatorname{MAD}(y_B) = 172990$.
Regardless of the small size of $y_B$, the pooled median absolute deviation is heavily affected:
  $\operatorname{PMAD}(x, y_B) \approx 28062.68$.
Since it is used as the denominator in $d(x, y)$ equation, a huge value of $\operatorname{PMAD}$
  leads to a small value of estimated effect size.

The described problem can often be observed
  when the second sample contains a small number of elements from a heavy-tailed distribution.
In such cases, it is better to use the previously defined Glass's delta-consistent approach.
Here are the corresponding results:

$$
\Delta(x, y_A) \approx 27355, \quad \Delta(x, y_B) \approx 175338.
$$

As we can see, $\Delta(x, y_A) < \Delta(x, y_B)$, which matches our expectation.
Moreover, $\Delta(x, y_B) \approx 175338$, which is much more impressive than $d(x, y_B) \approx 6.2$:
  the estimated change is truly significant.