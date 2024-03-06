---
title: Unobvious problems of using the R's implementation of the Hodges-Lehmann estimator
date: 2023-05-09
tags:
- mathematics
- statistics
- research
- Hodges-Lehmann Estimator
- R
features:
- math
---

The Hodges-Lehmann location estimator (also known as pseudo-median) is a robust, non-parametric statistic
  used as a measure of the central tendency.
For a sample $\mathbf{x} = \{ x_1, x_2, \ldots, x_n \}$, it is defined as follows:

$$
\operatorname{HL}(\mathbf{x}) =
  \underset{1 \leq i \leq j \leq n}{\operatorname{median}} \left(\frac{x_i + x_j}{2} \right).
$$

Essentially, it's the median of the Walsh (pairwise) averages.

For two samples $\mathbf{x} = \{ x_1, x_2, \ldots, x_n \}$ and $\mathbf{y} = \{ y_1, y_2, \ldots, y_m \}$,
  we can also consider the Hodges-Lehmann location shift estimator:

$$
\operatorname{HL}(\mathbf{x}, \mathbf{y}) =
  \underset{1 \leq i \leq n,\,\, 1 \leq j \leq m}{\operatorname{median}} \left(x_i - y_j \right).
$$

In R, both estimators are available via
  the [wilcox.test](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/wilcox.test.html) function.
Here is a usage example:

```r
set.seed(1729)
x <- rnorm(2000, 5) # A sample of size 2000 from the normal distribution N(5, 1)
y <- rnorm(2000, 2) # A sample of size 2000 from the normal distribution N(2, 1)
wilcox.test(x, conf.int = TRUE)$estimate
# (pseudo)median
#       5.000984
wilcox.test(y, conf.int = TRUE)$estimate
# (pseudo)median
#       1.969096
wilcox.test(x, y, conf.int = TRUE)$estimate
# difference in location
#               3.031782
```

In most cases, this function works fine.
However, there is an unobvious corner case, in which it returns wrong values.
In this post, we discuss the underlying problem and provide a correct implementation for the Hodges-Lehmann estimators.

<!--more-->

### Problem 1: Zero values

Let us consider the one-sample estimator for a sample that contains exactly one zero element:

```r
x <- c(0, 1, 2)
wilcox.test(x, conf.int = TRUE)$estimate
# (pseudo)median 
#            1.5 
# Warning messages:
# 1: In wilcox.test.default(x, conf.int = TRUE) :
#   requested conf.level not achievable
# 2: In wilcox.test.default(x, conf.int = TRUE) :
#   cannot compute exact p-value with zeroes
# 3: In wilcox.test.default(x, conf.int = TRUE) :
#   cannot compute exact confidence interval with zeroes
```

