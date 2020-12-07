---
title: "Weighted quantile estimators"
date: "2020-09-29"
tags:
- Statistics
- Quantiles
- Harrell-Davis
- R
- Perfolizer
features:
- math
---

In this post, I will show how to calculate weighted quantile estimates and how to use them in practice.

Let's start with a problem from real life.
Imagine that you measure the total duration of a unit test executed daily on a CI server.
Every day you get a single number that corresponds to the test duration from the latest revision for this day:

{{< imgld_medium moving1 >}}

You collect a history of such measurements for 100 days.
Now you want to describe the "actual" distribution of the performance measurements.

However, for the latest "actual" revision, you have only a single measurement, which is not enough to build a distribution.
Also, you can't build a distribution based on the last N measurements because they can contain change points that will spoil your results.
So, what you really want to do is to use all the measurements, but older values should have a lower impact on the final distribution form.

Such a problem can be solved using the weighted quantiles!
This powerful approach can be applied to any time series regardless of the domain area.
In this post, we learn how to calculate and apply weighted quantiles.

<!--more-->

### Literature overview

When I started looking for a weighted quantile implementation,
  I was sure that it should be easy to google some well explained sources.
Unfortunately, I didn't manage to find any workable approach.
Here are some of my findings (you can scroll to the next section if you are not interested in non-working approaches):

