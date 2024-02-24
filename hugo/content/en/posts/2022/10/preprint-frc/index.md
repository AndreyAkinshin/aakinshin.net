---
title: "Preprint announcement: 'Finite-sample Rousseeuw-Croux scale estimators'"
date: 2022-10-18
tags:
- mathematics
- statistics
- paper-announcement
- research-frc
features:
- math
---

Recently, I published a preprint of a paper 'Finite-sample Rousseeuw-Croux scale estimators'.
It's based on a series of my [research notes]({{< ref research-frc >}}).

The paper preprint is available on arXiv:
  [arXiv:2209.12268 [stat.ME]](https://arxiv.org/abs/2209.12268).
The paper source code is available on GitHub:
  [AndreyAkinshin/paper-frc](https://github.com/AndreyAkinshin/paper-frc).
You can cite it as follows:

* Andrey Akinshin (2022)
  "Finite-sample Rousseeuw-Croux scale estimators"
  [arXiv:2209.12268](https://arxiv.org/abs/2209.12268)

Abstract:

>  The Rousseeuw-Croux $S_n$, $Q_n$ scale estimators and the median absolute deviation $\operatorname{MAD}_n$
>    can be used as consistent estimators for the standard deviation under normality.
>  All of them are highly robust: the breakdown point of all three estimators is $50\%$.
>  However, $S_n$ and $Q_n$ are much more efficient than $\operatorname{MAD}_n$:
>    their asymptotic Gaussian efficiency values are $58\%$ and $82\%$ respectively
>    compared to $37\%$ for $\operatorname{MAD}_n$.
>  Although these values look impressive, they are only asymptotic values.
>  The actual Gaussian efficiency of $S_n$ and $Q_n$ for small sample sizes
>    is noticeably lower than in the asymptotic case.
>
>  The original work by Rousseeuw and Croux (1993)
>    provides only rough approximations of the finite-sample bias-correction factors for $S_n,\, Q_n$
>    and brief notes on their finite-sample efficiency values.
>  In this paper, we perform extensive Monte-Carlo simulations in order to obtain refined values of the
>    finite-sample properties of the Rousseeuw-Croux scale estimators.
>  We present accurate values of the bias-correction factors and Gaussian efficiency for small samples ($n \leq 100$)
>    and prediction equations for samples of larger sizes.

<!--more-->

### Relevant blog posts

Here is the full list of the relevant blog posts:

{{< tag-list research-frc >}}

### BibTeX reference

```bib
@article{akinshin2022frc,
  title = {Finite-sample Rousseeuw-Croux scale estimators},
  author = {Akinshin, Andrey},
  year = {2022},
  month = {9},
  publisher = {arXiv},
  doi = {10.48550/arXiv.2209.12268},
  url = {https://arxiv.org/abs/2209.12268}
}
```