Obviously, for $\mathbb{x} = \{ 0, 1, 2 \}$, the correct pseudo-median value is $1$.
However, `wilcox.test` returns $1.5$ (a wrong value) and prints a set of warnings about a zero value in the sample.
The problem [can be found](https://github.com/wch/r-source/blob/tags/R-4-3-0/src/library/stats/R/wilcox.test.R#L65)
  in the source of `wilcox.test`:

```r
ZEROES <- any(x == 0)
if(ZEROES)
    x <- x[x != 0]
```

For the one-sample case, `wilcox.test` removes all zero elements from the sample.
This logic is needed to properly perform the Wilcoxon rank-sum test
  (also known as the [Mann–Whitney U test](https://en.wikipedia.org/wiki/Mann%E2%80%93Whitney_U_test)).
The Hodges-Lehmann estimation is an additional feature of this function.
Unfortunately, this feature is affected by this cleanup of zero values.
Therefore, it actually estimated the pseudo-median
  not for $\mathbf{x} = \{ 0, 1, 2 \}$, but for $\mathbf{x}' = \{ 1, 2 \}$ (which is $1.5$).

### Problem 2: Tied values (one sample)

Now let us consider the following sample of four elements with a tie:

$$
\mathbf{x} = \{ -2.12984, -2.12984, 1.1479, -0.4895 \}.
$$

The true value of the Hodges-Lehmann location estimator is given by:

$$
\begin{align}
\operatorname{HL}(\mathbf{x}) & =
  \underset{1 \leq i \leq j \leq n}{\operatorname{median}} \left(\frac{x_i + x_j}{2} \right) = \\
  & = \Bigl(\operatorname{median} \left\{ x_1 + x_1,\, x_1 + x_2,\, x_1 + x_3,\, x_1 + x_4,\, x_2 + x_2,\,
      x_2 + x_3,\, x_2 + x_4,\, x_3 + x_3,\, x_3 + x_4,\, x_4 + x_4 \right\} \Bigr) / 2 = \\
  & = \Bigl(\operatorname{median} \left\{ -4.25968, -4.25968, -0.98194, -2.61934, -4.25968, -0.98194, 
-2.61934, 2.2958, 0.6584, -0.979 \right\} \Bigr) / 2 = \\
  & = -0.90032.
\end{align}
$$

Now let us look at the calculated result by `wilcox.test`:

```r
x <- c(-2.12984, -2.12984, 1.1479, -0.4895)
wilcox.test(x, conf.int = TRUE)$estimate
# (pseudo)median 
#     -0.6514901 
# Warning messages:
# 1: In wilcox.test.default(x, conf.int = TRUE) :
#   requested conf.level not achievable
# 2: In wilcox.test.default(x, conf.int = TRUE) :
#   cannot compute exact p-value with ties
# 3: In wilcox.test.default(x, conf.int = TRUE) :
#   cannot compute exact confidence interval with ties
```

As we can see, the returned value of $-0.6514901$ significantly differs from the expected value of $-0.90032$.
When the sample contains tied values, `wilcox.test` [switched]({{< ref r-mann-whitney-incorrect-p-value>}})
  from the exact implementation of Wilcoxon rank-sum test to the approximated one.
As a side effect, it also uses a peculiar approximation of the Hodges-Lehmann estimator
  that leads to another pseudo-median estimation that differs from the explicit equation.

### Problem 3: Tied values (two samples)

When we estimate the location shift between two samples, tied values are also an issue.
Let us consider the following samples:

$$
\mathbf{x} = \{ 1.5274454801712, 1.5274454801712, 0.3 \},
$$

$$
\mathbf{y} = \{ 3.3, -1.72972619537396 \}.
$$

The expected value of $\operatorname{HL}(\mathbf{x}, \mathbf{y})$ is $\approx 0.1285858$.
Now let us check the output of `wilcox.test`:

```r
x <- c(1.5274454801712, 1.5274454801712, 0.3)
y <- c(3.3, -1.72972619537396)
wilcox.test(x, y, conf.int = TRUE)$estimate
# difference in location
#               1.503729
```

We have $\approx 0.1285858$ vs. $\approx 1.503729$.
It is a huge difference!
The underlying problem is the same as the previous one: existing of tied values forces `wilcox.test` to switch
  to the approximated algorithm that returns strange results.

### Problem 4: Degenerate samples

When sample ranges are degenerate ($\min(x) = \max(x)$, $\min(y) = \max(y)$),
  we get a corner case that is not supported in `wilcox.test`:

```r
x <- c(2, 2)
y <- c(1, 1)
wilcox.test(x, y, conf.int = TRUE)$estimate
# Error in if (f.lower <= 0) return(mumin) : 
#   missing value where TRUE/FALSE needed
# In addition: Warning messages:
# 1: cannot compute confidence interval when all observations are tied 
# 2: cannot compute confidence interval when all observations are tied 
```

While the actual value of $\operatorname{HL}(\mathbf{x}, \mathbf{y})$ is obviously $1$,
  `wilcox.test` fails to provide any result.

### The correct implementation

Given the problems discussed above,
  I recommend against using `wilcox.test` for Hodges-Lehmann estimations due to its numerous corner cases
Instead, I suggest the following simple and reliable implementation that supports all the discussed scenarios:

```r
hl <- function(x, y = NULL) {
  if (is.null(y)) {
    walsh <- outer(x, x, "+") / 2
    median(walsh[lower.tri(walsh, diag = TRUE)])
  } else {
    median(outer(x, y, "-"))
  }
}
```

Let us check that it works correctly:

```r
x <- c(0, 1, 2)
hl(x)
# [1] 1

x <- c(-2.12984, -2.12984, 1.1479, -0.4895)
hl(x)
# [1] -0.90032

x <- c(1.5274454801712, 1.5274454801712, 0.3)
y <- c(3.3, -1.72972619537396)
hl(x, y)
# [1] 0.1285858

x <- c(2, 2)
y <- c(1, 1)
hl(x, y)
# [1] 1
```
