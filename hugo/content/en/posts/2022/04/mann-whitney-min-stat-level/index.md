---
title: Minimum meaningful statistical level for the Mann–Whitney U test
date: 2022-04-12
tags:
- mathematics
- statistics
- research
- mann-whitney
features:
- math
---

The [Mann–Whitney U test](https://en.wikipedia.org/wiki/Mann%E2%80%93Whitney_U_test) is one of the most popular
  nonparametric null hypothesis significance tests.
However, like any statistical test, it has limitations.
We should always carefully match them with our business requirements.
In this post, we discuss how to properly choose the statistical level for the Mann–Whitney U test on small samples.

Let's say we want to compare two samples $x = \{ x_1, x_2, \ldots, x_n \}$ and $y = \{ y_1, y_2, \ldots, y_m \}$
  using the one-sided Mann–Whitney U test.
Sometimes, we don't have an opportunity to gather enough data and we have to work with small samples.
Imagine that the size of both samples is six: $n=m=6$.
We want to set the statistical level $\alpha$ to $0.001$ (because we really don't want to get false-positive results).
Is it a valid requirement?
In fact, the minimum p-value we can observe with $n=m=6$ is $\approx 0.001082$.
Thus, with $\alpha = 0.001$, it's impossible to get a positive result.
Meanwhile, everything is correct from the technical point of view:
  since we can't get any positive results, the false positive rate is exactly zero which is less than $0.001$.
However, it's definitely not something that we want: with this setup the test becomes useless because
  it always provides negative results regardless of the input data.

This brings an important question: what is the minimum meaningful statistical level
  that we can require for the one-sided Mann–Whitney U test knowing the sample sizes?

<!--more-->

The Mann–Whitney U test is a rank-based test.
It means that it takes into account only the relative positions of the sample elements.
The worst case for this test is a situation when all elements from one sample are less (or greater)
  then all samples of the other sample.
Here is an example of such a configuration:

$$
x_1 \leq x_2 \leq \ldots \leq x_n < y_1 \leq y_2 \leq \ldots \leq y_m.
$$

Now let's assume that the null hypothesis is true and that both samples were taken from the same distribution.
What is the probability of getting the above configuration by chance?
The answer is the same as the probability of having the first $n$ elements on the first $n$ positions among
  $n+m$ elements.
Thus, the minimum p-value that we can observe is

$$
p_{\min} = \frac{1}{C_{n+m}^n} = \frac{n! \cdot m!}{(n+m)!}
$$

Here are some $p_{\min}$ values for $n,m \leq 10$:

|   |        1|        2|        3|        4|        5|        6|        7|        8|        9|       10|
|:--|--------:|--------:|--------:|--------:|--------:|--------:|--------:|--------:|--------:|--------:|
|1  | 0.500000| 0.333333| 0.250000| 0.200000| 0.166667| 0.142857| 0.125000| 0.111111| 0.100000| 0.090909|
|2  | 0.333333| 0.166667| 0.100000| 0.066667| 0.047619| 0.035714| 0.027778| 0.022222| 0.018182| 0.015152|
|3  | 0.250000| 0.100000| 0.050000| 0.028571| 0.017857| 0.011905| 0.008333| 0.006061| 0.004545| 0.003497|
|4  | 0.200000| 0.066667| 0.028571| 0.014286| 0.007937| 0.004762| 0.003030| 0.002020| 0.001399| 0.000999|
|5  | 0.166667| 0.047619| 0.017857| 0.007937| 0.003968| 0.002165| 0.001263| 0.000777| 0.000500| 0.000333|
|6  | 0.142857| 0.035714| 0.011905| 0.004762| 0.002165| 0.001082| 0.000583| 0.000333| 0.000200| 0.000125|
|7  | 0.125000| 0.027778| 0.008333| 0.003030| 0.001263| 0.000583| 0.000291| 0.000155| 0.000087| 0.000051|
|8  | 0.111111| 0.022222| 0.006061| 0.002020| 0.000777| 0.000333| 0.000155| 0.000078| 0.000041| 0.000023|
|9  | 0.100000| 0.018182| 0.004545| 0.001399| 0.000500| 0.000200| 0.000087| 0.000041| 0.000021| 0.000011|
|10 | 0.090909| 0.015152| 0.003497| 0.000999| 0.000333| 0.000125| 0.000051| 0.000023| 0.000011| 0.000005|

From this table, we can find the answer for the example from the beginning of this post.
Fo $n=m=6$, the lowest p-value we can observe is $1/C_{12}^6 \approx 0.001082$.
If we set the statistical level $\alpha = 0.001$, the Mann–Whitney U test will never provide a positive result.

If we want to make the use of the one-sided Mann–Whitney U test meaningful,
  we always should choose $\alpha$ which is bigger than $1/C_{n+m}^n$.