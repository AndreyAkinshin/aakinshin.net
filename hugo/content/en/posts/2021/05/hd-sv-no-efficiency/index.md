---
title: Comparing the efficiency of the Harrell-Davis, Sfakianakis-Verginis, and Navruz-Özdemir quantile estimators
description: "A set of simulation studies that calculate the efficiency of the Harrell-Davis, Sfakianakis-Verginis, and Navruz-Özdemir quantile estimators for different distributions"
date: 2021-05-18
tags:
- mathematics
- statistics
- research
- Quantile
- Statistical efficiency
features:
- math
---

In the previous posts, I discussed the statistical efficiency of different quantile estimators
  ([Efficiency of the Harrell-Davis quantile estimator]({{< ref hdqe-efficiency >}}) and 
  [Efficiency of the winsorized and trimmed Harrell-Davis quantile estimators]({{< ref wthdqe-efficiency >}})).

In this post, I continue this research and compare the efficiency of
  the Harrell-Davis quantile estimator,
  the [Sfakianakis-Verginis quantile estimators]({{< ref sfakianakis-verginis-quantile-estimator >}}), and
  the [Navruz-Özdemir quantile estimator]({{< ref navruz-ozdemir-quantile-estimator>}}).

{{< imgld LightAndHeavy_N10_Efficiency >}}

<!--more-->

### Simulation design

The relative efficiency value depends on five parameters:

* Target quantile estimator
* Baseline quantile estimator
* Estimated quantile $p$
* Sample size $n$
* Distribution

In this case study, we are going to compare three target quantile estimators:

