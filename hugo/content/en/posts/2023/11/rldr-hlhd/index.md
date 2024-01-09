---
title: "Resistance to the low-density regions: the Hodges-Lehmann location estimator based on the Harrell-Davis quantile estimator"
date: 2023-11-21
tags:
- mathematics
- statistics
- research
- research-rldr
- hodges-lehmann
features:
- math
---

Previously, I have discussed the topic of the [resistance to the low-density regions]({{< ref research-rldr >}})
  of various estimators including [the Hodges-Lehmann location estimator]({{< ref rldr-hl >}}) ($\operatorname{HL}$).
In general, $\operatorname{HL}$ is a great estimator with great statistical efficiency and a decent breakdown point.
Unfortunately, it has low resistance to the low-density regions around
  $29^\textrm{th}$ and $71^\textrm{th}$ percentiles, which may cause troubles in the case of multimodal distributions.
I am trying to find a modification of $\operatorname{HL}$
  that performs almost the same as the original $\operatorname{HL}$, but has increased resistance.
One of the ideas I had was using the Harrell-Davis quantile estimator
  instead of the sample median to evaluate $\operatorname{HL}$.
Regrettably, this idea did not turn out to be successful:
  such an estimator has a resistance function similar to the original $\operatorname{HL}$.
I believe that it is important to share negative results, and therefore this post contains a bunch of plots,
  which illustrate results of relevant numerical simulations.

<!--more-->

In this post, I extend research from the [original post about $\operatorname{HL}$ resistance]({{< ref rldr-hl >}})
  by adding a new estimator that we denote as $\operatorname{HLHD}$.
The simulation setup is fully reused from the previous post.
Here are the updated results:

{{< imgld resistance_hlhd49 >}}
{{< imgld resistance_hlhd50 >}}
{{< imgld resistance_hlhd99 >}}
{{< imgld resistance_hlhd100 >}}
{{< imgld resistance_all49 >}}
{{< imgld resistance_all50 >}}
{{< imgld resistance_all99 >}}
{{< imgld resistance_all100 >}}
