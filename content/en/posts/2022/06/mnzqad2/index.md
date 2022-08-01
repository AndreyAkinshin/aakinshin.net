---
title: Middle non-zero quantile absolute deviation, Part 2
date: 2022-06-28
tags:
- Statistics
- research-qad
features:
- math
---

In one of the previous posts, I [described]({{< ref mnzqad >}}) the idea of the
  middle non-zero quantile absolute deviation.
It's defined as follows:

$$
\operatorname{MNZQAD}(x, p) = \operatorname{QAD}(x, p, q_m),
$$

$$
q_m = \frac{q_0 + 1}{2}, \quad
q_0 = \frac{\max(k - 1, 0)}{n - 1}, \quad
k = \sum_{i=1}^n \mathbf{1}_{Q(x, p)}(x_i),
$$

where $\mathbf{1}$ is the indicator function

$$
\mathbf{1}_U(u) = \begin{cases}
1 & \textrm{if}\quad  u = U,\\
0 & \textrm{if}\quad  u \neq U,
\end{cases}
$$

and $\operatorname{QAD}$ is the [quantile absolute deviation]({{< ref qad >}})

$$
\operatorname{QAD}(x, p, q) = Q(|x - Q(x, p)|, q).
$$

The $\operatorname{MNZQAD}$ approach tries to work around a problem with tied values.
While it works well in the generic case, there are some corner cases
  where the suggested metric behaves poorly.
In this post, we discuss this problem and how to solve it.

<!--more-->

### The problem

Let's take 20 samples of size 1000 from the
  [rectified Gaussian distribution](https://en.wikipedia.org/wiki/Rectified_Gaussian_distribution)
  and calculate $\operatorname{MNZQAD}$ around the median for each of them.
It could be done using the following R snippet:

{{< src mnzqad1.R >}}

And here is the result:

```txt
0.6708304 0.0626490 0.6283213 0.6484299 0.0139355
0.6640861 0.0068413 0.0229421 0.5961456 0.6814358
0.6744908 0.6451489 0.6804007 0.0602365 0.7027132
0.6503397 0.0025354 0.0349211 0.0158567 0.0105813
```

As we can see, the results are not stable.
Sometimes we have small values (like 0.007), and sometimes we have large values (like 0.703).
The underlying problem is quite simple.
If the number of zero values in the sample is larger than 500,
  the median is exactly zero,
  and the number of median-tied values $k$ is around 500.
It leads to evaluating the $0.75^\textrm{th}$ quantile ($q_m \approx 0.75$).
If the number of zero values in the sample is smaller than 500,
  the median is non-zero,
  and the number of median-tied values $k$ is zero.
It leads to evaluating the $0.50^\textrm{th}$ quantile ($q_m \approx 0.50$).

### The solution

One of the ideas I have is about counting the total number of tied values in the sample
  instead of only median-tied values.
It makes $k$ much more stable in corner cases like the one above.
Here is the updated R snippet:

{{< src mnzqad2.R >}}

And here is the updated result:

```txt
0.6708304 0.6329019 0.6283213 0.6484299 0.7578973
0.6640861 0.6207138 0.6284881 0.5961456 0.6814358
0.6744908 0.6451489 0.6804007 0.6067494 0.7027132
0.6503397 0.6441379 0.6970224 0.6400928 0.6438555
```

As we can see, the new version of $\operatorname{MNZQAD}$ is much more stable
  than the originally proposed version.