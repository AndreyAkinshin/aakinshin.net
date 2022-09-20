---
title: The Huggins-Roy family of effective sample sizes
date: 2022-09-13
tags:
- Statistics
- research
- research-wqe
features:
- math
---

When we work with weighted samples, it's essential to introduce adjustments for the sample size.
Indeed, let's consider two following weighted samples:

$$
\mathbf{x}_1 = \{ x_1, x_2, \ldots, x_n \}, \quad \mathbf{w}_1 = \{ w_1, w_2, \ldots, w_n \},
$$

$$
\mathbf{x}_2 = \{ x_1, x_2, \ldots, x_n, x_{n+1} \}, \quad \mathbf{w}_2 = \{ w_1, w_2, \ldots, w_n, 0 \}.
$$

Since the weight of $x_{n+1}$ in the second sample is zero,
  it's natural to expect that both samples have the same set of properties.
However, there is a major difference between $\mathbf{x}_1$ and $\mathbf{x}_2$: their sample sizes which are
  $n$ and $n+1$.
In order to eliminate this difference, we typically introduce the *effective sample size* (ESS)
  which is estimated based on the list of weights.

There are various ways to estimate the ESS.
In this post, we briefly discuss the Huggins-Roy's family of ESS.

<!--more-->

For a list of weights $\mathbf{w} = \{ w_1, w_2, \ldots, w_n \}$, we can consider the corresponding normalized weights
  (or standardized weights):

$$
\overline{\mathbf{w}} = \frac{\mathbf{w}}{\sum_{i=1}^n w_i}.
$$

For any non-degenerate weighted sample, the sum of all weights is always positive so that
  the normalized weights are defined.

The Huggins-Roy's family is given by:

$$
\operatorname{ESS}_\beta(\overline{\mathbf{w}}) =
  \Bigg( \frac{1}{\sum_{i=1}^n \overline{w}_i^\beta } \Bigg)^{\frac{1}{\beta - 1}} =
  \Bigg( \sum_{i=1}^n \overline{w}_i^\beta \Bigg)^{\frac{1}{1 - \beta}}.
$$

This family is proposed in [[Huggins2019]](#Huggins2019) and discussed in
  [[Elvira2021]](#Elvira2021) and [[Elvira2022]](#Elvira2022).

In order to understand this approach, let's consider several special cases.

* $\beta = 0$:

$$
\operatorname{ESS}_0(\overline{\mathbf{w}}) = n - n_z(\overline{\mathbf{w}}),
$$

  where $n_z(\overline{\mathbf{w}})$ is the number of zeros in $\overline{\mathbf{w}}$.
This approach is quite straightforward: we just omit elements with zero weights.

* $\beta = 1/2$:

$$
\operatorname{ESS}_{1/2}(\overline{\mathbf{w}}) = \Bigg( \sum_{i=1}^n \sqrt{\overline{w}_i} \Bigg)^2.
$$

* $\beta = 1$:

$$
\operatorname{ESS}_{1}(\overline{\mathbf{w}}) =
  \operatorname{exp} \Bigg( -\sum_{i=1}^n \overline{w}_i \log \overline{w}_i \Bigg)^2.
$$

This approach is also known as *perplexity*

* $\beta = 2$:

$$
\operatorname{ESS}_{2}(\overline{\mathbf{w}}) = \frac{1}{\sum_{i=1}^n \overline{w}_i^2 }.
$$

This approach is often referenced as the Kish's effective sample size (see [[Kish1965]](#Kish1965)).

* $\beta = \infty$:

$$
\operatorname{ESS}_{\infty}(\overline{\mathbf{w}}) =
  \frac{1}{\max [\overline{w}_1, \overline{w}_2, \ldots, \overline{w}_n] }.
$$

This approach is also popular and straightforward: we define the sample size based on the maximum weight.

### References

* <b id="Elvira2022">[Elvira2022]</b>  
  Víctor Elvira, Luca Martino, and Christian P. Robert. "Rethinking the effective sample size."
  International Statistical Review (2022).  
  https://arxiv.org/pdf/1809.04129.pdf
* <b id="Elvira2021">[Elvira2021]</b>  
  Víctor Elvira, Luca Martino. "Effective sample size approximations as entropy measures." (2021)  
  https://vixra.org/pdf/2111.0145v1.pdf
* <b id="Huggins2019">[Huggins2019]</b>  
  Huggins, Jonathan H., and Daniel M. Roy.
  "Sequential Monte Carlo as approximate sampling: bounds, adaptive resampling via $\infty$-ESS,
  and an application to particle Gibbs." Bernoulli 25, no. 1 (2019): 584-622.  
  https://arxiv.org/pdf/1503.00966.pdf
* <b id="Kish1965">[Kish1965]</b>  
  Kish, Leslie. Survey sampling. Chichester., 1965.  
  https://doi.org/10.1002/bimj.19680100122
