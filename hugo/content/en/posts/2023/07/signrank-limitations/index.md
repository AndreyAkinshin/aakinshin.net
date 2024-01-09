---
title: Unobvious limitations of R *signrank Wilcoxon Signed Rank functions
date: 2023-07-11
tags:
- mathematics
- statistics
- research
- R
features:
- math
---

In R, we have functions to calculate the density, distribution function, and quantile function
  of the Wilcoxon Signed Rank statistic distribution: `dsignrank`, `psignrank`, and `qsignrank`.
All the functions use exact calculations of the target functions
  (the R 4.3.1 implementation can be found [here](https://svn.r-project.org/R/tags/R-4-3-1/src/nmath/signrank.c)).
The exact approach works excellently for small sample sizes.
Unfortunately, for large sample sizes, it fails to provide the expected function values.
Out of the box, there are no alternative approximation solutions that could allow us to get reasonable results.
In this post, we investigate the limitations of these functions and
  provide sample size thresholds after which we might get invalid results.

<!--more-->

### psignrank

`psignrank` returns values of the Wilcoxon Signed Rank statistic cumulative distribution function (CDF).
It has the following signature:

```r
psignrank(q, n, lower.tail = TRUE, log.p = FALSE)
```

The Statistic value takes values between $0$ and $n(n+1)/2$.
For example, for $n=4$, the Statistic values range from $0$ to $10$:

```r
psignrank(-1:10, 4)
# [1] 0.0000 0.0625 0.1250 0.1875 0.3125 0.4375 0.5625 0.6875 0.8125 0.8750 0.9375 1.0000
```

Problems appear when $n \geq 1039$.
Let us consider $n=1039$ to illustrate this problem.
For this sample size, the Statistic values range from $0$ to $540280$.
Let us explore the `psignrank` results for some of these values using the following snippet:

```r
n <- 1039
q <- c(
  0,
  seq(230000, 262000, by = 2000),
  262633,
  262634,
  270140,
  270141,
  277645,
  277646,
  seq(278000, 310000, by = 2000),
  540280
)
cdf <- psignrank(q, n)
cbind(q, cdf)
```

Here are the results:

|      q|     cdf|      q|     cdf|
|------:|-------:|------:|-------:|
|      0| 0.00000| 270141|    -Inf|
| 230000| 0.00002| 277645|    -Inf|
| 232000| 0.00004| 277646| 0.78101|
| 234000| 0.00009| 278000| 0.79166|
| 236000| 0.00021| 280000| 0.84587|
| 238000| 0.00044| 282000| 0.88983|
| 240000| 0.00091| 284000| 0.92399|
| 242000| 0.00180| 286000| 0.94942|
| 244000| 0.00343| 288000| 0.96757|
| 246000| 0.00628| 290000| 0.97997|
| 248000| 0.01104| 292000| 0.98810|
| 250000| 0.01867| 294000| 0.99319|
| 252000| 0.03039| 296000| 0.99626|
| 254000| 0.04764| 298000| 0.99802|
| 256000| 0.07197| 300000| 0.99900|
| 258000| 0.10483| 302000| 0.99951|
| 260000| 0.14738| 304000| 0.99977|
| 262000| 0.20017| 306000| 0.99990|
| 262633| 0.21899| 308000| 0.99996|
| 262634|     Inf| 310000| 0.99998|
| 270140|     Inf| 540280| 1.00000|

If we continue exploring in-between values, we obtain four intervals in the function domain:

| q                  | cdf                  |
|-------------------:|---------------------:|
|      `[0; 262633]` | `[0.00000; 0.21899]` |
| `[262634; 270140]` | $\infty$             |
| `[270141; 277645]` | $-\infty$            |
| `[277646; 540280]` | `[0.78101; 1.00000]` |

As we can see, in the middle part of the distribution ($q \in [262634; 277645]$),
  `psignrank` returns $\pm \infty$.
For larger values of $n$, we have the same pattern: `psignrank` returns correct values only at the distribution tails.
The middle part of the distribution gives invalid values.
For $1039 \leq n \leq 1074$ these invalid values are $\pm \infty$.
Starting $n \geq 1075$, we observe `NaN`.

### dsignrank

`dsignrank` returns values of the Wilcoxon Signed Rank statistic probability density function (PDF).
It has the following signature:

```r
dsignrank(x, n, log = FALSE)
```

It works fine for $n \leq 1038$.
However, for $n \geq 1039$, we encounter issues similar to `psignrank`:

```r
n <- 1039
x <- c(262633, 262634, 277646, 277647)
dsignrank(x, n)
# [1] 0.00003051712           Inf           Inf 0.00003051712
```

For the middle part of the distribution, `dsignrank` always returns `Inf`.
The range of invalid values almost matches the corresponding range for `psignrank`.


### qsignrank

`qsignrank` returns values of the Wilcoxon Signed Rank statistic quantile function values.
It has the following signature:

```r
qsignrank(p, n, lower.tail = TRUE, log.p = FALSE)
```

It performs normally for $n \leq 1074$, but it hangs for $n \geq 1075$.
For example, the following function call never returns a result:

```r
qsignrank(0.5, 1075)
```

The hanging behavior is observed for $p \in (0; 1); n \geq 1075$.

### Conclusion

The signrank functions in R are reliable for small sample sizes,
  but they have some unobvious limitations when dealing with larger sample sizes.
If one needs values that cannot be obtained using standard functions,
  various approximation models like the normal one or the [Edgeworth expansion](mw-edgeworth2) can be considered.
