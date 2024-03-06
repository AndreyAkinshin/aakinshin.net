---
title: Hodges-Lehmann-Sen shift and shift confidence interval estimators
date: 2022-05-31
tags:
- mathematics
- statistics
- research
- Hodges-Lehmann Estimator
features:
- math
---

In the previous two posts
  ([1]({{< ref hodges-lehmann-efficiency1 >}}), [2]({{< ref hodges-lehmann-efficiency2 >}})),
  I discussed the Hodges-Lehmann median estimator.
The suggested idea of getting median estimations based on a cartesian product
  could be adopted to estimate the shift between two samples.
In this post, we discuss how to build Hodges-Lehmann-Sen shift estimator
  and how to get confidence intervals for the obtained estimations.
Also, we perform a simulation study that checks the actual coverage percentage of these intervals.

<!--more-->

### Hodges-Lehmann-Sen shift estimator

Let's consider two samples $x = \{ x_1, x_2, \ldots, x_n, \}$ and $y = \{ y_1, y_2, \ldots, y_m \}$.
The Hodges-Lehmann-Sen shift is defined as follows:

$$
\hat{\Delta} =
  \underset{1 \leq i \leq n;\; 1 \leq j \leq m}{\operatorname{median}}\Big(y_j - x_i\Big).
$$

It was suggested in {{< link hodges1963 >}} and {{< link sen1963 >}}.

### Confidence Interval

Once we get a shift estimation $\hat{\Delta}$, we may want to also get a confidence interval for this estimation.
{{< link hodges1963 >}} doesn't contain any mention of confidence intervals.
{{< link sen1963 >}} includes a discussion about confidence interval, but it's quite vague.
Recently, I have found a nice straightforward approach for getting CIs (see {{< link deshpande2018 >}}, 7.11.2).
Let's calculate all the pairwise differences $y_j-x_i$, sort them and denote the result as
  $d = \{ d_1, d_2, \ldots, d_{nm} \}$.
Next, we define the required confidence interval with confidence level $\alpha$ as $[d_l, d_u]$ where

$$
l = \Big[
  \frac{nm}{2} - z_{\alpha/2}\sqrt{\frac{nm(n+m+1)}{12}} - 0.5
\Big],
$$

$$
u = \Big[
  \frac{nm}{2} + z_{\alpha/2}\sqrt{\frac{nm(n+m+1)}{12}} - 0.5
\Big].
$$

### Simulation Study

Now it's time to check the above equations.
Let's enumerate different distributions, sample sizes, confidence levels,
  and check the actual coverage percentage in each situation.

Here is the source code of this simulation:

{{< src "study.R" >}}

And here are the results:

