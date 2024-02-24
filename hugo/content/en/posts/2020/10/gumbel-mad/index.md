---
title: "The median absolute deviation value of the Gumbel distribution"
date: "2020-10-06"
tags:
- mathematics
- statistics
- research
- Quantiles
- Harrell-Davis quantile estimator
- Gumbel
features:
- math
---

The [Gumbel distribution](https://en.wikipedia.org/wiki/Gumbel_distribution) is not only a useful model in the [extreme value theory](https://en.wikipedia.org/wiki/Extreme_value_theory),
  but it's also a nice example of a slightly right-skewed distribution (skewness $\approx 1.14$).
Here is its density plot:

{{< imgld_medium gumbel >}}

In some of my statistical experiments, I like to use the Gumbel distribution as a sample generator for hypothesis checking or unit tests.
I also prefer the [median absolute deviation](https://en.wikipedia.org/wiki/Median_absolute_deviation) (MAD) over the standard deviation as a measure of dispersion because it's more robust in the case of non-parametric distributions.
Numerical hypothesis verification often requires the exact value of the median absolute deviation of the original distribution.
I didn't find this value in the reference tables, so I decided to do another exercise and derive it myself.
In this post, you will find a short derivation and the result (spoiler: the exact value is `0.767049251325708 * β`).
The general approach of the MAD derivation is common for most distributions, so it can be easily reused.

<!--more-->

### General approach

The median absolute deviation of a sample has a simple definition:

$$
\mathcal{MAD}_0 = \textrm{Median}(|x_i - \textrm{Median}(x_i)|).
$$

The exact formula for the distribution looks similar:

$$
\mathcal{MAD}_0 = \textrm{Median}(|X - \textrm{Median}(X)|).
$$

It's convenient to use a scaled version of MAD in many practical cases to make it a [consistent estimator](https://en.wikipedia.org/wiki/Consistent_estimator) for the standard deviation estimation.
It's often denoted as $\mathcal{MAD}$ without any clarification.
To avoid misinterpretation and highlight that we are working with a non-scaled version of MAD, we denote it as $\mathcal{MAD}_0$ instead of just $\mathcal{MAD}$.

We also denote the median distribution value as $M = \textrm{Median}(X)$.
Thus, the $\mathcal{MAD}_0$ definition can be rewritten as

$$
\mathcal{MAD}_0 = \textrm{Median}(|X - M|).
$$

Since $\mathcal{MAD}_0$ is the median of $|X - M|$, we can conclude that
  the range $[M - \mathcal{MAD}_0; M + \mathcal{MAD}_0]$ contains $50\%$ of the distribution:

{{< imgld_medium gumbel-mad >}}

This can be expressed using the distribution [CDF](https://en.wikipedia.org/wiki/Cumulative_distribution_function) (let's call it $F$):

$$
\begin{equation}
\label{eq:main}\tag{1}
F(M + \mathcal{MAD}_0) - F(M - \mathcal{MAD}_0) = 0.5.
\end{equation}
$$

Equation ($\ref{eq:main}$) is an important property of the median absolute deviation, which we will use to calculate it's exact value.

## Gumbel distribution

The Gumbel distribution is parametrized by $\mu$ (location) and $\beta$ (scale).
For these parameters, the median value and the CDF are well-known (see [[HoSM]](#HoSM), [1.3.6.6.16](https://www.itl.nist.gov/div898/handbook/eda/section3/eda366g.htm)):

$$
M = \mu - \beta \cdot \ln(\ln(2)), \quad F(x) = e^{-e^{-(x-\mu)/\beta}}.
$$

The $\mathcal{MAD}_0$ value is directly proportional to the scale parameter $\beta$,
  so let's introduce an auxiliary variable $p$ for the "descaled version" of $\mathcal{MAD}_0$:

$$
p = \mathcal{MAD}_0 / \beta.
$$

Next, let's express $F(M + \mathcal{MAD}_0)$ via $p$:

$$
\begin{split}
F(M + \mathcal{MAD}_0) & = F(\mu - \beta \cdot \ln(\ln(2)) + p \beta) = \\
& = e^{-e^{-(\mu - \beta \cdot \ln(\ln(2)) + p \beta - \mu)/\beta}} = \\
& = e^{-e^{\ln(\ln(2)) - p}} =
e^{-\ln(2) e^{-p}} =
0.5^{e^{-p}},
\end{split}
$$

In the same way, we can show that

$$
F(M - \mathcal{MAD}_0) = 0.5^{e^{p}}.
$$

Now, equation ($\ref{eq:main}$) can be transformed to

$$
0.5^{e^{-p}} - 0.5^{e^{p}} = 0.5.
$$

This equation can be solved numerically.
Here is a short R script which calculates the result:

{{< src "solve.R" >}}

The numerical solution is $p = 0.767049251325708 $.
Since $p = \mathcal{MAD}_0 / \beta$, the exact solution looks as follows:

$$
\mathcal{MAD}_0 = 0.767049251325708 \beta.
$$

Now we can use it in experiments (copy-pastable version: `0.767049251325708 * β`).

### Numerical simulation

Let's double-check that our calculations are correct.
Below you can see an R script that generates 1000 random samples from the Gumbel distribution
  with $\mu = 0,\; \beta = 1$ (1000 elements in each sample).
Next, it calculates the MAD estimation for each sample using the Harrell-Davis quantile estimator
  for the median estimations (see [[Harrell1982]](#Harrell1982)).
After that, it calculates the median of all MAD estimations and prints the result.

{{< src "simulation.R" >}}

This script's output is `0.7670284` which is close enough to the exact value `0.767049251325708`.

### Conclusion

The Gumbel distribution can be used as a good model of a slightly right-skewed distribution.
If we are playing with an algorithm that involves MAD estimations (e.g., [MAD-based outlier detector]({{< ref "harrell-davis-double-mad-outlier-detector" >}})),
  we can check the precision of our calculations using the exact MAD value which is $\mathcal{MAD}_0 = 0.767049251325708 \beta$.

The general approach can be reused for any other distributions with known median and CDF.
You can get the exact $\mathcal{MAD}_0$ value by solving the equation $F(M + \mathcal{MAD}_0) - F(M - \mathcal{MAD}_0) = 0.5$
  which is correct for the distribution of any form.

### References

* <b id="HoSM">[HoSM]</b>  
  NIST/SEMATECH e-Handbook of Statistical Methods, http://www.itl.nist.gov/div898/handbook/, October 6, 2020.
  https://doi.org/10.18434/M32189 
* <b id="Harrell1982">[Harrell1982]</b>  
  Harrell, F.E. and Davis, C.E., 1982. A new distribution-free quantile estimator.
  *Biometrika*, 69(3), pp.635-640.  
  https://pdfs.semanticscholar.org/1a48/9bb74293753023c5bb6bff8e41e8fe68060f.pdf
