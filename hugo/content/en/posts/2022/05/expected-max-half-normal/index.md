---
title: Expected value of the maximum of two standard half-normal distributions
date: 2022-05-10
tags:
- mathematics
- statistics
- case-study
features:
- math
---

Let $X_1, X_2$ be [i.i.d.](https://en.wikipedia.org/wiki/Independent_and_identically_distributed_random_variables)
  random variables that follow the standard normal distribution $\mathcal{N}(0,1^2)$.
In the [previous post]({{< ref expected-min-half-normal >}}),
  I have found the expected value of $\min(|X_1|, |X_2|)$.
Now it's time to find the value of $Z = \max(|X_1|, |X_2|)$.

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

Suppose $U, V$ are independent random variables with CDFs $F_U$ and $F_V$, $W = \max(U,V)$.
Let's express the CDF $F_W$ of $W$ via $F_U$ and $F_W$:

$$
\begin{split}
F_W(w) & =
  \mathbb{P}(W \leq w) =
  \mathbb{P}(\max(U, V) \leq w) =
  \mathbb{P}(U \leq w, V \leq w) = \\
  & = \mathbb{P}(U \leq w)\cdot \mathbb{P}(V \leq w) =
  F_U(w)\cdot F_V(w).
\end{split}
$$

Now let's apply this rule to $F_Z$:

$$
F_Z(z) = F_Y^2(z) = (2\Phi(z)-1)^2 = 4\Phi^2(z) - 4\Phi(z) + 1.
$$

Now we can calculate the PDF of $Z$:

$$
f_Z(z) = F_Z'(z) = (4\Phi^2(z) - 4\Phi(z) + 1)' = 8\phi(z)\Phi(z) - 4\phi(z) = 4\phi(z) (2\Phi(z) - 1).
$$

Since $Y = |X|\geq 0$, the expected value of $Z$ is a definite integral from $0$ to $\infty$ of $xf_Z(x)dx$:

$$
\mathbb{E}(Z) =
  \int_0^\infty xf_Z(x)dx = 
  \int_0^\infty 4x \phi(x) (2\Phi(x) - 1) dx
$$

First of all, let's calculate the indefinite integral of this expression:

$$
\int 4x \phi(x) (2\Phi(x) - 1) dx =
  2\sqrt{\frac{2}{\pi}} \Big( \frac{\operatorname{erf}(x)}{\sqrt{2}} - e^{-x^2/2}(\operatorname{erf}(x/\sqrt{2})) \Big).
$$

(The result is easy to derive following the trick
  that we used in the [previous post]({{< ref expected-min-half-normal >}}).)

Now we are ready to finish the calculation of $\mathbb{E}(Z)$:

$$
\begin{split}
\mathbb{E}(Z) & = \int_0^\infty 4x \phi(x) (2\Phi(x) - 1)dx =\\
  & = 2\sqrt{\frac{2}{\pi}} \Big( \frac{\operatorname{erf}(x)}{\sqrt{2}} - e^{-x^2/2}(\operatorname{erf}(x/\sqrt{2})) \Big) \Bigg|_0^\infty =\\
  = \frac{2}{\sqrt{\pi}} \approx 1.12837916709551.
\end{split}
$$

Hooray, we have solved the initial problem:

$$
\mathbb{E}(\max(X_1, X_2)) = \frac{2}{\sqrt{\pi}} \approx 1.12837916709551.
$$

We can check the correctness of this result using the following R script
  that uses a Monte-Carlo simulation to evaluate the first three digits after the decimal point of the result:

```r
set.seed(42)
round(mean(pmax(abs(rnorm(100000000)), abs(rnorm(100000000)))), 3)
# 1.128
```