```md
*** n = 5, alpha = 90% ***
Uniform(a=0, b=1)             :  89.65%
Triangular(a=0, b=2, c=1)     :  89.20%
Triangular(a=0, b=2, c=0.2)   :  89.00%
Beta(a=2, b=4)                :  89.72%
Beta(a=2, b=10)               :  90.32%
Normal(m=0, sd=1)             :  88.78%
Weibull(scale=1, shape=2)     :  89.24%
Student(df=3)                 :  89.56%
Gumbel(loc=0, scale=1)        :  89.32%
Exp(rate=1)                   :  89.52%
Cauchy(x0=0, gamma=1)         :  89.16%
Pareto(loc=1, shape=0.5)      :  89.19%
Pareto(loc=1, shape=2)        :  89.29%
LogNormal(mlog=0, sdlog=1)    :  89.53%
LogNormal(mlog=0, sdlog=2)    :  89.18%
LogNormal(mlog=0, sdlog=3)    :  89.06%
Weibull(shape=0.3)            :  89.56%
Weibull(shape=0.5)            :  88.83%
Frechet(shape=1)              :  89.42%
Frechet(shape=3)              :  89.63%

*** n = 5, alpha = 95% ***
Uniform(a=0, b=1)             :  94.72%
Triangular(a=0, b=2, c=1)     :  94.93%
Triangular(a=0, b=2, c=0.2)   :  94.58%
Beta(a=2, b=4)                :  94.56%
Beta(a=2, b=10)               :  94.80%
Normal(m=0, sd=1)             :  94.36%
Weibull(scale=1, shape=2)     :  95.07%
Student(df=3)                 :  94.73%
Gumbel(loc=0, scale=1)        :  95.03%
Exp(rate=1)                   :  94.71%
Cauchy(x0=0, gamma=1)         :  94.38%
Pareto(loc=1, shape=0.5)      :  94.64%
Pareto(loc=1, shape=2)        :  94.58%
LogNormal(mlog=0, sdlog=1)    :  94.56%
LogNormal(mlog=0, sdlog=2)    :  94.90%
LogNormal(mlog=0, sdlog=3)    :  94.90%
Weibull(shape=0.3)            :  94.56%
Weibull(shape=0.5)            :  94.43%
Frechet(shape=1)              :  94.88%
Frechet(shape=3)              :  94.52%

*** n = 5, alpha = 99% ***
Uniform(a=0, b=1)             :  99.21%
Triangular(a=0, b=2, c=1)     :  99.28%
Triangular(a=0, b=2, c=0.2)   :  99.22%
Beta(a=2, b=4)                :  99.38%
Beta(a=2, b=10)               :  99.17%
Normal(m=0, sd=1)             :  99.13%
Weibull(scale=1, shape=2)     :  99.23%
Student(df=3)                 :  99.35%
Gumbel(loc=0, scale=1)        :  99.23%
Exp(rate=1)                   :  99.29%
Cauchy(x0=0, gamma=1)         :  99.37%
Pareto(loc=1, shape=0.5)      :  99.30%
Pareto(loc=1, shape=2)        :  99.41%
LogNormal(mlog=0, sdlog=1)    :  99.21%
LogNormal(mlog=0, sdlog=2)    :  99.29%
LogNormal(mlog=0, sdlog=3)    :  99.34%
Weibull(shape=0.3)            :  99.21%
Weibull(shape=0.5)            :  99.29%
Frechet(shape=1)              :  99.31%
Frechet(shape=3)              :  99.30%

*** n = 10, alpha = 90% ***
Uniform(a=0, b=1)             :  89.33%
Triangular(a=0, b=2, c=1)     :  89.36%
Triangular(a=0, b=2, c=0.2)   :  89.77%
Beta(a=2, b=4)                :  88.51%
Beta(a=2, b=10)               :  89.07%
Normal(m=0, sd=1)             :  89.58%
Weibull(scale=1, shape=2)     :  89.43%
Student(df=3)                 :  89.19%
Gumbel(loc=0, scale=1)        :  89.45%
Exp(rate=1)                   :  88.99%
Cauchy(x0=0, gamma=1)         :  90.34%
Pareto(loc=1, shape=0.5)      :  89.42%
Pareto(loc=1, shape=2)        :  89.38%
LogNormal(mlog=0, sdlog=1)    :  89.37%
LogNormal(mlog=0, sdlog=2)    :  89.34%
LogNormal(mlog=0, sdlog=3)    :  89.42%
Weibull(shape=0.3)            :  89.59%
Weibull(shape=0.5)            :  89.25%
Frechet(shape=1)              :  89.60%
Frechet(shape=3)              :  89.56%

*** n = 10, alpha = 95% ***
Uniform(a=0, b=1)             :  94.85%
Triangular(a=0, b=2, c=1)     :  94.79%
Triangular(a=0, b=2, c=0.2)   :  94.51%
Beta(a=2, b=4)                :  95.02%
Beta(a=2, b=10)               :  94.71%
Normal(m=0, sd=1)             :  94.85%
Weibull(scale=1, shape=2)     :  95.04%
Student(df=3)                 :  94.71%
Gumbel(loc=0, scale=1)        :  94.63%
Exp(rate=1)                   :  94.72%
Cauchy(x0=0, gamma=1)         :  94.47%
Pareto(loc=1, shape=0.5)      :  94.28%
Pareto(loc=1, shape=2)        :  94.96%
LogNormal(mlog=0, sdlog=1)    :  94.75%
LogNormal(mlog=0, sdlog=2)    :  94.49%
LogNormal(mlog=0, sdlog=3)    :  94.41%
Weibull(shape=0.3)            :  94.71%
Weibull(shape=0.5)            :  94.83%
Frechet(shape=1)              :  94.66%
Frechet(shape=3)              :  94.69%

*** n = 10, alpha = 99% ***
Uniform(a=0, b=1)             :  99.25%
Triangular(a=0, b=2, c=1)     :  99.25%
Triangular(a=0, b=2, c=0.2)   :  99.24%
Beta(a=2, b=4)                :  99.20%
Beta(a=2, b=10)               :  99.21%
Normal(m=0, sd=1)             :  99.31%
Weibull(scale=1, shape=2)     :  99.21%
Student(df=3)                 :  99.36%
Gumbel(loc=0, scale=1)        :  99.49%
Exp(rate=1)                   :  99.19%
Cauchy(x0=0, gamma=1)         :  99.41%
Pareto(loc=1, shape=0.5)      :  99.19%
Pareto(loc=1, shape=2)        :  99.28%
LogNormal(mlog=0, sdlog=1)    :  99.30%
LogNormal(mlog=0, sdlog=2)    :  99.31%
LogNormal(mlog=0, sdlog=3)    :  99.39%
Weibull(shape=0.3)            :  99.20%
Weibull(shape=0.5)            :  99.36%
Frechet(shape=1)              :  99.28%
Frechet(shape=3)              :  99.34%

*** n = 50, alpha = 90% ***
Uniform(a=0, b=1)             :  89.62%
Triangular(a=0, b=2, c=1)     :  88.94%
Triangular(a=0, b=2, c=0.2)   :  89.03%
Beta(a=2, b=4)                :  89.16%
Beta(a=2, b=10)               :  89.71%
Normal(m=0, sd=1)             :  89.14%
Weibull(scale=1, shape=2)     :  89.53%
Student(df=3)                 :  89.10%
Gumbel(loc=0, scale=1)        :  88.51%
Exp(rate=1)                   :  89.23%
Cauchy(x0=0, gamma=1)         :  89.14%
Pareto(loc=1, shape=0.5)      :  89.55%
Pareto(loc=1, shape=2)        :  89.27%
LogNormal(mlog=0, sdlog=1)    :  89.54%
LogNormal(mlog=0, sdlog=2)    :  89.12%
LogNormal(mlog=0, sdlog=3)    :  89.69%
Weibull(shape=0.3)            :  89.15%
Weibull(shape=0.5)            :  89.03%
Frechet(shape=1)              :  89.55%
Frechet(shape=3)              :  88.43%

*** n = 50, alpha = 95% ***
Uniform(a=0, b=1)             :  94.86%
Triangular(a=0, b=2, c=1)     :  94.54%
Triangular(a=0, b=2, c=0.2)   :  94.32%
Beta(a=2, b=4)                :  94.63%
Beta(a=2, b=10)               :  94.58%
Normal(m=0, sd=1)             :  94.97%
Weibull(scale=1, shape=2)     :  94.22%
Student(df=3)                 :  94.85%
Gumbel(loc=0, scale=1)        :  94.51%
Exp(rate=1)                   :  94.06%
Cauchy(x0=0, gamma=1)         :  94.57%
Pareto(loc=1, shape=0.5)      :  94.67%
Pareto(loc=1, shape=2)        :  94.84%
LogNormal(mlog=0, sdlog=1)    :  94.46%
LogNormal(mlog=0, sdlog=2)    :  94.60%
LogNormal(mlog=0, sdlog=3)    :  95.00%
Weibull(shape=0.3)            :  94.68%
Weibull(shape=0.5)            :  94.49%
Frechet(shape=1)              :  94.75%
Frechet(shape=3)              :  94.69%

*** n = 50, alpha = 99% ***
Uniform(a=0, b=1)             :  99.24%
Triangular(a=0, b=2, c=1)     :  99.11%
Triangular(a=0, b=2, c=0.2)   :  99.34%
Beta(a=2, b=4)                :  99.30%
Beta(a=2, b=10)               :  99.26%
Normal(m=0, sd=1)             :  99.21%
Weibull(scale=1, shape=2)     :  99.28%
Student(df=3)                 :  99.31%
Gumbel(loc=0, scale=1)        :  99.27%
Exp(rate=1)                   :  99.28%
Cauchy(x0=0, gamma=1)         :  99.31%
Pareto(loc=1, shape=0.5)      :  99.41%
Pareto(loc=1, shape=2)        :  99.40%
LogNormal(mlog=0, sdlog=1)    :  99.20%
LogNormal(mlog=0, sdlog=2)    :  99.34%
LogNormal(mlog=0, sdlog=3)    :  99.24%
Weibull(shape=0.3)            :  99.30%
Weibull(shape=0.5)            :  99.37%
Frechet(shape=1)              :  99.33%
Frechet(shape=3)              :  99.36%
```

It seems that the approach is accurate enough, the coverage percentage is quite close to the requested confidence level.
