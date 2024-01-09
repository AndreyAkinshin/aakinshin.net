---
title: The expected number of takes from a discrete distribution before observing the given element
date: 2022-06-21
tags:
- mathematics
- statistics
- case-study
features:
- math
---

Let's consider a discrete distribution $X$ defined by its probability mass function $p_X(x)$.
We randomly take elements from $X$ until we observe the given element $x_0$.
What's the expected number of takes in this process?

This classic statistical problem could be solved in various ways.
I would like to share one of my favorite approaches that involves the derivative of the series
  $\sum_{n=0}^\infty x^n$.

<!--more-->

Let's denote the result (the expected number of takes) as $K$
  and the probability $p_X(x_0)$ of observing $x_0$ as $\alpha$.
First of all, let's write down the straightforward equation for $K$.
The probability of observing $x_0$ after the first take is just $\alpha$.
The probability of observing $x_0$ after the second take is $\alpha(1-\alpha)$.
The probability of observing $x_0$ after the third take is $\alpha(1-\alpha)^2$.
Continuing this process, we have

$$
K = 1 \cdot \alpha + 2 \cdot \alpha(1-\alpha) + 3 \cdot \alpha(1-\alpha)^2 + 4 \cdot \alpha(1-\alpha)^3 + \ldots =
  \alpha \sum_{n=0}^\infty n (1-\alpha)^{n-1}.
$$

Now consider the following series:

$$
S(y) = \sum_{n=0} y^n.
$$

It's easy to see that

$$
S(y) = \sum_{n=0}^\infty y^n =
  1 + \sum_{n=1}^\infty y^n =
  1 + y \cdot \sum_{n=1}^\infty y^{n-1} =
  1 + y \cdot \sum_{n=0}^\infty y^n =
  1 + y \cdot S(y).
$$

Solving $S(y) = 1 + y \cdot S(y)$, we get

$$
\sum_{n=0}^\infty y^n = S(y) = \frac{1}{1-y}.
$$

By taking the derivative of both sides of this expression, we get

$$
\sum_{n=0}^\infty n \cdot y^{n-1} = \frac{1}{(1-y)^2}.
$$

Putting $y = 1-\alpha$, we get

$$
K = \alpha \sum_{n_0}^\infty n \cdot y^{n-1} =
  \alpha \frac{1}{(1-y)^2} = \alpha \frac{1}{\alpha^2} = \frac{1}{\alpha}.
$$

Thus, we get the answer:

$$
K = \frac{1}{p_X(x_0)}.
$$
