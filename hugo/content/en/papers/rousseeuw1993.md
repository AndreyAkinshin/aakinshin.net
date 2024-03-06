---
title: Alternatives to the Median Absolute Deviation
year: 1993
doi: 10.1080/01621459.1993.10476408
urls:
- "https://www.tandfonline.com/doi/abs/10.1080/01621459.1993.10476408"
authors:
- Peter J Rousseeuw
- Christophe Croux
tags:
- Mathematics
- Statistics
- Shamos Estimator
hasNotes: false
---

## Reference

> <i>Peter J Rousseeuw, Christophe Croux</i> “Alternatives to the Median Absolute Deviation” (1993) // Journal of the American Statistical Association. Vol.&nbsp;88. No&nbsp;424. Pp.&nbsp;1273–1283. DOI:&nbsp;<a href='https://doi.org/10.1080/01621459.1993.10476408'>10.1080/01621459.1993.10476408</a>

## Abstract

> In robust estimation one frequently needs an initial or auxiliary estimate of scale. For this one usually takes the median absolute deviation MAD n = 1.4826 med, \textbarxi − med j x j \textbar, because it has a simple explicit formula, needs little computation time, and is very robust as witnessed by its bounded influence function and its 50\% breakdown point. But there is still room for improvement in two areas: the fact that MAD n is aimed at symmetric distributions and its low (37\%) Gaussian efficiency. In this article we set out to construct explicit and 50\% breakdown scale estimators that are more efficient. We consider the estimator Sn = 1.1926 med, med j \textbar xi − xj \textbar and the estimator Qn given by the .25 quantile of the distances \textbarxi − x j \textbar; i \textless j. Note that Sn and Qn do not need any location estimate. Both Sn and Qn can be computed using O(n log n) time and O(n) storage. The Gaussian efficiency of Sn is 58\%, whereas Qn attains 82\%. We study Sn and Qn by means of their influence functions, their bias curves (for implosion as well as explosion), and their finite-sample performance. Their behavior is also compared at non-Gaussian models, including the negative exponential model where Sn has a lower gross-error sensitivity than the MAD.

## Bib

```bib
@Article{rousseeuw1993,
  title = {Alternatives to the Median Absolute Deviation},
  volume = {88},
  issn = {0162-1459},
  url = {https://www.tandfonline.com/doi/abs/10.1080/01621459.1993.10476408},
  doi = {10.1080/01621459.1993.10476408},
  abstract = {In robust estimation one frequently needs an initial or auxiliary estimate of scale. For this one usually takes the median absolute deviation MAD n = 1.4826 med, \textbarxi − med j x j \textbar, because it has a simple explicit formula, needs little computation time, and is very robust as witnessed by its bounded influence function and its 50\% breakdown point. But there is still room for improvement in two areas: the fact that MAD n is aimed at symmetric distributions and its low (37\%) Gaussian efficiency. In this article we set out to construct explicit and 50\% breakdown scale estimators that are more efficient. We consider the estimator Sn = 1.1926 med, med j \textbar xi − xj \textbar and the estimator Qn given by the .25 quantile of the distances \textbarxi − x j \textbar; i \textless j. Note that Sn and Qn do not need any location estimate. Both Sn and Qn can be computed using O(n log n) time and O(n) storage. The Gaussian efficiency of Sn is 58\%, whereas Qn attains 82\%. We study Sn and Qn by means of their influence functions, their bias curves (for implosion as well as explosion), and their finite-sample performance. Their behavior is also compared at non-Gaussian models, including the negative exponential model where Sn has a lower gross-error sensitivity than the MAD.},
  number = {424},
  urldate = {2020-07-14},
  journal = {Journal of the American Statistical Association},
  author = {Rousseeuw, Peter J and Croux, Christophe},
  month = {dec},
  year = {1993},
  note = {Publisher: Taylor \& Francis},
  keywords = {Bias curve, Breakdown point, Influence function, Robustness, Scale estimation},
  pages = {1273--1283}
}
```
