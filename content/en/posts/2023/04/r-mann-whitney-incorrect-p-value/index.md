---
title: "When R's Mann-Whitney U-test returns extremely distorted p-values"
description: "Discussing corner cases in which wilcox.test returns distorted p-values"
date: 2023-04-25
tags:
- mathematics
- statistics
- research
- mann-whitney
- R
features:
- math
---

The [Mann–Whitney U test](https://en.wikipedia.org/wiki/Mann%E2%80%93Whitney_U_test)
  (also known as the Wilcoxon rank-sum test)
  is one of the most popular nonparametric statistical tests.
In R, it can be accessed using
  the [wilcox.test](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/wilcox.test.html) function,
  which has been [available](https://github.com/wch/r-source/blob/tags/R-1-0/src/library/ctest/R/wilcox.test.R)
  since R 1.0.0 (February 2000).
With its extensive adoption and long-standing presence in R,
  the `wilcox.test` function has become a trusted tool for many researchers.
But is it truly reliable, and to what extent can we rely on its accuracy by default?

In my work,
  I often encounter the task of comparing a large sample (e.g., of size 50+) with a small sample (e.g., of size 5).
In some cases, the ranges of these samples do not overlap with each other,
  which is the extreme case of the Mann–Whitney U test: it gives the minimum possible p-value.
In [one of the previous posts]({{< ref mann-whitney-min-stat-level >}}),
  I presented the exact equation for such a p-value.
If we compare two samples of sizes $n$ and $m$,
  the minimum p-value we can observe with the one-tailed Mann–Whitney U test is $1/C_{n+m}^n$.
For example, if $n=50$ and $m=5$, we get $1/C_{55}^5 \approx 0.0000002874587$.
Let's check these calculations using R:

```r
> wilcox.test(101:105, 1:50, alternative = "greater")$p.value
[1] 0.0001337028
```

The obtained p-value is $\approx 0.0001337028$, which is $\approx 465$ times larger than we expected!
Have we discovered a critical bug in `wilcox.test`?
Can we now trust this function?
Let's find out!

<!--more-->

In fact, the `wilcox.test` has two implementations of the Mann–Whitney U test: the exact one and the approximated one.
The choice of a particular strategy is controlled by the `exact` parameter of this function.
Here is an example from the official documentation:

```r
> x <- c(0.80, 0.83, 1.89, 1.04, 1.45, 1.38, 1.91, 1.64, 0.73, 1.46)
> y <- c(1.15, 0.88, 0.90, 0.74, 1.21)
> wilcox.test(x, y, alternative = "greater", exact = TRUE)$p.value
[1] 0.1272061
> wilcox.test(x, y, alternative = "greater", exact = FALSE)$p.value
[1] 0.1223118
```

In this example, the approximation looks accurate, with a difference ofhis makes it an impra only about $5\%$.
When the `exact` parameter is not specified, it is determined
  [as follows](https://github.com/wch/r-source/blob/tags/R-4-3-0/src/library/stats/R/wilcox.test.R#L279):

```r
if(is.null(exact))
    exact <- (n.x < 50) && (n.y < 50)
```

Before we start exploring different extreme cases,
  let us briefly review both methods to estimate the p-value within this test.

The first step of the Mann–Whitney U test is calculating the U statistic:

$$
U(x, y) = \sum_{i=1}^n \sum_{j=1}^m S(x_i, y_j),\quad

S(a,b) = \begin{cases}
1,   & \text{if } a > b, \\
0.5, & \text{if } a = b, \\
0,   & \text{if } a < b.
\end{cases}
$$

It is a simple rank-based statistic, which varies from $0$ to $nm$.
Once we get the value of $U$,
  we should match it with the distribution of $U$ statistics under the valid null hypothesis.
The distribution can be obtained in two different ways:

* **The exact implementation**  
  The [straightforward implementation](https://github.com/wch/r-source/blob/tags/R-4-3-0/src/nmath/wilcox.c#L111) uses
    [dynamic programming](https://en.wikipedia.org/wiki/Dynamic_programming)
    to obtain the exact probability of obtaining the given $U$ statistic for the given $n$ and $m$.
  The only drawback of this solution is its computational complexity
    (which is $\mathcal{O}(n^2 m^2)$ for both time and memory).
  This makes this approach an impractical solution for large samples.
* **The approximated implementation**  
  Fortunately, we have a method of large sample approximation
    (see [[Hollander1973]](#Hollander1973), pages 68–75).
  Long story short, we approximate the distribution of $U$ statistics with the following normal distribution
    (in the case of tied values, a small correction is needed):

$$
\mathcal{N}\left( \frac{nm}{2},\, \frac{nm(n+m+1)}{12} \right)
$$

For the middle values of $U$ (around $nm/2$), this approximation provides reasonably accurate results.
However, it performs extremely poorly at the tails.
To illustrate the problems, we perform a simple numerical study:

* Enumerate $n$ from $1$ to $50$, set $m$ to $50$
    (since $50$ is a critical value, after which `wilcox.text` switches to the approximated algorithm);
* For each pair of $n,\, m$, we consider two non-overlapped samples
    $x = \{ 101, 102, \ldots, 100 + n \}$ and $y = \{ 1, 2, \ldots, m \}$;
* For each pair of samples $x$ and $y$, we estimate the exact and approximated p-values using `wilcox.test`
    (R [4.3.0](https://cran.r-project.org/bin/windows/base/NEWS.R-4.3.0.html)).
  We also evaluate the ratio between two obtained p-values.

This simulation can be performed using the following simple script:

```r
options(scipen = 999)
df <- expand.grid(n = 1:50, m = 50)
df$approx <- sapply(1:nrow(df), function(i) wilcox.test(101:(100+df$n[i]), 1:df$m[i], "g", exact = F)$p.value)
df$exact <-  sapply(1:nrow(df), function(i) wilcox.test(101:(100+df$n[i]), 1:df$m[i], "g", exact = T)$p.value)
df$ratio <- df$approx / df$exact
df
```

Here are the results:

|  n|  m|                     approx|                                  exact|               ratio|
|--:|--:|--------------------------:|--------------------------------------:|-------------------:|
|  1| 50| 0.048011543131958198116216| 0.019607843137254901688670827297755750|            2.448589|
|  2| 50| 0.009252304327263300917639| 0.000754147812971342414341269222433084|           12.268556|
|  3| 50| 0.002068602594726797437585| 0.000042687612054981640980627632941946|           48.459084|
|  4| 50| 0.000507425712710512176983| 0.000003162045337406047683961830482846|          160.473889|
|  5| 50| 0.000133702777437926781292| 0.000000287458667036913421002024661768|          465.120008|
|  6| 50| 0.000037419721898732403792| 0.000000030799142896812156031614014003|         1214.959846|
|  7| 50| 0.000011044391063200054742| 0.000000003782350882064650319878251473|         2919.980564|
|  8| 50| 0.000003420097224807733340| 0.000000000521703569939951803913405917|         6555.633164|
|  9| 50| 0.000001106806028706227259| 0.000000000079581900499314674285699250|        13907.760706|
| 10| 50| 0.000000373114142492364927| 0.000000000013263650083219112919478920|        28130.577944|
| 11| 50| 0.000000130667516485322913| 0.000000000002391805752711643505365161|        54631.324612|
| 12| 50| 0.000000047426982847987003| 0.000000000000462930145686124477766408|       102449.545120|
| 13| 50| 0.000000017803734950873793| 0.000000000000095525268157454267935196|       186377.230803|
| 14| 50| 0.000000006899453656698780| 0.000000000000020896152409443119138672|       330178.184075|
| 15| 50| 0.000000002755517795088092| 0.000000000000004822189017563796906354|       571424.675609|
| 16| 50| 0.000000001132420441204299| 0.000000000000001169015519409405310631|       968695.814899|
| 17| 50| 0.000000000478204516517026| 0.000000000000000296615878059102926844|      1612201.341500|
| 18| 50| 0.000000000207230566590806| 0.000000000000000078515967721527219964|      2639342.959203|
| 19| 50| 0.000000000092045404447794| 0.000000000000000021620338937811845233|      4257352.519429|
| 20| 50| 0.000000000041857100940344| 0.000000000000000006177239696517670397|      6776020.196196|
| 21| 50| 0.000000000019466963240158| 0.000000000000000001827070896153113595|     10654738.839717|
| 22| 50| 0.000000000009250432374139| 0.000000000000000000558271662713451387|     16569768.791735|
| 23| 50| 0.000000000004487040794828| 0.000000000000000000175893811539854518|     25509941.228442|
| 24| 50| 0.000000000002219810231291| 0.000000000000000000057046641580493394|     38912198.330882|
| 25| 50| 0.000000000001119116799357| 0.000000000000000000019015547193497798|     58852726.559442|
| 26| 50| 0.000000000000574519790304| 0.000000000000000000006505318776722924|     88315393.914190|
| 27| 50| 0.000000000000300116336043| 0.000000000000000000002281085804824923|    131567315.621484|
| 28| 50| 0.000000000000159415937793| 0.000000000000000000000818851314552536|    194682398.330711|
| 29| 50| 0.000000000000086049778707| 0.000000000000000000000300590988886374|    286268657.038994|
| 30| 50| 0.000000000000047171214487| 0.000000000000000000000112721620832390|    418475303.483840|
| 31| 50| 0.000000000000026245863540| 0.000000000000000000000043140373404989|    608382855.044904|
| 32| 50| 0.000000000000014813624414| 0.000000000000000000000016835267670240|    879916179.758513|
| 33| 50| 0.000000000000008477165239| 0.000000000000000000000006693540158047|   1266469616.742985|
| 34| 50| 0.000000000000004916004777| 0.000000000000000000000002709290063971|   1814499245.458048|
| 35| 50| 0.000000000000002887621675| 0.000000000000000000000001115590026341|   2588425503.078257|
| 36| 50| 0.000000000000001717269860| 0.000000000000000000000000466991173817|   3677306886.886681|
| 37| 50| 0.000000000000001033523240| 0.000000000000000000000000198605441738|   5203901920.395980|
| 38| 50| 0.000000000000000629226919| 0.000000000000000000000000085761440751|   7336944364.786281|
| 39| 50| 0.000000000000000387373398| 0.000000000000000000000000037580856059|  10307732138.774328|
| 40| 50| 0.000000000000000241060228| 0.000000000000000000000000016702602693|  14432494906.850683|
| 41| 50| 0.000000000000000151579231| 0.000000000000000000000000007525348466|  20142486658.620667|
| 42| 50| 0.000000000000000096277356| 0.000000000000000000000000003435485169|  28024384121.614346|
| 43| 50| 0.000000000000000061750057| 0.000000000000000000000000001588450132|  38874406735.166344|
| 44| 50| 0.000000000000000039980098| 0.000000000000000000000000000743529849|  53770670472.618752|
| 45| 50| 0.000000000000000026122455| 0.000000000000000000000000000352198350|  74169725522.991974|
| 46| 50| 0.000000000000000017219619| 0.000000000000000000000000000168761709| 102035109626.813110|
| 47| 50| 0.000000000000000011448630| 0.000000000000000000000000000081771137| 140008207685.065460|
| 48| 50| 0.000000000000000007675202| 0.000000000000000000000000000040051169| 191634915718.995544|
| 49| 50| 0.000000000000000005187081| 0.000000000000000000000000000019823306| 261665784427.152771|
| 50| 50| 0.000000000000000003533036| 0.000000000000000000000000000009911653| 356452748856.307617|

Thus, for $n=m=50$, the ratio between the exact (the correct one) and approximated (the default one) solutions
  is about $3.5 \cdot 10^{11}$.
Of course, both p-values are pretty small in this case.
If you are using the notorious $\alpha = 0.05$, you will most likely avoid such a problem
  (however, for $n=1,\, m = 50$, the exact true p-value is $0.0196$, while the approximated one is $0.0480$,
   whish is alarmingly close to $0.05$).
  
If you prefer using extremely low statistical significance levels
  and there are non-zero chances of getting extreme values of the $U$ statistic,
  you may consider making `exact = TRUE` your default way to call `wilcox.test`.
Such a simple trick may save you from misleading research results.

### References

* <b id="Hollander1973">[Hollander1973]</b>  
  Myles Hollander and Douglas A. Wolfe (1973)
  Nonparametric Statistical Methods.
  New York: John Wiley & Sons.
  DOI:[10.1002/9781119196037](https://dx.doi.org/10.1002/9781119196037)