* [The weighted percentile method](https://en.wikipedia.org/wiki/Percentile#Weighted_percentile) on Wikipedia  
  A very strange formulation with missing details.
  It doesn't seem to be true because it's based on two subsequent elements from the given sample.
  Here is a simple counterexample for any formula which is based on two subsequent elements.
  Imagine a sample $ \{ x_1, x_2, x_3, x_4 \}$ where $ x_1 \leq x_2 \leq x_3 \leq x_4 $ with weights $ \{ 1, 0, 1, 0 \} $.
  I expect that the median value will be $ (x_1 + x_3) / 2$, but we can't get such a result using two subsequent elements.
  If we have low weights around the element that corresponds to the target quantile, the formula should involve several elements from the original sample.
* [Answer for "Defining quantiles over a weighted sample"](https://stats.stackexchange.com/a/13223/261747) on StackExchange.  
  The same problem here: a formula with two subsequent elements.
* [Weighted percentiles](https://blogs.sas.com/content/iml/2016/08/29/weighted-percentiles.html) on SAS blogs.  
  It explains only the general concept of weighted quantiles, but it doesn't provide any details.
  Although the main idea looks correct (it uses ECDF), it's hard to check and reuse it.

Also, I found some implementations of weighted quantiles:

* [Hmisc::wtd.quantile](http://finzi.psych.upenn.edu/R/library/Hmisc/html/wtd.stats.html) (R)  
  Has a [critical bug](https://github.com/harrelfe/Hmisc/issues/97), doesn't work.
  Designed only for the Harrell-Davis quantile estimator.
* [reldist::wtd.quantile](https://www.rdocumentation.org/packages/reldist/versions/1.6-6/topics/wtd.quantile) (R)  
  Just [calls](https://github.com/cran/reldist/blob/5e5c9357b7ca27585a11bbcfb2e4a2ab6e37dd7b/R/wtd.quantile.R#L16) `wtd.quantile` from `Hmisc`
* [FilippoBovo/robustats](https://github.com/FilippoBovo/robustats) (Python)  
  Produces very strange results.
  [For example](https://github.com/FilippoBovo/robustats/blob/8d029001acaa7702fe5ecb33479664bb7cb0a3f7/robustats/robustats.py#L32), the weighted median value for $\{ 1.0, 2.0 \}$ with weights $\{ 1.0, 1.0 \}$ is $1.0$.

The weighted quantiles look like a very natural concept to me.
So, I believe it should be explained somewhere, but I just didn't manage to find it.
If you know such a reference, I will appreciate if you share it with me.

Meanwhile, I decided to derive all the formulas myself because it sounds like a fun exercise.
In this post, I will show how to transform a non-weighted quantile estimator to a weighted one
  and present exact formulas for the Harrell-Davis and Type 7 weighted quantile estimators.

### Notation

We will use the following notation:

* $x$: original sample. Assuming that it's always contain sorted real numbers.
* $n$: the number of elements in the sample.
* $x_i$: $i^\textrm{th}$ element of the sample.
* $w$: a vector of weights. It has the same length as $x$. Assuming $w_i \geq 0$, $\sum_{i=1}^n w > 0$.
* $s_i(w)$: partial sum of weights, $s_i(w) = \sum_{j=1}^{i} w_j$. Assuming $s_0(w) = 0$.
* $q_p$: estimation of the $p^\textrm{th}$ quantile based on $x$.

### Weighted quantiles

Let's say we have a sample $x = \{ x_1, x_2, \ldots, x_n \}$ and we want to calculate the $p^\textrm{th}$ quantile $q_p$.

{{< example >}}
*Input:* $x = \{ 1, 2, 3, 4, 5 \}$ and $p = 0.5$.  
*Result:* $q_p = 3$.  
Since $p = 0.5$, we are looking for the median, it's the middle element of a sorted sample which equals $3$ in our case.
{{< /example>}}

Let's also consider a vector of weights $w = \{ w_1, w_2, \ldots, w_n \}$.
We assume that the weight of $x_i$ is $w_i$.
We want to calculate the $p^\textrm{th}$ quantile $q_p$ with respect to these weights.
To give you an idea of this concept, let's look at another example.

{{< example >}}
*Input:* $x = \{ 1, 2, 3, 4, 5 \}$, $w = \{ 1, 0, 0, 1, 1 \}$, $p = 0.5$.  
*Result:* $q_p = 4$.  
Here $w_2 = w_3 = 0$, which means that we can omit the second and the third element of the sample.
Since $w_1 = w_4 = w_5 = 1$, we can imagine that our sample was transformed to $\{ 1, 4, 5 \}$.
After that, it's easy to see that $q_p = 4$ because it's the middle element of the transformed sample.
{{< /example>}}

It was an easy example because $w$ contained only zeros and ones.
What about more complicated cases when $w$ contains fractional numbers?
The exact formula for weighted quantiles depends on the used quantile estimator for the non-weighted case.
In this post, we consider two estimator kinds:

* **The Type 7 quantile estimator**  
  It's the most popular quantile estimator which is used by default in
    R, Julia, NumPy, Excel (`PERCENTILE`, `PERCENTILE.INC`), Python (`inclusive` method).
  We call it "Type 7" according to notation from [[Hyndman1996]](#Hyndman1996), 
    where Rob J. Hyndman and Yanan Fan described nine quantile algorithms which are used in statistical computer packages.
* **The Harrell-Davis quantile estimator**  
  It's my favorite option in real life because
    it's more robust than classic quantile estimators based on linear interpolation,
    and it provides more reliable estimations on small samples.
  This quantile estimator is described in [[Harrell1982]](#Harrell1982).

### Weighted Harrell-Davis quantile estimator

I start with the Harrell-Davis quantile estimator because it provides a more intuitive generalization for the weighted case.

Here is the formula for the Harrell-Davis quantile estimator:

$$
q_p = \sum_{i=1}^{n} W_{n,i} \cdot x_i,
$$

$$
W_{n,i} = I_{i/n} (p(n+1)), (1-p)(n+1)) - I_{(i-1)/n} (p(n+1), (1-p)(n+1))
$$

where $I_t(a, b)$ denotes the [regularized incomplete beta function](https://en.wikipedia.org/wiki/Beta_function#Incomplete_beta_function).
It's not a simple formula, so let's visualize it for better understanding.
$I_u (a, b)$ depends on three variables: $x$, $a$, and $b$.
The values of $a$ and $b$ and fixed for the given $p$:

$$
\left\{
\begin{array}{rccl}
a = & p     & \cdot & (n + 1),\\
b = & (1-p) & \cdot & (n + 1).
\end{array}
\right.
$$

Thus, we can rewrite the formula for $W_{n,i}$ as follows:

$$
W_{n,i} = I_{i/n}(a, b) - I_{(i-1)/n}(a, b).
$$

{{< example >}}
*Input:* $n=9$, $p=0.25$ (we are looking for the first [quartile](https://en.wikipedia.org/wiki/Quartile)).  
*Result:* $a = p(n+1) = 0.25 \cdot 10 = 2.5, \quad b = (1-p)(n+1) = 0.75 \cdot 10 = 7.5$.
{{< /example >}}

Using the predefined $a$ and $b$, we can define the following function:

$$
g(t) = t^{a-1} (1-t)^{b-1}.
$$

{{< example >}}
For $a = 2.5$ and $b = 7.5$, $g(t)$ looks as follows:

{{< imgld_small hd1 >}}
{{< /example >}}

The value of the [beta function](https://en.wikipedia.org/wiki/Beta_function) is the area under this curve:

$$
B(a,b) = \int_0^1 t^{a-1}(1-t)^{b-1}\,dt.
$$

The value of the [incomplete beta function](https://en.wikipedia.org/wiki/Beta_function#Incomplete_beta_function) for $x$ is the area under this curve between $0$ and $x$:

$$
B(u; a,b) = \int_0^u t^{a-1}(1-t)^{b-1}\,dt.
$$

The value of the *regularized incomplete beta function* for $x$ is the normalized version of the incomplete beta function, so its value always belongs to $[0; 1]$.
To get the regularized version, we should divide the incomplete beta function by $B(a,b)$ (it's a constant for given $a$ and $b$).

$$
I_u(a,b) = \frac{B(u;\,a,b)}{B(a,b)}.
$$

{{< example >}}
$I_{0.25}(a, b)$ corresponds to the area of the highlighted area on the following plot:

{{< imgld_small hd2 >}}
{{< /example >}}

Here are a few additional facts which are good to understand:

* $I_{0.0}(a, b) = 0.0$, it's the minimum value of this function.
* $I_{1.0}(a, b) = 1.0$, it's the maximum value of this function and the area under the curve on the above plot.
* $I_u(a,b)$ is also the [cumulative distribution function](https://en.wikipedia.org/wiki/Cumulative_distribution_function) (CDF) for the [Beta distribution](https://en.wikipedia.org/wiki/Beta_distribution).
* Regularized version of $g(t)$ is the [probability density function](https://en.wikipedia.org/wiki/Probability_density_function) (PDF) of the Beta distribution:
  $f(t) = g(t) / B(a, b) = t^{a-1} (1-t)^{b-1} / B(a, b)$.
  On the above and below plots, we are working with PDF.

Now we can visualize $W_{n,i} = I_{i/n}(a, b) - I_{(i-1)/n}(a, b)$.
Each $W_{n,i}$ corresponds to a fragment of our plot.

{{< example >}}
*Input:* $n=9$, $p=0.25$, $a=2.5$, $b=7.5$.  
In this case, we get 9 fragments of $I_u(a,b)$ (last two segments are almost invisible):

{{< imgld_small hd3 >}}

$W_{n,i}$ equals the area of the $i^\textrm{th}$ fragment.

{{< /example >}}

We work with the *regularized* version of the incomplete beta function, so the sum of these fragments equals $1$:

$$
\sum_{i=1}^n W_{n, i} = 1.
$$

Since $q_p = \sum_{i=1}^{n} W_{n,i} \cdot x_i$, the $W_{n, i}$ coefficients define the "contribution" of $x_i$ to the quantile value.

Now it's time to convert our non-weighted quantile estimator to a weighted one.
First of all, we should introduce the concept of "weighted count."
It's the sum of all weights normalized by the maximum weight:

$$
n^* = \dfrac{\sum_{i=1}^n w_i}{\max_{i=1}^{n} w_i}.
$$

Thus, the weighted count of $w = \{1, 1, 1, 0, 0 \}$ and $w = \{ 1, 1, 1 \}$ is $3$ for both cases.
This value has an influence on the values of $a$ and $b$.
Here are the updated equations for the weighted case:

$$
\left\{
\begin{array}{rccl}
a^* = & p     & \cdot & (n^* + 1),\\
b^* = & (1-p) & \cdot & (n^* + 1).
\end{array}
\right.
$$

Next, I suggest changing how we choose the width of the $I_u(a,b)$ fragments.
Currently, the endpoints of the $i^\textrm{th}$ fragment are
$$
\left\{
\begin{array}{rcc}
l_i & = & \dfrac{i - 1}{n},\\
r_i & = & \dfrac{i}{n}.
\end{array}
\right.
$$

All the fragments have the same width which equals $1/n$.
Let's introduce new endpoints in such a way that the width of the fragment will be equal to $w_i/s_n(w)$:

$$
\left\{
\begin{array}{rcc}
l^*_i & = & \dfrac{s_{i-1}(w)}{s_n(w)},\\
r^*_i & = & \dfrac{s_i(w)}{s_n(w)}.
\end{array}
\right.
$$

It's a generalization of the non-weighted case because $l_i = l^*_i, r_i = r^*_i$ when all weights are equal (e.g., $\forall i: w_i = 1$).
Now we can introduce a "weighted version" of $W_{n, i}$:

$$
W^*_{n, i} = I_{r^*_i}(a^*, b^*) - I_{l^*_i}(a^*, b^*).
$$

Here is the final formula for the weighted Harrell-Davis quantile estimator:

$$
q^*_p = \sum_{i=1}^{n} W^*_{n,i} \cdot x_i.
$$

{{< example >}}
*Input:* $x = \{ 1, 2, 3, 4, 5 \}$, $w = \{ 1, 0, 0, 1, 1 \}$, $p = 0.5$.  

Without weights, we had the following five equal-width fragments:

{{< imgld_small hd4 >}}

With weights, the second and the third fragments will be eliminated.
It means that now we have three equal fragments (for $x_1$, $x_4$, $x_5$):

{{< imgld_small hd5 >}}

{{< /example >}}

{{< example >}}
*Input:* $x = \{ 1, 2, 3, 4, 5 \}$, $w = \{ 0.4, 0.4, 0.05, 0.05, 0.1 \}$, $p = 0.5$.  
The values of $x$ and $p$ match the previous example, so we have the same plot for $I_u(a, b)$.
However, the new value of $w$ defines another fragmentation:

{{< imgld_small hd6 >}}

As we can see, $x_1$ and $x_2$ have a major impact on the median value because they have high weights: $w_1 = w_2 = 0.4$.
Meanwhile, $x_3$, $x_4$, and $x_5$ have a minor impact because they have low weights: $w_3 = 0.05$, $w_4 = 0.05$, $w_5 = 0.1$.
The weighted median value $q^*_{0.5}$ is $\approx 1.7756$.

{{< /example >}}

### The generalization

We can generalize this approach for any non-weighted quantile estimator.
Let's say we can express the non-weighted equations via a CDF function $F$ in the following way:

$$
\begin{gather*}
q_p = \sum_{i=1}^{n} W_{n,i} \cdot x_i,\\
W_{n, i} = F(r_i) - F(l_i),\\
l_i = (i - 1) / n, \quad r_i = i / n.
\end{gather*}
$$

In this case, we can generalize it to the weighted case using an altered version of above equations:

$$
\begin{gather*}
q^*_p = \sum_{i=1}^{n} W^*_{n,i} \cdot x_i,\\
W^*_{n, i} = F(r^*_i) - F(l^*_i),\\
l^*_i = s_{i-1}(w) / s_n(w), \quad r^*_i = s_i(w) / s_n(w).
\end{gather*}
$$

It can be easily transformed back to the non-weighted case if we put $w_i = 1$ for any $i$.

In the case of the Harrell-Davis quantile estimator, we should put $F(u) = I_u(a^*, b^*)$.

### Weighted Type 7 quantile estimator

First of all, let's recall the [formula](https://en.wikipedia.org/wiki/Quantile#Estimating_quantiles_from_a_sample) for the Type 7 quantile estimator in the non-weighted case.
In order to do that, we should calculate the real valued index $h = p (n - 1) + 1$.
After that, the quantile value can be calculated using the following formula:

$$
q_p = x_{\lfloor h \rfloor} + (h - \lfloor h \rfloor) (x_{\lfloor h \rfloor + 1} - x_{\lfloor h \rfloor}).
$$

To get the non-weighted case formula in the generic form, we should express it via a CDF function (let's call it $F_7$).
It has the following form:

$$
F_7(u) = \left\{
\begin{array}{lcrcllr}
0      & \textrm{for} &         &      & u  & <    & (h-1)/n, \\
un-h+1 & \textrm{for} & (h-1)/n & \leq & u  & \leq & h/n, \\
1      & \textrm{for} & h/n     & <    & u. &      &
\end{array}
\right.
$$

The corresponding PDF (let's call it $f_7$) looks simpler:

$$
f_7(u) = F'_7(u) = \left\{
\begin{array}{lcrcllr}
0      & \textrm{for} &         &      & u  & <    & (h-1)/n, \\
n      & \textrm{for} & (h-1)/n & \leq & u  & \leq & h/n, \\
0      & \textrm{for} & h/n     & <    & u. &      &
\end{array}
\right.
$$

{{< example >}}
*Input:* $n = 5$, $p = 0.25$.  
We have $h = 2$ which gives us the following plots:

{{< imgld_small type7-1 >}}

{{< /example >}}

Let's verify that it works the correct way for the non-weighted case using $W_{n,i} = F_7(i / n) - F_7((i - 1) / n)$:

* Assuming $h$ is an integer number.  
  For $i < h$, we have $W_{n,i} = 0 - 0 = 0$.  
  For $i = h$, we have $W_{n,i} = 1 - 0 = 1$.  
  For $i > h$, we have $W_{n,i} = 1 - 1 = 0$.  
  Thus, $q_p = \sum_{i=1}^{n} W_{n,i} \cdot x_i = x_h = x_{\lfloor h \rfloor} + (h - \lfloor h \rfloor) (x_{\lfloor h \rfloor + 1} - x_{\lfloor h \rfloor})$.

{{< example >}}
*Input:* $n = 5$, $p = 0.25$.  
We have $h = 2$, which is an integer number.
Here are the corresponding PDF and CDF plots:

{{< imgld_small type7-2 >}}

It's easy to see that we have only one non-negative $W_{n,i}$: $W_{5,2} = 1$.
It means that $q_{0.25} = x_2$, which satisfies our expectations (the first quartile of a sample with five elements is the second element).

{{< /example >}}

* Assuming $h$ is a non-integer number.  
  For $i < \lfloor h \rfloor$, we have $W_{n,i} = 0 - 0 = 0$.  
  For $i = \lfloor h \rfloor$, we have $W_{n,i} = (\lfloor h \rfloor/n \cdot n - h + 1) - 0 = \lfloor h \rfloor - h + 1$.  
  For $i = \lfloor h \rfloor + 1$, we have $W_{n,i} = 1 - (\lfloor h \rfloor/n \cdot n - h + 1) = h - \lfloor h \rfloor $.  
  For $i > \lfloor h \rfloor + 1$, we have $W_{n,i} = 1 - 1 = 0$.  
  Thus, $q_p = \sum_{i=1}^{n} W_{n,i} \cdot x_i = (\lfloor h \rfloor - h + 1) x_{\lfloor h \rfloor} + (h - \lfloor h \rfloor) x_{\lfloor h \rfloor + 1} = x_{\lfloor h \rfloor} + (h - \lfloor h \rfloor) (x_{\lfloor h \rfloor + 1} - x_{\lfloor h \rfloor})$.

{{< example >}}
*Input:* $n = 5$, $p = 0.25$.  
We have $h = 2.4$ which is a non-integer number.
Thus, the first quartile estimation is a linear combination of $x_2$ and $x_3$:

{{< imgld_small type7-3 >}}

{{< /example >}}

As we can see, the suggested $F_7$ perfectly matches the non-weighted case.
Using equations from the previous section, we can get the weighted case.

{{< example >}}
*Input:* $n = 5$, $x = \{ 1, 2, 3, 4, 5\}$, $w = \{ 1, 0, 1, 1, 1 \}$, $p = 0.25$.  
Here we have:  
$h = p(n - 1) + 1 = 2,$  
$(h - 1) / n = 0.2, \quad h / n = 0.4,$  
$F_7(u) = \left\{
\begin{array}{lcrcllr}
0    & \textrm{for} &     &      & u  & <    & 0.2, \\
5u-1 & \textrm{for} & 0.2 & \leq & u  & \leq & 0.4, \\
1    & \textrm{for} & 0.4 & <    & u, &      &
\end{array}
\right.$  
$s_0(w) = 0, \; s_1(w) = 1, \; s_2(w) = 1, \; s_3(w) = 2, \; s_4(w) = 3, \; s_5(w) = 4,$  
$\begin{array}{ll}
l^*_1 = s_0(w) / s_5(w) = 0.00, & r^*_1 = s_1(w) / s_5(w) = 0.25,\\
l^*_2 = s_1(w) / s_5(w) = 0.25, & r^*_2 = s_2(w) / s_5(w) = 0.25,\\
l^*_3 = s_2(w) / s_5(w) = 0.25, & r^*_3 = s_3(w) / s_5(w) = 0.50,\\
l^*_4 = s_3(w) / s_5(w) = 0.50, & r^*_4 = s_4(w) / s_5(w) = 0.75,\\
l^*_5 = s_4(w) / s_5(w) = 0.75, & r^*_5 = s_5(w) / s_5(w) = 1.00,\\
\end{array}$  
$W^*_{5,1} = F_7(r_1) - F_7(l_1) = F_7(0.25) - F_7(0.00) = 0.25 - 0.25 = 0.25,$  
$W^*_{5,2} = F_7(r_2) - F_7(l_2) = F_7(0.25) - F_7(0.25) = 0.25 - 0.25 = 0.00,$  
$W^*_{5,3} = F_7(r_3) - F_7(l_3) = F_7(0.50) - F_7(0.25) = 1.00 - 0.25 = 0.75,$  
$W^*_{5,4} = F_7(r_4) - F_7(l_4) = F_7(0.75) - F_7(0.50) = 1.00 - 1.00 = 0.00,$  
$W^*_{5,5} = F_7(r_5) - F_7(l_5) = F_7(1.00) - F_7(0.75) = 1.00 - 1.00 = 0.00,$  
$q^*_{0.25} = W^*_{5,1}x_1 + W^*_{5,2}x_2 + W^*_{5,3}x_3 + W^*_{5,4}x_4 + W^*_{5,5}x_5 = 0.25x_1 + 0.75x_3 = 0.25 + 2.25 = 2.5.$
{{< /example >}}

### Weighted quantiles in action

Let's go back to the original problem with performance measurements and quantile evaluations.
We already know how to calculate the weighted quantiles.
All we need now is the weight values.
For problems like this, it's pretty convenient to use the [exponential decay](https://en.wikipedia.org/wiki/Exponential_decay) law
  (this approach is inspired by the [radioactive decay](https://en.wikipedia.org/wiki/Radioactive_decay)):

$$
\omega(t) = 2^{-t/t_{1/2}}
$$

where $t_{1/2}$ is the [half-life](https://en.wikipedia.org/wiki/Half-life).
This value describes the period of time required for the current weight to reduce to half of its original value.
Thus, we have

$$
\omega(0) = 1, \quad \omega(t_{1/2}) = 0.5, \quad \omega(2t_{1/2}) = 0.25, \quad \omega(3t_{1/2}) = 0.125, \ldots
$$

For our problem, we should use the exponential decay in a reverse way:

$$
w_i = \omega(n - i).
$$

Thus, the last measurement has weight $w_n = 1$,
  the measurement from $t_{1/2}$ days ago has weight $w_{n-t_{1/2}} = 0.5$,
  the measurement from $2t_{1/2}$ days ago has weight $w_{n-2t_{1/2}} = 0.25$,
  and so on.

Originally, we had the following pictures with daily measurements:

{{< imgld_small moving1 >}}

Let's say we want to get a daily estimation for the actual median value.
To do that, we have to apply the following procedure after each day:

* Assign weights $w_i$ to existing measurements $x_i$ according to the exponential decay law.
* Sort the pairs $(x_i, w_i)$ by the measurement values $x_i$ because our equations require a sorted sample.
* Apply the Harrell-Davis quantile estimator (because it's the most robust estimator) to get the median estimation ($q_{0.5}$).

Here is an illustration of how it works in practice (for this example, $t_{1/2} = 5$).

{{< imgld_small moving2 >}}

Of course, we can apply this procedure not only to the median, but to any other quantile and get a daily estimation of the "actual" distribution.
It may be "spoiled" after change point, but it will be "recovered" after a several days.

This approach can be improved with the help of change point detection (e.g., using [EdPelt]({{< ref "edpelt" >}}) or [RqqPelt](https://github.com/AndreyAkinshin/perfolizer#changepoint-detection)): we can just drop the values before the last change point.
However, the weighted approach improves our estimations in this case as well because some change points may not be correctly detected, or measurements may change slowly without explicit change points.

### Reference implementation

If you use R, here are functions that you can use in your scripts:

{{< src "weighted-quantiles.R" >}}

If you use C#, you can take an implementation from
  the latest nightly version (0.3.0-nightly.72+) of [Perfolizer](https://github.com/AndreyAkinshin/perfolizer)
  (you need `HarrellDavisQuantileEstimator` and `SimpleQuantileEstimator`).

### Conclusion

In this post, we derived equations for weighted quantile, including a generic CDF-based approach and specific formulas for the Harrell-Davis and Type 7 quantile estimators.
This technique has various applications, and we showed how to apply it to estimate quantiles for a time series using exponential decay.

The suggested equations present my own view on the concept of weighted quantiles since it's not a popular topic, and I didn't manage to find any good explanations.
If you know any papers/posts/implementations with the same or other approaches, I will appreciate if you share it with me.

### References

* <b id="Harrell1982">[Harrell1982]</b>  
  Harrell, F.E. and Davis, C.E., 1982. A new distribution-free quantile estimator.
  *Biometrika*, 69(3), pp.635-640.  
  https://pdfs.semanticscholar.org/1a48/9bb74293753023c5bb6bff8e41e8fe68060f.pdf
* <b id="Hyndman1996">[Hyndman1996]</b>  
  Hyndman, R. J. and Fan, Y. 1996. Sample quantiles in statistical packages, *American Statistician* 50, 361–365.  
  https://doi.org/10.2307/2684934