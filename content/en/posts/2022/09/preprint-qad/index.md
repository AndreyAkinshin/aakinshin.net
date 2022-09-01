---
title: "Preprint announcement: 'Quantile absolute deviation'"
date: 2022-09-01
tags:
- 
- Statistics
- paper-announcement
- research-qad
features:
- math
---

I have just published a preprint of a paper 'Quantile absolute deviation'.
It's based on a series of my [research notes]({{< ref research-qad >}})
  that I have been writing since December 2020.

The paper preprint is available on arXiv:
  [arXiv:2208.13459 [stat.ME]](https://arxiv.org/abs/2208.13459).
The paper source code is available on GitHub:
  [AndreyAkinshin/paper-qad](https://github.com/AndreyAkinshin/paper-qad).
You can cite it as follows:

* Andrey Akinshin (2022)
  "Quantile absolute deviation"
  [arXiv:2208.13459](https://arxiv.org/abs/2208.13459)

Abstract:

> The median absolute deviation (MAD) is a popular robust measure of statistical dispersion.
> However, when it is applied to non-parametric distributions (especially multimodal, discrete, or heavy-tailed),
>   lots of statistical inference issues arise.
> Even when it is applied to distributions with slight deviations from normality and these issues are not actual,
>   the Gaussian efficiency of the MAD is only 37% which is not always enough.
>
> In this paper, we introduce the *quantile absolute deviation* (QAD) as a generalization of the MAD.
> This measure of dispersion provides a flexible approach to analyzing properties of non-parametric distributions.
> It also allows controlling the trade-off between robustness and statistical efficiency.
> We use the trimmed Harrell-Davis median estimator based on the highest density interval of the given width
>   as a complimentary median estimator that gives
>   increased finite-sample Gaussian efficiency compared to the sample median
>   and a breakdown point matched to the QAD.
>
> As a rule of thumb, we suggest using two new measures of dispersion
>   called the *standard QAD* and the *optimal QAD*.
> They give 54% and 65% of Gaussian efficiency having breakdown points of 32% and 14% respectively.

<!--more-->

### Relevant blog posts

Here is the full list of the relevant blog posts:

{{< tag-list research-qad >}}

### BibTeX reference

```bib
@article{akinshin2022qad,
  title = {Quantile absolute deviation},
  author = {Akinshin, Andrey},
  year = {2022},
  month = {8},
  publisher = {arXiv},
  doi = {10.48550/ARXIV.2208.13459},
  url = {https://arxiv.org/abs/2208.13459}
}
```
