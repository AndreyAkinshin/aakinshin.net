---
title: "Publication announcement: 'Trimmed Harrell-Davis quantile estimator based on the highest density interval of the given width'"
date: 2022-03-22
tags:
- Statistics
features:
- math
---

Since the beginning of previous year, I have been working on building a quantile estimator
  that provides an optimal trade-off between statistical efficiency and robustness.
At the end of the year, I [published]({{< ref preprint-thdqe >}}) the corresponding preprint
  where I presented a description of such an estimator:
  [arXiv:2111.11776 [stat.ME]](https://arxiv.org/abs/2111.11776).
The paper source code is available on GitHub:
  [AndreyAkinshin/paper-thdqe](https://github.com/AndreyAkinshin/paper-thdqe).

Finally, the paper was published in *Communications in Statistics - Simulation and Computation*.
You can cite it as follows:

* Andrey Akinshin (2022)
  *Trimmed Harrell-Davis quantile estimator based on the highest density interval of the given width,*
  Communications in Statistics - Simulation and Computation,
  DOI: [10.1080/03610918.2022.2050396](https://www.tandfonline.com/doi/abs/10.1080/03610918.2022.2050396)

<!--more-->

Here is the corresponding BibTeX reference:

```bib
@article{akinshin2022thdqe,
  author = {Andrey Akinshin},
  title = {Trimmed Harrell-Davis quantile estimator based on the highest density interval of the given width},
  journal = {Communications in Statistics - Simulation and Computation},
  pages = {1-11},
  year = {2022},
  publisher = {Taylor & Francis},
  doi = {10.1080/03610918.2022.2050396},
  URL = {https://www.tandfonline.com/doi/abs/10.1080/03610918.2022.2050396},
  eprint = {https://www.tandfonline.com/doi/pdf/10.1080/03610918.2022.2050396},
  abstract = {Traditional quantile estimators that are based on one or two order statistics are a common way to estimate distribution quantiles based on the given samples. These estimators are robust, but their statistical efficiency is not always good enough. A more efficient alternative is the Harrell-Davis quantile estimator which uses a weighted sum of all order statistics. Whereas this approach provides more accurate estimations for the light-tailed distributions, it’s not robust. To be able to customize the tradeoff between statistical efficiency and robustness, we could consider a trimmed modification of the Harrell-Davis quantile estimator. In this approach, we discard order statistics with low weights according to the highest density interval of the beta distribution.}
}
```

### Relevant blog posts

Here is the full list of relevant blog posts:

{{< tag-list research-thdqe >}}
