---
title: Quantile-Respectful Density Estimation and Trimming
date: 2024-03-26
tags:
- Mathematics
- Statistics
- Research
- qrde
- Multimodality Detection
features:
- math
---

I continue the topic of {{< link qrde >}} in the context of {{< link multimodality-detection >}}.
In this post, we briefly discuss the handling of the QRDE boundary spikes
  in order to correctly detect the near-border modes.

<!--more-->

QRDE-HD has an issue in the form of boundary spikes,
  which may distort the multimodality detection procedure.
Let us review two examples:
  the first one describes the problem, and the second one suggests a solution.

{{< example >}}

Let us review the lowland view for a sample of 20 elements from the standard normal distribution
  presented in the below figure:

{{< imgld boundary1 >}}

As we can see, the right boundary spike was "recognized" as a mode,
  which leads to an incorrect insight into the number of modes.

One may suggest just ignoring the boundary spikes.
However, the boundary spikes may represent the actual modes.
In the next figure, we can see a bimodal distribution with a right boundary spike.

{{< imgld boundary2 >}}

In this case, two modes are detected correctly.
If we always silently ignore the boundary spikes, it would distort the multimodality analysis for this case.

{{< /example >}}

{{< example >}}

Instead of ignoring the boundary spikes, we suggest the trimming procedure.
The "false" boundary spikes arise only in close proximity to the boundary elements
  due to the nature of the Harrell-Davis quantile estimator.
If we exclude the minimum and the maximum sample element from the histogram range
  (while QRDE-HD is still built based on the full sample),
  the "false" boundary spikes will be suppressed.
In the below figure,
  we can see that such a trimming procedure eliminates the false mode at the right boundary of the plot:

{{< imgld trimming1 >}}

In the next figure,
  we can see that the trimming procedure does not affect the correct detection of the two modes in the bimodal case:

{{< imgld trimming2 >}}

We believe that trimming a single element from each side is enough for the majority of cases.
However, the number of trimmed elements may be increased if needed.

{{< /example >}}
