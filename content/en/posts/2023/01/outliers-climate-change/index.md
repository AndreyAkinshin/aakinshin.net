---
title: Thoughts about outlier removal and climate change
date: 2023-01-31
tags:
- mathematics
- statistics
- research
features:
- math
---

When it comes to outlier removal,
  people typically start discussing various techniques that remove outliers from the given sample.
However, such a discussion should be started with the question, "why do we want to remove outliers?"
Outliers may provide essential information about the underlying distribution,
  so we do not always want to discard them.
If we blindly remove all the outliers, we may miss important insights.
Before we start choosing the best outlier detector, we should understand the nature of the outlier existing.
We should define what kind of values we recognize as outliers
  and what kind of useful information they can provide.
If we have non-robust estimators that can be affected by these outliers,
  we may also consider replacing them with robust estimators that do not have such a problem.
Meanwhile, additional analysis of extreme values can provide
  useful insights for anomaly detection and tail approximation.

To illustrate the danger of blind outlier removal, I would like to share a fragment from the book
  "Our Changing Climate" (1991) by R. Kandel:

<!--more-->

> The discovery of the ozone hole **was announced in 1985** by a British team working on the ground
>   with “conventional” instruments and examining its observations in detail.
> Only later, after reexamining the data transmitted by the TOMS instrument on NASA’s Nimbus 7 satellite,
>   was it found that **the hole had been forming for several years**.
> Why had nobody noticed it? The reason was simple:
>   the systems processing the TOMS data, designed in accordance with predictions derived from models,
>   which in turn were established on the basis of what was thought to be “reasonable”,
>   **had rejected the very (“excessively”) low values** observed above the Antarctic during the Southern spring.
> As far as the program was concerned, there must have been an operating defect in the instrument.
> 
> --- R. Kandel, Our Changing Climate (1991)

Thus, the research team had enough data to detect the ozone holes,
  but these values were ignored because they were recognized as outliers that should be removed.
