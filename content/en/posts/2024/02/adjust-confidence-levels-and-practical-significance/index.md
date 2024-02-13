---
title: Simplifying adjustments of confidence levels and practical significance thresholds
date: 2024-02-13
tags:
- mathematics
- statistics
- research
features:
- math
---

Translation of the buisness goals to the actual parameters of the statistical procedure is a non-trivial task.
The degree of non-triviality increases if we should adjust several parameters at the same time.
In this post, we consider a problem of simultaneous choice
  of the confidence level and the practical significance threshold.
We discuss possible pitfalls and how to simplify the adjusting procedure to avoid them.

<!--more-->

### The problem

Let us consider the following problem.
We have a sample $\mathbf{x}$ of size $n$.
The corresponding distribution is parametrized by a parameter $\theta$.
We want to known if $\theta$ is practically larger than zero, where the significance threshold is a matter of choice.
We also have two predefined estimators:

* Estimator $T$ for the parameter $\theta$: $T(\mathbf{x}) = \hat{\theta}$,
* Estimator $S$ for the dispersion of a sample: $S(\mathbf{x}) = \hat{\sigma}$.

For the given samples, we want to obtain the correct answer with the max false-positive rate of $\alpha$.

The confidence interval approach is essentially gives us a measure of uncertainty $\Delta$,
  so the check condition can be expressed as predicate $P(\mathbf{x})$:

$$
P(\mathbf{x}):\quad \hat{\theta} - \Delta > C_{\operatorname{raw}},
$$

where $C_{\operatorname{raw}}$ is the statistical theshold expressed in the raw measurement units.

The value of $\Delta$ depends on the sample size $n$, the dispersion $\hat{\sigma}$, and the confidence level $\gamma$.
For simplicity, we use the classic equation: $\Delta = c(\gamma)\hat{\sigma}n^{-1/2}$.
Thus,

$$
P(\mathbf{x}):\quad \hat{\theta} - c(\gamma)\hat{\sigma}n^{-1/2} > C_{\operatorname{raw}}.
\tag{1}
$$

The goal here is to set the value of $\gamma$ to ensure that the actual false-positive rate does not exceed $\alpha$.

Now let us discuss how do we typically choose the practical significance threshold value.
This task is supposed to be handled by an expert in the domain area,
  who adjusts it according to intuition or additional business goals.
This way or another, there is an adjusting procedure.
In problems with the false-positive rate requirement,
  it is usually acceptable to get a better false-positive rate than the requirement,
  but it is not acceptable to get a worse one.
Therefore, the adjusting procedure aims to detect not exactly the minimum effect of intereset,
  but any value larger than it (of course, the lower, the better).
This procedure also often involves real data sets or numerical simulations with model distributions,
  so that it is possible to calibrate the threshold value.
We consider a single calibration step based on a data set of samples
  $\mathbf{x}_1, \mathbf{x}_2, \ldots, \mathbf{x}_m$,
  where the $\alpha$ fraction of the samples came from distributions with practically insignificant effect sizes.
Therefore, the chosen threshold should gives us a predicate $P(\mathbf{x})$:

$$
\Sigma_{i=1}^m \mathbb{I}\left[
  P(\mathbf{x}_i)
\right] \leq \alpha \cdot m.
$$

For the given $n$, $T$, $S$, $c$, $\alpha$,
  we want to choose $C_{\operatorname{raw}}$ and $\gamma$ to satisfy the following inequality:

$$
\Sigma_{i=1}^m \mathbb{I}\left[
  T(\mathbf{x}_i) - c(\gamma)S(\mathbf{x}_i)n^{-1/2} > C_{\operatorname{raw}}
\right] \leq \alpha \cdot m.
$$

### Pitfall 1: choosing $\gamma$

One may say that the confidence level automatically controls the false-positive rate.
Therefore, we can put $\gamma=1-\alpha$ (assuming one-sided test)
  and adjust $C_{\operatorname{raw}}$ in a numerical simulation.
Unfortunately, this is not always true in practice.
Indeed, let us consider nonparametric case and bootstrap-based confidence intervals for a distribution quantile.
Here is a naive R implementation of the false-positive rate calculation
  for the confidence intervals around the median of the standard normal distribution
  for $n = 3$, $\gamma = 0.95$:

```r
P <- function(x, rep = 1000, gamma = 0.95) {
  bootstrap_medians <- replicate(rep, median(sample(x, size = length(x), replace = TRUE)))
  quantile(bootstrap_medians, probs = 1 - gamma) > 0
}
# False-positive rate
fp <- function(n, m, rD) sum(replicate(m, P(rD(n)))) / m

n <- 3
m <- 1000
set.seed(1729)
fp(n, m, \(n) rnorm(n))
```

