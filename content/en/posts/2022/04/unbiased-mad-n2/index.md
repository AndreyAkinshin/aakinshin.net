---
title: Unbiased median absolute deviation for n=2
date: 2022-04-26
tags:
- Statistics
features:
- math
---

I already covered the topic of the unbiased median deviation based on
  [the traditional sample median]({{< ref unbiased-mad >}}),
  [the Harrell-Davis quantile estimator]({{< ref unbiased-mad-hd >}}), and
  [the trimmed Harrell-Davis quantile estimator]({{< ref unbiased-mad-thd >}}).
In all the posts, the values of bias-correction factors were evaluated using the Monte-Carlo simulation.
In this post, we calculate the exact value of the bias-correction factor for two-element samples.

<!--more-->

Let $X = \{ X_1, X_2 \}$ be a sample of two random variables
  from the standard normal distribution $\mathcal{N}(0, 1^2)$.
Regardless of the chosen median estimator, the median is unequivocally determined:

$$
\operatorname{median}(X) = \dfrac{X_1 + X_2}{2}.
$$

Now let's calculate the median absolute deviation $\operatorname{MAD}$:

$$
\begin{split}
\operatorname{MAD}(X)
  & = \operatorname{median}(|X - \operatorname{median}(X)|) = \\
  & = \operatorname{median}(\{ \, |X_1 - (X_1 + X_2)/2|\,,\, |X_2 - (X_1 + X_2)/2|\, \}) = \\
  & = \operatorname{median}(\{ \, |(X_1 - X_2)/2|\,,\, |(X_2 - X_1)/2| \,\}) = \\
  & = |X_1 - X_2|/2.
\end{split}
$$

Since $X_1, X_2 \sim \mathcal{N}(0, 1^2)$ which is symmetrical,
  $|X_1 - X_2|/2$ is distributed the same was as $|X_1 + X_2|/2$.
Let's denote the sum of two standard normal distributions as $Z = X_1 + X_2$.
It gives us another normal distribution with modified variance:

$$
Z \sim \mathcal{N}(0, \sqrt{2}^2).
$$

Since we take the absolute value of $Z$, we get the half-normal distribution.
The expected value of a half-normal distribution formed from the normal distribution $\mathcal{N}(0, \sigma^2)$
  is $\sigma \sqrt{2/\pi}$.
Thus,

$$
\mathbb{E}(|Z|) = \sqrt{2} \sqrt{2/\pi} = 2/\sqrt{\pi}.
$$

Finally, we have:

$$
\begin{split}
\mathbb{E}(\operatorname{MAD}(X))
  & = \mathbb{E}\Bigg( \frac{|X_1 - X_2|}{2} \Bigg)
    = \mathbb{E}\Bigg( \frac{|X_1 + X_2|}{2} \Bigg) = \\
  & = \mathbb{E}\Bigg( \frac{|Z|}{2} \Bigg)
    = \frac{2/\sqrt{\pi}}{2} = \frac{1}{\sqrt{\pi}}.
\end{split}
$$

The bias-correction factor $C_2$ for $\operatorname{MAD}(X)$ is the reciprocal value of its expected value:

$$
C_2 = \frac{1}{\mathbb{E}(\operatorname{MAD}(X))} = \sqrt{\pi} \approx 1.77245385090552.
$$
