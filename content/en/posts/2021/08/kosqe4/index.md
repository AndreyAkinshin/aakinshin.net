---
title: "Quantile estimators based on k order statistics, Part 4: Adopting trimmed Harrell-Davis quantile estimator"
date: 2021-08-24
tags:
- Statistics
- Quantile Estimators
- Quantile estimators based on k order statistics
features:
- math
---

In the previous posts, I discussed various aspects of
  [quantile estimators based on k order statistics]({{< ref kosqe1 >}}).
I already tried a few weight functions that aggregate the sample values to the quantile estimators
  (see posts about [an extension of the Hyndman-Fan Type 7 equation]({{< ref kosqe2 >}}) and
  about [adjusted regularized incomplete beta function]({{< ref kosqe3 >}})).
In this post, I continue my experiments and try to adopt the
  [trimmed modifications of the Harrell-Davis quantile estimator]({{< ref trimmed-hdqe >}}) to this approach.

<!--more-->

All posts from this series:

{{< tag-list "Quantile estimators based on k order statistics" >}}

### The approach

The general idea is the same that was used in [one]({{< ref kosqe2 >}}) of the previous posts.
We express the estimation of the $p^\textrm{th}$ quantile as follows:

$$
\begin{gather*}
q_p = \sum_{i=1}^{n} W_{i} \cdot x_i,\\
W_{i} = F(r_i) - F(l_i),\\
l_i = (i - 1) / n, \quad r_i = i / n,
\end{gather*}
$$

where F is a CDF function of a specific distribution.
The distribution has non-zero PDF only inside a window $[L_k, R_k]$
  that covers at most k order statistics:

$$
F(u) = \left\{
\begin{array}{lcrcllr}
0                      & \textrm{for} &         &      & u  & <    & L_k, \\
G(u)                   & \textrm{for} & L_k     & \leq & u  & \leq & R_k, \\
1                      & \textrm{for} & R_k     & <    & u, &      &
\end{array}
\right.
$$

$$
L_k = (h - 1) / (n - 1) \cdot (n - (k - 1)) / n, \quad R_k = L_k + (k-1)/n,
$$

$$
h = (n - 1)p + 1.
$$

Now we just have to define the $G: [0;1] \to [0;1]$ function that defines $F$ values inside the window.
We already discussed a few possible options for $G$:

* [An extension of Hyndman-Fan Type 7 equation]({{< ref kosqe2 >}}):

$$
G_{HF7}(u) = (u - L_k)/(R_k-L_k).
$$

* [Adjusted regularized incomplete beta function]({{< ref kosqe3 >}}):

$$
G_{\textrm{Beta}}(u) = I_{(u - L_k)/(R_k-L_k)}(kp, k(1-p)).
$$

Now it's time to try the
  [trimmed modifications of the Harrell-Davis quantile estimator]({{< ref trimmed-hdqe >}}) (THD).
In order to adjust THD, we should rescale the original regularized incomplete beta function:

$$
G_{\textrm{THD}}(u) = (I_u - I_{L_k}) / (I_{R_k} - I_{L_k}), \quad I_x = I_x(p(n+1), (1-p)(n+1))
$$

With such values, the suggested estimator becomes the exact copy of the Harrell-Davis quantile estimator for $k=n+1$.
Let's perform some numerical simulations to check the statistical efficiency of this estimator.

### Numerical simulations

We are going to take the same simulation setup that was declared in [this post]({{< ref thdqe-threshold >}}).
Briefly speaking, we evaluate the classic MSE-based relative statistical efficiency of different quantile estimators
  on samples from different light-tailed and heavy-tailed distributions
  using the classic Hyndman-Fan Type 7 quantile estimator as the baseline.

The considered estimator based on k order statistics is denoted as "KOS-THDk".
The estimator from the [previous post]({{< ref kosqe3 >}}) based on the adjusted beta function is denoted as "KOS-THDk".

Here are some of the statistical efficiency plots:

{{< imgld LightAndHeavy_a_N15_Efficiency >}}

{{< imgld LightAndHeavy_b_N15_Efficiency >}}

{{< imgld LightAndHeavy_c_N15_Efficiency >}}

{{< imgld LightAndHeavy_d_N15_Efficiency >}}

### Conclusion

It sounds reasonable to use the trimmed modifications of the Harrell-Davis quantile estimator with the trimming strategy
  based on k order statistics.
Unlike the originally proposed approach with the trimming strategy based on the highest density interval,
  the updated version of THD doesn't become degenerated in the corner cases
  (the problem of [over-trimming]({{< ref thdqe-overtrimming>}})).
Also, it provides more direct control of the estimator breakdown point, which is also a nice feature.

In the next post, I will try to come up with further improvements of the suggested estimator.
