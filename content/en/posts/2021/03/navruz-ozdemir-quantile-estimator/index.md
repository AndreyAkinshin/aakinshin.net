---
title: "Navruz-Özdemir quantile estimator"
description: "A brief description of the Navruz-Özdemir quantile estimator"
date: "2021-03-16"
tags:
- mathematics
- statistics
- research
- Quantile
features:
- math
---

The Navruz-Özdemir quantile estimator
  suggests the following equation to estimate the $p^\textrm{th}$ quantile of sample $X$:

$$
\begin{split}
\operatorname{NO}_p =
& \Big( (3p-1)X_{(1)} + (2-3p)X_{(2)} - (1-p)X_{(3)} \Big) B_0 +\\
& +\sum_{i=1}^n \Big((1-p)B_{i-1}+pB_i\Big)X_{(i)} +\\
& +\Big( -pX_{(n-2)} + (3p-1)X_{(n-1)} + (2-3p)X_{(n)} \Big) B_n
\end{split}
$$

where $B_i = B(i; n, p)$ is probability mass function of the binomial distribution $B(n, p)$,
  $X_{(i)}$ are order statistics of sample $X$.

In this post, I derive these equations following the paper
  ["A new quantile estimator with weights based on a subsampling approach"](https://doi.org/10.1111/bmsp.12198) (2020)
  by Gözde Navruz and A. Fırat Özdemir.
Also, I add some additional explanations,
  simplify the final equation,
  and provide reference implementations in C# and R.

<!--more-->

### Preparation

The first steps exactly match the preparation performed for the
  [Sfakianakis-Verginis quantile estimator]({{< ref sfakianakis-verginis-quantile-estimator >}}).
Consider sample $X = \{ X_1, X_2, \ldots, X_n \}$ ($n \geq 3$).
Let $X_{(1)}, X_{(2)}, \ldots, X_{(n)}$ be the order statistics of this sample
  ($X_{(k)}$ is the $k^\textrm{th}$ smallest element).
Now let's build the following intervals:

$$
S_0 = \big(L, X_{(1)} \big),\;
S_1 = \big[X_{(1)}, X_{(2)} \big),
\ldots,
S_{n-1} = \big[X_{(n-1)},X_{n} \big),\;
S_{(n)} = \big[X_{(n)}, U \big)
$$

where $L$ and $U$ are lower and upper bounds for $X$ values ($L$ and $U$ could be equal to $-\infty$ and $\infty$).

We want to estimate $p^\textrm{th}$ quantile $Q_p$.
Obviously, $Q_p$ should belong to one of the $S_i$ intervals (because they cover all possible $Q_p$ values).
With the help of $Q_p$, we can introduce variables $\delta_i$:

$$
\delta_i =
\begin{cases}
  1 & \textrm{if}\; X_i \leq Q_p,\\
  0 & \textrm{if}\; X_i > Q_p.
\end{cases}
$$

Since $Q_p$ is the $p^\textrm{th}$ quantile,
  the probability of $(X_i \leq Q_p)$ is $p$ and
  the probability of $(X_i > Q_p)$ is $1-p$.
Thus, $\delta_i$ belongs to the [bernoulli distribution](https://en.wikipedia.org/wiki/Bernoulli_distribution):
  $\delta_i \sim \textrm{Bernoulli}(p)$.

Next, consider the sum of $\delta_i$ values:

$$
N = \delta_1 + \delta_2 + \ldots + \delta_{n-1} + \delta_n.
$$

Since $\delta_i$ are independent variables from the Bernoulli distribution,
  their sum belongs to the [binomial distribution](https://en.wikipedia.org/wiki/Binomial_distribution):
  $N \sim \textrm{Binomial(n, p)}$.
Now we can get the probability of $Q_p \in S_i$:

$$
P(Q_p \in S_i) = P(N = i) = B(i; n, p) = {n \choose k} p^k (1-p)^{(n-k)}.
$$

Let $Q'_{p,i}$ be a point estimator of $Q_p$ conditioned on the event $Q_p \in S_i$.
With the help of $Q'_{p,i}$, we could introduce a quantile estimator:

$$
Q_p \approx \operatorname{E}(Q'_p) = \sum_{i=0}^n P(Q_p \in S_i) \cdot Q'_{p,i}.
$$

### The Navruz-Özdemir quantile estimator

In [[Sfakianakis2008]](#Sfakianakis2008), Michael E. Sfakianakis and Dimitris G. Verginis described
  three options to choose $Q'_p$:

$$
\begin{split}
\operatorname{SV1}_p:\quad & Q'_{p,i} = (X_{(i)}+X_{(i+1)}) / 2\\
\operatorname{SV2}_p:\quad & Q'_{p,i} = X_{(i+1)}\\
\operatorname{SV3}_p:\quad & Q'_{p,i} = X_{(i)}\\
\end{split}
$$

Based on these assumptions, they got three different quantile estimators:

$$
\begin{split}
\operatorname{SV1}_p =&
\frac{B_0}{2} \big( X_{(1)}+X_{(2)}-X_{(3)} \big) +
\sum_{i=1}^{n} \frac{B_i+B_{i-1}}{2} X_{(i)} +
\frac{B_n}{2} \big(- X_{(n-2)}+X_{(n-1)}-X_{(n)} \big),\\
\operatorname{SV2}_p =& \sum_{i=1}^{n} B_{i-1} X_{(i)} + B_n \cdot \big(2X_{(n)} - X_{(n-1)}\big),\\
\operatorname{SV3}_p =& \sum_{i=1}^n B_i X_{(i)} + B_0 \cdot \big(2X_{(1)}-X_{(2)}\big).
\end{split}
$$

In [[Navruz2020]](#Navruz2020), Gözde Navruz and A. Fırat Özdemir suggested another way to choose $Q'_{p,i}$:

$$
\operatorname{NO}_p:\quad Q'_{p,i} = pX_{(i)} + (1-p) X_{(i+1)}
$$

Also, following [[Sfakianakis2008]](#Sfakianakis2008),
  they used the following assumptions for $Q'_{p,0}$ and $Q'_{p,n}$:

$$
Q'_{p,0}-Q'_{p,1} = Q'_{p,1} - Q'_{p,2}; \quad Q'_{p,n} - Q'_{p,n-1} = Q'_{p,n-1}-Q'_{p,n-2}.
$$

Thus, we have:

$$
\begin{split}
Q'_{p,0} = & 2Q'_{p,1} - Q'_{p,2}
&= 2pX_{(1)}+2(1-p)X_{(2)} - pX_{(2)} - (1-p)X_{(3)} \\
& &= 2pX_{(1)} + (2-3p)X_{(2)} - (1-p)X_{(3)},\\
Q'_{p,n} = & 2Q'_{p,n-1} - Q'_{p,n-2}
&= 2pX_{(n-1)}+2(1-p)X_{(n)} - pX_{(n-2)} - (1-p)X_{(n-1)}\\
& &= -pX_{(n-2)} + (3p-1)X_{(n-1)} + 2(1-p)X_{(n)}.
\end{split}
$$

Let's also denote $B(i; n, p)$ (the probability mass function os the binomial distribution $B(n, p)$) as $B_i$ to
  make the equations more readable.

Let's start to derive the equation for the Navruz-Özdemir quantile estimator.
Here is the first step:

$$
\operatorname{NO}_p =
\sum_{i=0}^n P(Q_p \in S_i) \cdot Q'_{p,i}
=B_0 Q'_{p,0} + 
\sum_{i=1}^{n-1} B_i \cdot (pX_{(i)} + (1-p)X_{(i+1)}) +
B_n Q'_{p,n}
$$

It gives us the following expression:

$$
\begin{split}
\operatorname{NO}_p = &
\big( 2pX_{(1)} + (2-3p)X_{(2)} - (1-p)X_{(3)} \big) B_0 + \\
& pX_{(1)}B_1 + (1-p)X_{(2)}B_1 + pX_{(2)}B_2 + (1-p)X_{(3)}B_2 \ldots + pX_{(n-1)}B_n + (1-p)X_{(n)}B_n +\\
& \big( -pX_{(n-2)} + (3p-1)X_{(n-1)} + 2(1-p)X_{(n)} \big) B_n
\end{split}
$$

By regrouping the equation members, we get the final equation:

$$
\begin{split}
\operatorname{NO}_p =
& \Big( (3p-1)X_{(1)} + (2-3p)X_{(2)} - (1-p)X_{(3)} \Big) B_0 +\\
& +\sum_{i=1}^n \Big((1-p)B_{i-1}+pB_i\Big)X_{(i)} +\\
& +\Big( -pX_{(n-2)} + (3p-1)X_{(n-1)} + (2-3p)X_{(n)} \Big) B_n
\end{split}
$$

In [[Navruz2020]](#Navruz2020), the estimator has slightly different representation:

$$
\begin{split}
NO_q = &
  \big(B(0;n,q)2q + B(1;n,q)q\big)X_{(1)} +
  B(0;n,q)(2-3q)X_{(2)} -
  B(0;n,q)(1-q)X_{(3)} \\
  & + \sum_{i=1}^{n-2} \big( B(i;n,q)(1-q) + B(i+1;n,q)q \big) X_{(i+1)} -
  B(n;n,q)qX_{(n-2)} \\
  & + B(n;n,q)(3q-1)X_{(n-1)} +
  \big(B(n-1;n,q)(1-q)+B(n;n,q)(2-2q)\big)X_{(n)}.
\end{split}
$$

### Reference implementation

If you use R, here is the function that you can use in your scripts:

{{< src noquantile.R >}}

If you use C#, you can take an implementation from
  the latest nightly version (0.3.0-nightly.90+) of [Perfolizer](https://github.com/AndreyAkinshin/perfolizer)
  (you need `NavruzOzdemirQuantileEstimator`).

### References

* <b id="Sfakianakis2008">[Sfakianakis2008]</b>  
  Sfakianakis, Michael E., and Dimitris G. Verginis. "A new family of nonparametric quantile estimators."
  Communications in Statistics—Simulation and Computation® 37, no. 2 (2008): 337-345.  
  https://doi.org/10.1080/03610910701790491
* <b id="Navruz2020">[Navruz2020]</b>  
  Navruz, Gözde, and A. Fırat Özdemir. "A new quantile estimator with weights based on a subsampling approach."
  British Journal of Mathematical and Statistical Psychology 73, no. 3 (2020): 506-521.  
  https://doi.org/10.1111/bmsp.12198