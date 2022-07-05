---
title: Untied quantile absolute deviation
date: 2022-07-05
tags:
- Statistics
features:
- math
---

In the previous posts, I tried to adapt the concept of the [quantile absolute deviation]({{< ref qad >}})
  to samples with tied values so that this measure of dispersion never becomes zero for nondegenerate ranges.
My previous attempt was the *middle non-zero quantile absolute deviation*
  ([modification 1]({{< ref mnzqad >}}), [modification 2]({{< ref mnzqad2 >}})).
However, I'm not completely satisfied with the behavior of this metric.
In this post, I want to consider another way to work around the problem with tied values.

<!--more-->

### Untied quantile absolute deviation

First of all, let's recall the definition of the simple quantile absolute deviation $\operatorname{QAD}$:

$$
\operatorname{QAD}(x, p, q) = \operatorname{Q}(|x - \operatorname{Q}(x, p)|, q),
$$

where $\operatorname{Q}(x, p)$ is the estimation of the $p^\textrm{th}$ quantile for the given sample $x$.

The most popular example of $\operatorname{QAD}$ is the median absolute deviation $\operatorname{MAD}$:

$$
\operatorname{MAD}(x) = \operatorname{QAD}(x, 0.5, 0.5) = \operatorname{median}(|x - \operatorname{median}(x)|).
$$

We may have a problem when more than half of the sample elements are the same.
In this case, $\operatorname{MAD}$ becomes zero regardless of the other values.
For example,

$$
\operatorname{MAD}(\{ 1, 1, 1, 10, 20 \}) = 0.
$$

To work around this problem, let's introduce an operator $\operatorname{U}$ that removes all duplicated values
  from the given sample.
For example,

$$
\operatorname{U}(\{ 1, 1, 1, 10, 20 \}) = \{ 1, 10, 20 \},
$$

$$
\operatorname{U}(\{ 1, 1, 1, 1, 1, 2, 2, 4, 7, 7 \}) = \{ 1, 2, 4, 7 \}.
$$

Now, let's define the *untied quantile absolute deviation* $\operatorname{UQAD}$ as follows:

$$
\operatorname{UQAD}(x, p, q) = \operatorname{Q}(\operatorname{U}(|x - \operatorname{Q}(x, p)|), q).
$$

Similarly, we can define the *untied median absolute deviation* $\operatorname{UMAD}$:

$$
\operatorname{UMAD}(x) = \operatorname{UQAD}(x, 0.5, 0.5) =
  \operatorname{median}(\operatorname{U}(|x - \operatorname{median}(x)|)).
$$

It's easy to see that this approach resolves the problem:

$$
\operatorname{UMAD}(\{ 1, 1, 1, 10, 20 \}) =
  \operatorname{median}(\operatorname{U}(|\{ 1, 1, 1, 10, 20 \} - 1|)) =
  \operatorname{median}(\operatorname{U}(|\{ 0, 0, 0, 9, 19 \}|)) =
  \operatorname{median}(\{ 0, 9, 19 \}) = 9.
$$

### UQAD problems

While $\operatorname{UQAD}$ solves the problem with zero dispersion on some samples, it brings other problems.
Let's consider the two following samples:

$$
x_1 = \{ 1, 1, 1, 2, 2, 3, 4, 4, 5, 5, 5 \},
$$

$$
x_2 = \{ 1, 2, 2, 3, 3, 3, 4, 4, 5 \}.
$$

While we may expect that the dispersion of $x_1$ should be larger than the dispersion of $x_2$,
  we have $\operatorname{UMAD}(x_1) = \operatorname{UMAD}(x_2) = 1$.
In this particular case, my [second modification]({{< ref mnzqad2 >}}) of $\operatorname{MNZQAD}$ has the same problem:
  $\operatorname{MNZQAD}(x_1) = \operatorname{MNZQAD}(x_2) = 2$.

While the $\operatorname{UQAD}$ approach could be useful in some cases,
  I'm still not satisfied with its behavior in the general case.
An additional investigation of possible options is required.