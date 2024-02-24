---
title: Median absolute deviation vs. Shamos estimator
thumbnail: cauchy-10-light
date: 2022-02-01
tags:
- mathematics
- statistics
- research
features:
- math
---

There are multiple ways to estimate statistical dispersion.
The standard deviation is the most popular one, but it's not robust:
  a single outlier could heavily corrupt the results.
Fortunately, we have robust measures of dispersions like the *median absolute deviation* and the *Shamos estimator*.
In this post, we perform numerical simulations and
  compare these two estimators on different distributions and sample sizes.

<!--more-->

### Definitions

For a sample $x = \{ x_1, x_2, \ldots, x_n \}$,
  the *median absolute deviation* ($\operatorname{MAD}$) and
  the *Shamos estimator* (see [[Shamos1977]](#Shamos1977), p.260) are defined as follows:

$$
\operatorname{MAD}_n = C_n \cdot \operatorname{median}(|x - \operatorname{median}(x)|)
$$

$$
\operatorname{Shamos}_n = C_n \cdot \underset{i < j}{\operatorname{median}} (|x_i - x_j|)
$$

where $\operatorname{median}$ is a median estimator, $C_n$ is a scale factor.
In the scope of this post, we use the traditional sample median
  (if $n$ is odd, the median is the middle element of the sorted sample,
   if $n$ is even, the median is the arithmetic average of the two middle elements of the sorted sample).
The $C_n$ scale factors allow using $\operatorname{MAD}$ and $\operatorname{Shamos}$ consistent estimators
  for the standard deviation under the normal distribution.
The corresponding values of $C_n$ for both dispersion estimators could be found in {{< link park2020 >}}.

### Simulation study

Let's perform the following experiment:

* Enumerate different distributions:
  the standard Normal distribution (light-tailed),
  the standard Gumbel distribution (light-tailed),
  the standard Cauchy distribution (heavy-tailed),
  the Frechet distribution with shape = 1 (heavy-tailed),
  and the Weibull distribution with shape = 0.5 (heavy-tailed.)
* Enumerate different sample sizes: 5, 10, 20.
* For each combination of the parameters,
    we generate $10\,000$ random samples from the given distribution of the given size,
    and calculate the $\operatorname{MAD}$ and $\operatorname{Shamos}$ estimations.
  For each group of estimations, we draw a density plot (the Sheather & Jones method, the normal kernel)
    and calculate some summary statistics: the mean, the median, the standard deviation (SD),
    the interquartile range (IQR), the $99^\textrm{th}$ percentile (P99).

Let's start with the Normal distribution:

{{< imgld normal-5 >}}
{{< imgld normal-10 >}}
{{< imgld normal-20 >}}

As we can see from the plots, $\operatorname{Shamos}$ has higher statistical efficiency than $\operatorname{MAD}$.
Also, thanks to the $C_n$ scale factors from {{< link park2020 >}},
  the expected value of both estimators is $1$, which makes them a robust replacement
  for the unbiased standard deviation.

Now let's look at the results for the light-tailed Gumbel distribution:

{{< imgld gumbel-5 >}}
{{< imgld gumbel-10 >}}
{{< imgld gumbel-20 >}}

$\operatorname{Shamos}$ still looks better than $\operatorname{MAD}$ because its density plot is more narrow.

Next, let's consider the heavy-tailed Cauchy distribution (which has infinity variance):

{{< imgld cauchy-5 >}}
{{< imgld cauchy-10 >}}
{{< imgld cauchy-20 >}}

Here we can see that $\operatorname{MAD}$ shows better robustness than $\operatorname{Shamos}$
  (because it has a higher breakdown point).
Similar results could be observed for heavy-tailed Frechet and Weibull distributions:

{{< imgld frechet-5 >}}
{{< imgld frechet-10 >}}
{{< imgld frechet-20 >}}
{{< imgld weibull-5 >}}
{{< imgld weibull-10 >}}
{{< imgld weibull-20 >}}

### Conclusion

Under normality, $\operatorname{Shamos}$ has better statistical efficiency than $\operatorname{MAD}$
  if we consider these estimators as consistent estimators for the standard deviation.
On other light-tailed distributions, $\operatorname{Shamos}$ also has smaller dispersion than $\operatorname{MAD}$.

However, in the case of heavy-tailed distributions, $\operatorname{MAD}$ is the preferable option
  because it has a higher breakdown point and better resistance to outliers than $\operatorname{Shamos}$.
Since we typically use robust measures of scales when we expect to have some extreme outliers,
  $\operatorname{MAD}$ looks like a more reasonable measure of dispersion than $\operatorname{Shamos}$.

### References

* <b id="Shamos1977">[Shamos1977]</b>  
  Shamos, Michael Ian. "Geometry and Statistics: Problems at the Interface." In Algorithms and Complexity. 1977.  
* <b id="Park2020">[Park2020]</b>  
  Park, Chanseok, Haewon Kim, and Min Wang.
  "Investigation of finite-sample properties of robust location and scale estimators."
  Communications in Statistics-Simulation and Computation (2020): 1-27.  
  https://doi.org/10.1080/03610918.2019.1699114
