---
title: "Preprint announcement: 'Finite-sample bias-correction factors for the median absolute deviation based on the Harrell-Davis quantile estimator and its trimmed modification'"
date: 2022-07-26
tags:
- Statistics
- research-unbiased-mad
- paper-announcement
features:
- math
---

I have just published a preprint of a paper
  'Finite-sample bias-correction factors for the median absolute deviation based on the Harrell-Davis quantile estimator and its trimmed modification'.
It's based on a series of my [research notes]({{< ref research-unbiased-mad >}})
  that I have been writing since February 2021.

The paper preprint is available on arXiv:
  [arXiv:2207.12005 [stat.ME]](https://arxiv.org/abs/2207.12005).
The paper source code is available on GitHub:
  [AndreyAkinshin/paper-mad-factors](https://github.com/AndreyAkinshin/paper-mad-factors).
You can cite it as follows:

* Andrey Akinshin (2022)
  "Finite-sample bias-correction factors for the median absolute deviation based on the Harrell-Davis quantile estimator and its trimmed modification,"
  [arXiv:2207.12005](https://arxiv.org/abs/2207.12005)

Abstract:

> The median absolute deviation is a widely used robust measure of statistical dispersion.
> Using a scale constant, we can use it as an asymptotically consistent estimator for the standard deviation under normality.
> For finite samples, the scale constant should be corrected in order to obtain an unbiased estimator.
> The bias-correction factor depends on the sample size and the median estimator.
> When we use the traditional sample median, the factor values are well known,
>   but this approach does not provide optimal statistical efficiency.
> In this paper, we present the bias-correction factors for the median absolute deviation
>   based on the Harrell-Davis quantile estimator and its trimmed modification
>   which allow us to achieve better statistical efficiency of the standard deviation estimations.
> The obtained estimators are especially useful for samples with a small number of elements.

<!--more-->

### Relevant blog posts

Here is the full list of relevant blog posts:

{{< tag-list research-unbiased-mad >}}

### BibTeX reference

```bib
@article{akinshin2022madfactors,
  title = {Finite-sample bias-correction factors for the median absolute deviation based on the Harrell-Davis quantile estimator and its trimmed modification},
  author = {Akinshin, Andrey},
  year = {2022},
  month = {7},
  publisher = {arXiv},
  doi = {10.48550/ARXIV.2207.12005},
  url = {https://arxiv.org/abs/2207.12005}
}
```