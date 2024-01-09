---
title: Expected value of the minimum of two standard half-normal distributions
date: 2022-05-03
tags:
- mathematics
- statistics
- case-study
features:
- math
---

Let $X_1, X_2$ be [i.i.d.](https://en.wikipedia.org/wiki/Independent_and_identically_distributed_random_variables)
  random variables that follow the standard normal distribution $\mathcal{N}(0,1^2)$.
One day I wondered, what is the expected value of $Z = \min(|X_1|, |X_2|)$?
It turned out to be a fun exercise.
Let's solve it together!

<!--more-->

Let's denote the absolute values of $X_1, X_2$ as $Y_1, Y_2$:

$$
Y_1=|X_1|, \quad Y_2=|X_2|.
$$

Thus, $Y_1$, $Y_2$ follow
  the standard [half-normal distribution](https://en.wikipedia.org/wiki/Half-normal_distribution).
The [CDF](https://en.wikipedia.org/wiki/Cumulative_distribution_function) of this distribution is well known:

$$
F_Y(y) = \operatorname{erf}\bigg( \frac{y}{\sqrt{2}} \bigg), \quad \textrm{for}\,\,\, y\geq 0,
$$

where $\operatorname{erf}$ is the [error function](https://en.wikipedia.org/wiki/Error_function).
Let $\Phi$ be the CDF of the standard normal distribution:

$$
F_X(x) = \Phi(x) = \frac{1}{2} \Bigg( 1 + \operatorname{erf} \bigg( \frac{x}{\sqrt{2}} \bigg) \Bigg).
$$

Let also $\phi$ be the PDF of the standard normal distribution:

$$
\phi(x) = \Phi'(x) = \frac{1}{\sqrt{2\pi}}e^{-x^2/2}
$$

It's easy to see that

$$
F_Y(y) = 2\Phi(y)-1.
$$

Suppose $U, V$ are independent random variables with CDFs $F_U$ and $F_V$, $W = \min(U,V)$.
Let's express the CDF $F_W$ of $W$ via $F_U$ and $F_W$:

$$
\begin{split}
F_W(w) & =
  \mathbb{P}(W \leq w) =
  1 - \mathbb{P}(W > w) =
  1 - \mathbb{P}(\min(U, V) > w) =
  1 - \mathbb{P}(U > w, V > w) = \\
  & = 1 - \mathbb{P}(U > w)\cdot \mathbb{P}(V > w) =
  1 - (1-F_U(w))(1-F_V(w)) = \\
  & = F_U(w) + F_V(w) - F_U(w)F_V(w).
\end{split}
$$

Now let's apply this rule to $F_Z$:

$$
F_Z(z) = 2F_Y(z) - F_Y^2(z) = 2(2\Phi(z) - 1) - (2\Phi(z) - 1)^2 = -4\Phi^2(z)+8\Phi(z)-3.
$$

Now we can calculate the PDF of $Z$:

$$
f_Z(z) = F_Z'(z) = (-4\Phi^2(z)+8\Phi(z)-3)' = -8\phi(z)\Phi(z)+8\phi(z) = 8\phi(z) (1-\Phi(z)).
$$

Since $Y = |X|\geq 0$, the expected value of $Z$ is a definite integral from $0$ to $\infty$ of $xf_Z(x)dx$:

$$
\mathbb{E}(Z) =
  \int_0^\infty xf_Z(x)dx = 
  \int_0^\infty 8x \phi(z) (1-\Phi(z))dx
$$

First of all, let's calculate the indefinite integral of this expression:

$$
\begin{split}
\int 8x \phi(z) (1-\Phi(z))dx & =
  \int 8x \frac{1}{\sqrt{2\pi}}e^{-x^2/2} (1 - \frac{1}{2}(1+\operatorname{erf}(x/\sqrt{2}))dx =\\
  & = \int -2\sqrt{\frac{2}{\pi}} x e^{-x^2/2} (\operatorname{erf}(x/\sqrt{2})-1)dx =\\
  & = \int -2\sqrt{\frac{2}{\pi}} \bigg( 2\frac{e^{-x^2}}{\sqrt{2\pi}} + xe^{-x^2/2}(\operatorname{erf}(x/\sqrt{2})-1) - 2\frac{e^{-x^2}}{\sqrt{2\pi}} \bigg)dx =\\
  & = \int -2\sqrt{\frac{2}{\pi}} \bigg( 2\frac{e^{-x^2}}{\sqrt{2\pi}} - \Big( -xe^{-x^2/2}(\operatorname{erf}(x/\sqrt{2})-1) + e^{-x^2/2}\frac{1}{\sqrt{2}} \frac{2}{\sqrt{\pi}} e^{-x^2/2} \Big) \bigg)dx =\\
  & = \int -2\sqrt{\frac{2}{\pi}} \bigg( \Big(\frac{\operatorname{erf}(x)}{\sqrt{2}} \Big)' - \Big( e^{-x^2/2} (\operatorname{erf}(x/\sqrt{2})-1) \Big)' \bigg)dx =\\
  & = \int \bigg( -2\sqrt{\frac{2}{\pi}} \Big( \frac{\operatorname{erf}(x)}{\sqrt{2}} - e^{-x^2/2}(\operatorname{erf}(x/\sqrt{2})-1) \Big) \bigg)'dx =\\
  & = -2\sqrt{\frac{2}{\pi}} \Big( \frac{\operatorname{erf}(x)}{\sqrt{2}} - e^{-x^2/2}(\operatorname{erf}(x/\sqrt{2})-1) \Big).
\end{split}
$$

Now we are ready to finish the calculation of $\mathbb{E}(Z)$:

$$
\begin{split}
\mathbb{E}(Z) & = \int_0^\infty 8x \phi(z) (1-\Phi(z))dx =\\
  & = -2\sqrt{\frac{2}{\pi}} \Big( \frac{\operatorname{erf}(x)}{\sqrt{2}} - e^{-x^2/2}(\operatorname{erf}(x/\sqrt{2})-1) \Big) \Bigg|_0^\infty =\\
  & = -2\sqrt{\frac{2}{\pi}} \bigg( \frac{1}{\sqrt{2}} - 0 \bigg) - \Bigg( -2\sqrt{\frac{2}{\pi}} \bigg( 0 -e^0 (-1) \bigg) \Bigg) =\\
  & = -\frac{2}{\sqrt{\pi}} + \frac{2}{\sqrt{\pi}} \sqrt{2}
  = \frac{2(\sqrt{2}-1)}{\sqrt{\pi}} \approx 0.467389954510218.
\end{split}
$$

Hooray, we have solved the initial problem:

$$
\mathbb{E}(\min(X_1, X_2)) = \frac{2(\sqrt{2}-1)}{\sqrt{\pi}} \approx 0.467389954510218.
$$

We can check the correctness of this result using the following R script
  that uses a Monte-Carlo simulation to evaluate the first three digits after the decimal point of the result:

```r
set.seed(42)
round(mean(pmin(abs(rnorm(100000000)), abs(rnorm(100000000)))), 3)
# 0.467
```