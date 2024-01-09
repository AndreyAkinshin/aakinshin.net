---
title: "When Python's Mann-Whitney U test returns extremely distorted p-values"
description: "Discussing corner cases in which mannwhitneyu returns distorted p-values"
date: 2023-05-02
tags:
- mathematics
- statistics
- research
- mann-whitney
- python
---

In the [previous post]({{< ref r-mann-whitney-incorrect-p-value>}}),
  I have discussed a huge difference between p-values evaluated via the R implementation of
  the [Mann-Whitney U test](https://en.wikipedia.org/wiki/Mann%E2%80%93Whitney_U_test)
  between the exact and asymptotic implementations.
This issue is not unique only to R, it is relevant for other statistical packages in other languages as well.
In this post, we review this problem in the Python package [SciPy](https://scipy.org/).

<!--more-->

In SciPy[^1], the Mann-Whitney U test is available via the function
  [mannwhitneyu](https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.mannwhitneyu.html).
Similarly to R, it has two methods to estimate the value: the exact one and the normally approximated one.
The difference between these methods can be shown using the following [snippet](https://trinket.io/python3/204b37a1b1):

[^1]: We consider SciPy 1.10.1


```python
import numpy as np
from scipy.stats import mannwhitneyu

x = np.arange(101, 106) # n = 5
y = np.arange(1, 51)    # m = 50

print(mannwhitneyu(x, y, alternative="greater", method="exact"))
print(mannwhitneyu(x, y, alternative="greater", method="asymptotic"))
```

This code gives the following output:

```python
MannwhitneyuResult(statistic=250.0, pvalue=2.874586670369134e-07)
MannwhitneyuResult(statistic=250.0, pvalue=0.00013370277743792665)
```

The results match the situation [we observed]({{< ref r-mann-whitney-incorrect-p-value>}}) in R:
  the approximated value is 465 times larger than the exact value.

However, the default strategy for choosing between `exact` and `asymptotic` is different between R and SciPy.
In R, `wilcox.text` [uses](https://github.com/wch/r-source/blob/tags/R-4-3-0/src/library/stats/R/wilcox.test.R#L279)
  the exact strategy when `n < 50 AND m < 50` (and there are no tied values).
In SciPy, `mannwhitneyu` [uses](https://github.com/scipy/scipy/blob/v1.10.1/scipy/stats/_mannwhitneyu.py#L236)
  the exact strategy when `n <= 8 OR m <= 8` (and there are no tied values).
Therefore, SciPy switches to the `asymptotic` methods when both samples contain at least 9 elements.
Here is a [snippet](https://trinket.io/python3/acd4dac09d) that illustrates this transition:

```python
import numpy as np
from scipy.stats import mannwhitneyu

x = np.arange(101, 109) # n = 8
y = np.arange(1, 9)     # m = 8

print("n = m = 8")
print("auto:       " + str(mannwhitneyu(x, y, alternative="greater")))
print("exact:      " + str(mannwhitneyu(x, y, alternative="greater", method="exact")))
print("asymptotic: " + str(mannwhitneyu(x, y, alternative="greater", method="asymptotic")))
print("")

x = np.arange(101, 110) # n = 9
y = np.arange(1, 10)    # m = 9

print("n = m = 9")
print("auto:       " + str(mannwhitneyu(x, y, alternative="greater")))
print("exact:      " + str(mannwhitneyu(x, y, alternative="greater", method="exact")))
print("asymptotic: " + str(mannwhitneyu(x, y, alternative="greater", method="asymptotic")))
```

Here is the corresponding output:

```python
n = m = 8
auto:       MannwhitneyuResult(statistic=64.0, pvalue=7.77000777000777e-05)
exact:      MannwhitneyuResult(statistic=64.0, pvalue=7.77000777000777e-05)
asymptotic: MannwhitneyuResult(statistic=64.0, pvalue=0.00046955284955859495)

n = m = 9
auto:       MannwhitneyuResult(statistic=81.0, pvalue=0.00020614740103084563)
exact:      MannwhitneyuResult(statistic=81.0, pvalue=2.0567667626491154e-05)
asymptotic: MannwhitneyuResult(statistic=81.0, pvalue=0.00020614740103084563)
```

Thus, we should be careful when using `mannwhitneyu` from SciPy:
  the `asymptotic` method is enabled by default even for relatively small samples
  which can lead to significant errors in p-value evaluation for extreme values of the U statistic.