One may expect a result about $1-\gamma= 0.05$, but the actual result is $\approx 0.117$
  (because of the small sample size).

### Pitfall 2: choosing $c$

Now, let us consider a problem of estimating the maximum value of a sample of the given size.
According to the Fisher–Tippett–Gnedenko theorem,
  these maximum values belong to one of the three distribution families:
  the Gumbel distribution, the Fréchet distribution, or the Weibull distribution.
In order to obtain proper confidence intervals,
  we have to build a proper approximation for one of these distributions.
This is a tricky problems from the extreme value theory.
It has some classic solutions, but most of them are not always applicable in practice.

Thus, the task of expressing the desired confidence level that meets
  the business goals may be challenging in some cases.
Moreover, the model itself is quite complicated.
There are many pitfalls on the way, and it is too easy to introduce an unnoticed mistake in the implementation.
I believe, we can simplify the situation if we look at the problem from a different angle.
Let me to speculate a little bit about it.

### Pitfall 3: $n=1$

Sometimes, the confidence intervals can be non-applicable at all.
Let us think about the extreme cases.
For example, we consider a discrete-continuous mixture distribution
  that frequently produces small samples of identical values.
Such samples have undefined dispersion, and, therefore, we cannot express the confidence intervals.
How do we design a decision-making procedure in this case?

### The soluition

The above inequality contains too many variables.
Let us simplify it.
Firstly, we switch from the raw units of measurements to the effect size.
We can express this idea via a normalization by dispersion:

$$
P(\mathbf{x}):\quad
  \frac{\hat{\theta}}{\hat{\sigma}} - c(\gamma)n^{-1/2} > \frac{C_{\operatorname{raw}}}{\hat{\sigma}},
$$

The new threshold $C_{\operatorname{raw}}/\hat{\sigma}$
  can be redefined in terms of the effect size by $C_{\operatorname{ES}}$.
The normalized parameter estimation $\hat{\theta}/\hat{\sigma}$
  can be treated as the effect size estimation $\widehat{\operatorname{ES}}$.
Thus, we obtain the following inequality:

$$
P(\mathbf{x}):\quad \widehat{\operatorname{ES}} - c(\gamma)n^{-1/2} > C_{\operatorname{ES}}
$$

or

$$
P(\mathbf{x}):\quad \widehat{\operatorname{ES}} > C_{\operatorname{ES}} + c(\gamma)n^{-1/2}.
$$

Finally, we denote $C_{\operatorname{ES}} + c(\gamma)n^{-1/2}$ by $K_n$:

$$
P(\mathbf{x}):\quad \widehat{\operatorname{ES}} > K_n.
\tag{2}
$$



Here we should simultaneously define both $C_{\operatorname{raw}}$ and $c(\gamma)$ coherentlly.

Equation $(2)$ is much simpler:

$$
\Sigma_{i=1}^m \mathbb{I}\left[
  \widehat{\operatorname{ES}}(\mathbf{x}_i) > K_n
\right] \leq \alpha \cdot m.
$$

The value of $K_n$ can be defined via a quantile $Q$ of $\left\{ \widehat{\operatorname{ES}}(\mathbf{x}_i) \right\}$:

$$
K_n = Q\left( \left\{ \widehat{\operatorname{ES}}(\mathbf{x}_i) \right\}, 1 - \alpha \right).
$$

Under the hood, $K_n$ is still $C_{\operatorname{ES}} + c(\gamma)n^{-1/2}$, but it does not matter anymore.
Indeed, $C_{\operatorname{ES}}$ and $\gamma$ are constants we should choose;
  consequently, $c(\gamma)$ is a also a constant;
  $n$ if a constant in the given experiment.
Therefore $K_n$ becomes a single "cummulative" constnat we should define.

When we aggregate $K_n$ from different simulation steps, different straightforward strategies can be used.
If distributions of $K_n$ is light-tailed and well-bounded, the maximum $K_n$ can be used.
In case of heavy-tailed distribution, a reasonably large quantile is recommended.
Weights of the steps should be defined according their representativity and should be acknowledged in aggregation.

If we look deep inside this approach, you will see the same confidence interval, but normalized and reexpressed.
However, this switch in representation helps to build a simple and reliable training system
  that *actually* ensures the desired maximum false-positive rate.
It's much easier to implement than classic approach with requires simultaneous definition of two variables.
Also, it supports samples of a single element and, therefore, can be used for gradual sequential analysis.
