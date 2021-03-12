---
title: "Sfakianakis-Verginis quantile estimator"
description: "A brief description of the Sfakianakis-Verginis quantile estimator"
date: "2021-03-09"
tags:
- Statistics
- Quantile
features:
- math
---

There are dozens of different ways to estimate quantiles.
One of these ways is to use the Sfakianakis-Verginis quantile estimator.
To be more specific, it's a family of three estimators.
If we want to estimate the $p^\textrm{th}$ quantile for sample $X$,
  we can use one of the following equations:

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

where $B_i = B(i; n, p)$ is probability mass function os the binomial distribution $B(n, p)$,
  $X_{(i)}$ are order statistics of the sample $X$.

In this post, I derive these equations following the paper
  ["A new family of nonparametric quantile estimators"](https://doi.org/10.1080/03610910701790491)
  by Michael E. Sfakianakis and Dimitris G. Verginis.
Also, I add some additional explanations,
  reconstruct missing steps,
  simplify the final equations,
  and provide reference implementations in C# and R.

<!--more-->

### Preparation

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

{{< img segments >}}

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
With the help of $Q'_{p,i}$, we could introduce the Sfakianakis-Verginis quantile estimator:

$$
\operatorname{SV}_p = \operatorname{E}(Q'_p) = \sum_{i=0}^n P(Q_p \in S_i) \cdot Q'_{p,i}.
$$

There are three variations of the Sfakianakis-Verginis quantile estimator depending on the definition of $Q'_{p,i}$.

### SV1

The first approach assumes that the $p^\textrm{th}$ quantile is in the middle of the $i^\textrm{th}$ segment:

$$
Q'_{p,i} = \frac{X_{(i)}+X_{(i+1)}}{2}\quad \textrm{for}\;\; i=1..n-1.
$$

If we don't know values of $L$ and $U$, we need a way to define $Q'_{p,i}$ for $i=0$ and $i=n$.
The author suggests using these assumptions:

$$
Q'_{p,0}-Q'_{p,1} = Q'_{p,1} - Q'_{p,2}; \quad Q'_{p,n} - Q'_{p,n-1} = Q'_{p,n-1}-Q'_{p,n-2}.
$$
Thus, we have:

$$
\begin{split}
Q'_{p,0} = & 2Q'_{p,1} - Q'_{p,2}
&= 2 \frac{X_{(1)}+X_{(2)}}{2} - \frac{X_{(2)}+X_{(3)}}{2}
&= \frac{2X_{(1)}+X_{(2)}-X_{(3)}}{2},\\
Q'_{p,n} = & 2Q'_{p,n-1} - Q'_{p,n-2}
&= 2 \frac{X_{(n-1)}+X_{(n)}}{2} - \frac{X_{(n-2)}+X_{(n-1)}}{2}
&= \frac{2X_{(n)}+X_{(n-1)}-X_{(n-2)}}{2}.
\end{split}
$$

Now we can start deriving $\operatorname{SV1}_p$:

$$
\begin{split}
\operatorname{SV1}_p
& = \operatorname{E}(Q'_{p,i}) = \sum_{i=0}^n P(Q_p \in S_i) \cdot Q'_{p,i} = \\
& = \sum_{i=0}^n B(i;n,p) Q'_{p,i} = \\
& = B(0;n,p) Q'_{p,0} + \sum_{i=1}^{n-1} B(i;n,p) Q'_{p,i} + B(n;n,p) Q'_{p,n} \\
\end{split}
$$

It gives us the following expression:

$$
\begin{split}
\operatorname{SV1}_p =
B(0;n,p) \frac{2X_{(1)}+X_{(2)}-X_{(3)}}{2} +
B(1;n,p) \frac{X_{(1)}+X_{(2)}}{2} +
B(2;n,p) \frac{X_{(2)}+X_{(3)}}{2} + \ldots + \\+
B(n-2;n,p) \frac{X_{(n-2)}+X_{(n-1)}}{2} +
B(n-1;n,p) \frac{X_{(n-1)}+X_{(n)}}{2} +
B(n;n,p) \frac{2X_{(n)}+X_{(n-1)}-X_{(n-2)}}{2}.
\end{split}
$$

By regrouping the equation members, we get the final result from the paper:

$$
\begin{split}
\operatorname{SV1}_p =
& \frac{2B(0;n,p)+B(1;n,p)}{2} X_{(1)} + \frac{B(0;n,p)}{2}X_{(2)} - \frac{B(0;n,p)}{2}X_{(3)}\\
& +\sum_{i=2}^{n-1} \frac{B(i;n,p)+B(i-1;n,p)}{2} X_{(i)} \\
& -\frac{B(n;n,p)}{2} X_{(n-2)} + \frac{B(n;n,p)}{2} X_{(n-1)} + \frac{2B(n;n,p)+B(n-1;n,p)}{2}X_{(n)}
\end{split}
$$

### SV2

The second approach assumes that the $p^\textrm{th}$ quantile is in the right endpoint of the $i^\textrm{th}$ segment:

$$
Q'_{p,i} = X_{(i+1)}\quad \textrm{for}\;\; i=0..n-1.
$$

To get the value of $Q'_{p,n}$, we use an assumption from the $\operatorname{SV1}_p$ section:

$$
Q'_{p,n} - Q'_{p,n-1} = Q'_{p,n-1}-Q'_{p,n-2}
$$

which can be transformed to

$$
Q'_{p,n} = 2Q'_{p,n-1} - Q'_{p,n-2} = 2X_{(n)} - X_{(n-1)}.
$$

Using $\operatorname{SV2}_p = \sum_{i=0}^n B(i;n,p) Q'_{p,i}$, we get:

$$
\operatorname{SV2}_p = \sum_{i=0}^{n-1} B(i;n,p) X_{(i+1)} + (2X_{(n)} - X_{(n-1)}) B(n;n,p)
$$

### SV3

The third approach assumes that the $p^\textrm{th}$ quantile is in the left endpoint of the $i^\textrm{th}$ segment:

$$
Q'_{p,i} = X_{(i)}\quad \textrm{for}\;\; i=1..n.
$$

To get the value of $Q'_{p,0}$, we use an assumption from the $\operatorname{SV1}_p$ section:

$$
Q'_{p,0}-Q'_{p,1} = Q'_{p,1} - Q'_{p,2}
$$

which can be transformed to

$$
Q'_{p,0} = 2Q'_{p,1} - Q'_{p,2} = 2X_{(1)}-X_{(2)}.
$$

Using $\operatorname{SV3}_p = \sum_{i=0}^n B(i;n,p) Q'_{p,i}$, we get:

$$
\operatorname{SV3}_p = \sum_{i=1}^n B(i;n,p) X_{(i)} + (2X_{(1)}-X_{(2)}) B(0;n,p)
$$


### Simplification

In my opinion, the above equations (that match the original paper) are too bulky.
Let's simplify them!
We can notice that we work with the same Binomial distribution $B(n, p)$.
What the point of writing the arguments $n$ and $p$ each time?
This just makes it difficult to read the equation!
(If you read the original paper, you may notice that the authors are also confused with this notation;
  sometimes they write $B(i;p,n)$ or $B(i;p)$ instead of $B(i;n,p)$.)
Let's denote $B(i;p,n)$ as $B_i$:

$$
B_i = B(i;p,n).
$$

Now we could rewrite the first equation in a shorter form:

$$
\begin{split}
SV1_p = & \frac{2B_0+B_1}{2}X_{(1)} + \frac{B_0}{2} X_{(2)} - \frac{B_0}{2} X_{(3)}\\
& + \sum_{i=2}^{n-1} \frac{B_i+B_{i-1}}{2} X_{(i)}\\
& -\frac{B_n}{2} X_{(n-2)} + \frac{B_n}{2} X _{(n-1)} + \frac{2B_n + B_{n-1}}{2} X_{(n)}
\end{split}
$$

Currently, the sum part $\sum_{i=2}^{n-1} \frac{B_i+B_{i-1}}{2} X_{(i)}$ enumerates $i$ from $2$ to $n-1$.
The part could "absorb" the $\frac{B_i+B_{i-1}}{2} X_{(i)}$ expression for $i=1$ and for $i=n$ from other members of the equation:

$$
\operatorname{SV1}_p =
\frac{B_0}{2} \big( X_{(1)}+X_{(2)}-X_{(3)} \big) +
\sum_{i=1}^{n} \frac{B_i+B_{i-1}}{2} X_{(i)} +
\frac{B_n}{2} \big(- X_{(n-2)}+X_{(n-1)}-X_{(n)} \big)
$$

In the second equation, we could adjust indexes and enumerate $i$ in range $1..n$ instead of $0..(n-1)$
  (to make it consistent with the first and the third equations):

$$
\operatorname{SV2}_p = \sum_{i=1}^{n} B_{i-1} X_{(i)} + B_n \cdot \big(2X_{(n)} - X_{(n-1)}\big)
$$

In the third equation, we should just replace $B(i;p,n)$ by $B_i$:

$$
\operatorname{SV3}_p = \sum_{i=1}^n B_i X_{(i)} + B_0 \cdot \big(2X_{(1)}-X_{(2)}\big)
$$

### Reference implementation

If you use R, here is the function that you can use in your scripts:

{{< src svquantile.R >}}

If you use C#, you can take an implementation from
  the latest nightly version (0.3.0-nightly.90+) of [Perfolizer](https://github.com/AndreyAkinshin/perfolizer)
  (you need `SfakianakisVerginis1QuantileEstimator`, `SfakianakisVerginis2QuantileEstimator`, `SfakianakisVerginis3QuantileEstimator`).

### Conclusion

The Sfakianakis-Verginis quantile estimator is an interesting way to estimate quantiles.
In this post, we briefly described the idea and looked at the estimator equations.
In future posts, we compare the efficiency of the suggested approach with other quantile estimators.

### References

* <b id="Sfakianakis2008">[Sfakianakis2008]</b>  
  Sfakianakis, Michael E., and Dimitris G. Verginis. "A new family of nonparametric quantile estimators." Communications in Statistics—Simulation and Computation® 37, no. 2 (2008): 337-345.  
  https://doi.org/10.1080/03610910701790491