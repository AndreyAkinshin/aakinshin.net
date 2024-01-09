---
title: Corner case of the Brunner–Munzel test
date: 2023-02-21
tags:
- mathematics
- statistics
features:
- math
---

The Brunner–Munzel test is a nonparametric significance test,
  which can be considered an alternative to the Mann–Whitney U test.
However, the Brunner–Munzel test has a corner case
  that can cause some practical issues with applying this test to real data.
In this post, I briefly discuss the test itself and the corresponding corner case.

<!--more-->

### The Brunner–Munzel test

In this section, we briefly describe the equation of the Brunner–Munzel test.
We follow the approach from the original paper [[Brunner2000]](#Brunner2000)
  with slight changes in notation.

Let us consider two samples $x$ and $y$ of sizes $n$ and $m$:

$$
x = \{ x_1, x_2, \ldots, x_n \},\quad
y = \{ y_1, y_2, \ldots, y_m \}.
$$

For these samples, we define corresponding normalized empirical distribution functions:

$$
\hat{F}_x(x) = (\hat{F}_x^-(x) + \hat{F}_x^+(x))/2,\quad
\hat{F}_y(y) = (\hat{F}_y^-(y) + \hat{F}_y^+(y))/2,
$$

  where $\hat{F}^-$ and $\hat{F}^+$ are left-continuous and right-continuous empirical distribution functions.

Let $\hat{H}$ be the normalized combined empirical distribution function:

$$
\hat{H}(z) = \frac{n}{n + m} \hat{F}_x(z) + \frac{m}{n + m} \hat{F}_y(z).
$$

Next, we get the ranks for elements of $x$ and $y$ among $n+m$ values
  $\{ x_1, x_2, \ldots, x_n, y_1, y_2, \ldots, y_m \}$
  (in the case of ties, mid-ranks are used):

$$
R_{x,i} = (n + m) \hat{H}(x_i) + 0.5,\quad
R_{y,j} = (n + m) \hat{H}(y_j) + 0.5.
$$

Their mean values are given by:

$$
\overline{R}_x = \frac{1}{n} \sum_{i=1}^n R_{x,i},\quad
\overline{R}_y = \frac{1}{m} \sum_{j=1}^m R_{y,i}.
$$

We also get the ranks of $x$ and $y$ within themselves:

$$
R^*_{x,i} = n \hat{F}_x(x_i) + 0.5,\quad
R^*_{y,j} = m \hat{F}_y(y_j) + 0.5.
$$

Then, we define the following rank variances:

$$
S_x^2 = \frac{1}{n-1} \sum_{i=1}^n \Big( R_{x,i} - R^*_{x,i} - \overline{R}_x + (n+1)/2 \Big),\quad
S_y^2 = \frac{1}{m-1} \sum_{j=1}^m \Big( R_{y,j} - R^*_{y,j} - \overline{R}_y + (m+1)/2 \Big),
$$

$$
\hat{\sigma}_x^2 = \frac{S_x^2}{m^2},\quad
\hat{\sigma}_y^2 = \frac{S_y^2}{n^2}.
$$

The pooled variance is defined as follows:

$$
\hat{\sigma}^2 = (n + m) \cdot (\hat{\sigma}_x^2 / n + \hat{\sigma}_y^2 / m).
$$

Finally, the Brunner–Munzel test statistic is given by:

$$
W = \frac{\overline{R}_y - \overline{R}_x}{\hat{\sigma}\sqrt{n + m}}.
$$

This statistic follows the $t$-distribution with the degrees of freedom given by

$$
\hat{f} = \frac{\Big( S_x^2 / m + S_y^2 / n \Big)^2}{(S_x^2 / m)^2/(n-1) + (S_y^2 / n)^2/(m-1)}.
$$

### The corner case

The Brunner–Munzel test works fine when the ranges of $x$ and $y$ overlap.
The problems arise when they do not overlap.
For example, let us consider two following samples:

$$
x = \{ 1, 2, \ldots, 10 \},\quad
y = \{ 11, 12, \ldots, 20 \}.
$$

For these samples (and for any other pairs of samples with non-overlapping ranges), we have

$$
S_x^2 = S_y^2 = \hat{\sigma}_x^2 = \hat{\sigma}_y^2 = \hat{\sigma}^2 = 0.
$$

Since $\hat{\sigma}^2$ is used as the denominator to estimate the test statistic $W$,
  this statistic is not defined in the case of non-overlapping sample ranges.
Therefore, we cannot obtain a proper p-value.

How should we handle such situations?
I have found two approaches.

The first approach is implemented in package [lawstat](https://cran.r-project.org/web/packages/lawstat/index.html)
  (see function `brunner.munzel.test`).
In the case of non-overlapping sample ranges, this function returns `NA` as the p-value.
This [by-design](https://github.com/vlyubchich/lawstat/issues/1) behavior is consistent with the paper
  (the test statistic is not defined; therefore, the test can not be applied as is).
However, this approach is not convenient in practice since it forces the user to manually handle the corner case.

The second approach is implemented in package
  [brunnermunzel](https://cran.r-project.org/web/packages/brunnermunzel/vignettes/usage.html)
  (see function `brunnermunzel.test`).
This function extends the test and returns `1` or `0` as the p-value in the case of non-overlapping sample ranges.
Theoretically, this behavior may lead to the inflated false-positive rate under an extremely small significance level.
However, I doubt that it can be an actual issue with medium-size samples
  (the authors of the test do not recommend using it for small sample sizes $n,m<10$
   (see [[Brunner2000]](#Brunner2000), section 5, last paragraph)).

### References

* <b id="Brunner2000">[Brunner2000]</b>  
  Brunner, Edgar, and Ullrich Munzel.
  "The nonparametric Behrens‐Fisher problem: asymptotic theory and a small‐sample approximation."
  Biometrical Journal: Journal of Mathematical Methods in Biosciences 42, no. 1 (2000): 17-25.  
  DOI:[10.1002/(sici)1521-4036(200001)42:1<17::aid-bimj17>3.0.co;2-u ](https://doi.org/10.1002/(SICI)1521-4036(200001)42:1%3C17::AID-BIMJ17%3E3.0.CO;2-U)