(1) The **Harrell-Davis (HD)** quantile estimator ([[Harrell1982]](#Harrell1982)):

$$
Q_\textrm{HD}(p) = \sum_{i=1}^{n} W_{i} \cdot x_{(i)}, \quad
W_{i} = I_{i/n}(a, b) - I_{(i-1)/n}(a, b), \quad
a = p(n+1),\; b = (1-p)(n+1)
$$

where
  $I_t(a, b)$ denotes the [regularized incomplete beta function](https://en.wikipedia.org/wiki/Beta_function#Incomplete_beta_function),
  $x_{(i)}$ is the $i^\textrm{th}$ [order statistics](https://en.wikipedia.org/wiki/Order_statistic).

(2) The [**Sfakianakis-Verginis (SV)** quantile estimators]({{< ref sfakianakis-verginis-quantile-estimator >}}) ([[Sfakianakis2008]](#Sfakianakis2008)):

$$
\begin{split}
Q_\textrm{SV1}(p) =&
\frac{B_0}{2} \big( X_{(1)}+X_{(2)}-X_{(3)} \big) +
\sum_{i=1}^{n} \frac{B_i+B_{i-1}}{2} X_{(i)} +
\frac{B_n}{2} \big(- X_{(n-2)}+X_{(n-1)}-X_{(n)} \big),\\
Q_\textrm{SV2}(p) =& \sum_{i=1}^{n} B_{i-1} X_{(i)} + B_n \cdot \big(2X_{(n)} - X_{(n-1)}\big),\\
Q_\textrm{SV3}(p) =& \sum_{i=1}^n B_i X_{(i)} + B_0 \cdot \big(2X_{(1)}-X_{(2)}\big).
\end{split}
$$

where $B_i = B(i; n, p)$ is probability mass function of the binomial distribution $B(n, p)$,
  $X_{(i)}$ are order statistics of sample $X$.

(3) The [**Navruz-Özdemir (NO)** quantile estimator]({{< ref navruz-ozdemir-quantile-estimator>}}) ([[Navruz2020]](#Navruz2020)):

$$
\begin{split}
Q_\textrm{NO}(p) =
& \Big( (3p-1)X_{(1)} + (2-3p)X_{(2)} - (1-p)X_{(3)} \Big) B_0 +\\
& +\sum_{i=1}^n \Big((1-p)B_{i-1}+pB_i\Big)X_{(i)} +\\
& +\Big( -pX_{(n-2)} + (3p-1)X_{(n-1)} + (2-3p)X_{(n)} \Big) B_n
\end{split}
$$

where $B_i = B(i; n, p)$ is probability mass function of the binomial distribution $B(n, p)$,
  $X_{(i)}$ are order statistics of sample $X$.

The conventional baseline quantile estimator in such simulations is
  the traditional quantile estimator that is defined as
  a linear combination of two subsequent order statistics.
To be more specific, we are going to use the Type 7 quantile estimator from the Hyndman-Fan classification or
  HF7 ([[Hyndman1996]](#Hyndman1996)).
It can be expressed as follows (assuming one-based indexing):

$$
Q_\textrm{HF7}(p) = x_{(\lfloor h \rfloor)}+(h-\lfloor h \rfloor)(x_{(\lfloor h \rfloor+1)})-x_{(\lfloor h \rfloor)},\quad
h = (n-1)p+1.
$$

Thus, we are going to estimate the relative efficiency of HD, SV1, SV2, SV3, and NO quantile estimators comparing to
  the traditional quantile estimator HF7.
For the $p^\textrm{th}$ quantile,
  the relative efficiency of the target quantile estimator $Q_\textrm{Target}$ can be calculated
  as the ratio of the estimator mean squared errors ($\textrm{MSE}$):

$$
\textrm{Efficiency}(p) =
\dfrac{\textrm{MSE}(Q_{HF7}, p)}{\textrm{MSE}(Q_\textrm{Target}, p)} =
\dfrac{\operatorname{E}[(Q_{HF7}(p) - \theta(p))^2]}{\operatorname{E}[(Q_\textrm{Target}(p) - \theta(p))^2]}
$$

where $\theta(p)$ is the true value of the $p^\textrm{th}$ quantile.
The $\textrm{MSE}$ value depends on the sample size $n$, so it should be calculated independently for
  each sample size value.

Finally, we should choose the distributions for sample generation.
I decided to choose 4 light-tailed distributions and 4 heavy-tailed distributions

| distribution      | description                                                                             |
| ----------------- | --------------------------------------------------------------------------------------- |
| Beta(2,10)        | Beta distribution with a=2, b=10                                                        |
| U(0,1)            | Uniform distribution on [0;1]                                                           |
| N(0,1^2)          | Normal distribution with mu=0, sigma=1                                                  |
| Weibull(1,2)      | Weibull distribution with scale=1, shape=2                                              |
| Cauchy(0,1)       | Cauchy distribution with location=0, scale=1                                            |
| Pareto(1, 0.5)    | Pareto distribution with xm=1, alpha=0.5                                                |
| LogNormal(0,3^2)  | Log-normal distribution with mu=0, sigma=3                                              |
| Exp(1) + Outliers | 95% of exponential distribution with rate=1 and 5% of uniform distribution on [0;10000] |

Here are the probability density functions of these distributions:

{{< imgld LightAndHeavy_Pdf >}}

For each distribution, we are going to do the following:

* Enumerate all the percentiles and calculate the true percentile value $\theta(p)$ for each distribution
* Enumerate different sample sizes (from 3 to 40)
* Generate a bunch of random samples,
    estimate the percentile values using all estimators,
    calculate the relative efficiency of all target quantile estimators quantile estimator.

Here are the results of the simulation:

{{< imgld LightAndHeavy_Efficiency >}}

Here are the static charts for some of the $n$ values:

{{< imgld LightAndHeavy_N03_Efficiency >}}
{{< imgld LightAndHeavy_N04_Efficiency >}}
{{< imgld LightAndHeavy_N05_Efficiency >}}
{{< imgld LightAndHeavy_N10_Efficiency >}}
{{< imgld LightAndHeavy_N20_Efficiency >}}
{{< imgld LightAndHeavy_N40_Efficiency >}}

### Conclusion

Based on the above simulation, we could draw the following observations:

* The HD quantile estimator seems to be a good choice for unknown distribution.
* The SV3 quantile estimator provides good efficiency for
    the high-density area of heavy-tailed *right*-skewed distributions.
* By analogy, we can assume that the SV2 quantile estimator provides good efficiency for
    the high-density area of heavy-tailed *left*-skewed distributions.
* The NO quantile estimator provides good efficiency for
    the low-density area of heavy-tailed distributions on small samples.

### References

* <b id=Harrell1982>[Harrell1982]</b>  
  Harrell, F.E. and Davis, C.E., 1982. A new distribution-free quantile estimator.
  *Biometrika*, 69(3), pp.635-640.  
  https://doi.org/10.2307/2335999 
* <b id="Sfakianakis2008">[Sfakianakis2008]</b>  
  Sfakianakis, Michael E., and Dimitris G. Verginis. "A new family of nonparametric quantile estimators." Communications in Statistics—Simulation and Computation® 37, no. 2 (2008): 337-345.  
  https://doi.org/10.1080/03610910701790491
* <b id="Navruz2020">[Navruz2020]</b>  
  Navruz, Gözde, and A. Fırat Özdemir. "A new quantile estimator with weights based on a subsampling approach."
  British Journal of Mathematical and Statistical Psychology 73, no. 3 (2020): 506-521.  
  https://doi.org/10.1111/bmsp.12198
* <b id="Hyndman1996">[Hyndman1996]</b>  
  Hyndman, R. J. and Fan, Y. 1996. Sample quantiles in statistical packages, *American Statistician* 50, 361–365.  
  https://doi.org/10.2307/2684934
