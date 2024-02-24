---
title: "Examples of the Mann–Whitney U test misuse cases"
date: 2023-02-14
tags:
- mathematics
- statistics
- mann-whitney
features:
- math
---

The Mann–Whitney U test is one of the most popular nonparametric statistical tests.
Its alternative hypothesis claims that one distribution is stochastically greater than the other.
However, people often misuse this test and try to apply it to check
  if two nonparametric distributions are not identical
  or that there is a difference in distribution medians
  (while there are no additional assumptions on the shapes of the distributions).
In this post, I show several cases in which the Mann–Whitney U test is not applicable
  for comparing two distributions.

<!--more-->

### Simulation design

In the below case studies, we conduct numerical simulations according to the following scheme.
In each case study, we consider two different distributions: $A$ and $B$.
We
  draw $500$ random samples of size $5\,000$ from each distribution,
  perform the Mann–Whitney U test for each pair of samples,
  calculate the p-value,
  and build a distribution of p-values.
When the null hypothesis is true, we expect that p-values form the standard uniform distribution $\mathcal{U}(0, 1)$.
When the alternative hypothesis is true, the distribution of p-values is expected to be heavily skewed.

If we falsely (!) assume that the alternative hypothesis claims that the distributions are non-identical,
  we may expect a skewed distribution of p-values.
However, as we will see, this distribution is close to the uniform one.
This demonstrates that the Mann–Whitney U test is unsuitable for comparing such distributions.
Of course, it is not thorough research, but I believe that it is enough to illustrate the problem.

### Case study 1: Normal distributions with different variances

For the first case study, we consider two normal distributions:
  the standard normal distribution ($\mu = 0,\, \sigma = 1$)
  and a normal distribution with the same mean but increased variance ($\mu = 0,\, \sigma = 10$):

$$
\begin{split}
A =\; & \mathcal{N}(0, 1), \\
B =\; & \mathcal{N}(0, 10^2).
\end{split}
$$

Here are the density plots for $A$ and $B$:

{{< imgld density1 >}}

Although $A \neq B$ (there is a huge difference in variance), the Mann–Whitney U test is not capable of detecting it:

{{< imgld mw1 >}}

### Case study 2: Non-overlapping distributions

In the second case study, we compare a uniform distribution on $[-1;1]$ and
  a mixture of two uniform distributions on $[-3;-2]$ and $[2;3]$:

$$
\begin{split}
A =\; & \mathcal{U}(-1, 1), \\
B =\; & 0.5 \cdot \mathcal{U}(-3, -2) + 0.5 \cdot \mathcal{U}(2, 3).
\end{split}
$$

Here are the density plots for $A$ and $B$:

{{< imgld density2 >}}

Although $A$ and $B$ are non-overlapping distributions, the Mann–Whitney U test is not capable of detecting it:

{{< imgld mw2 >}}

### Case study 3: Different medians

Sometimes, the Mann–Whitney U test is considered a test that checks the difference and medians.
Let us consider the following two distributions with a noticeable difference in medians:

$$
\begin{split}
A =\; & 0.51 \cdot \mathcal{U}(0, 1) + 0.49 \cdot \mathcal{U}(10, 11), \\
B =\; & 0.49 \cdot \mathcal{U}(2, 3) + 0.51 \cdot \mathcal{U}(8, 9).
\end{split}
$$

It is easy to see that $\operatorname{median}(A) \approx 1$, $\operatorname{median}(B) \approx 8$.
Here are the density plots for $A$ and $B$:

{{< imgld density3 >}}

Although $\operatorname{median}(A) \ll \operatorname{median}(B)$, the Mann–Whitney U test is not capable of detecting it:

{{< imgld mw3 >}}

### Conclusion

The Mann–Whitney U test is a useful nonparametric test when it is used correctly.
If we compare population $A$ and population $B$, the alternative hypothesis claims that

$$
\mathbb{P}(A < B) + 0.5\cdot \mathbb{P}(A=B) \neq 0.5.
$$

If there are no additional assumptions related to $A$ and $B$, this statement cannot be converted to
  "the distributions are not identical" or "the distribution medians are not equal."
If you want to use statistical tests properly, always pay attention to the hypothesis statements and
  the [limitations of the used test]({{< ref mann-whitney-min-stat-level >}}).

### References

* <b id="Hart2001">[Hart2001]</b>  
  Hart, Anna.
  "Mann-Whitney test is not just a test of medians: differences in spread can be important."
  Bmj 323, no. 7309 (2001): 391-393.
  DOI:[10.1136/bmj.323.7309.391](https://dx.doi.org/10.1136/bmj.323.7309.391)
* <b id="Conroy2012">[Conroy2012]</b>  
  Conroy, Ronán M.
  "What hypotheses do “nonparametric” two-group tests actually test?."
  The Stata Journal 12, no. 2 (2012): 182-190.
  DOI:[10.1177/1536867X1201200202](https://dx.doi.org/10.1177/1536867X1201200202)
* <b id="Divine2018">[Divine2018]</b>  
  Divine, George W., H. James Norton, Anna E. Barón, and Elizabeth Juarez-Colunga.
  "The Wilcoxon–Mann–Whitney procedure fails as a test of medians."
  The American Statistician 72, no. 3 (2018): 278-286.
  DOI:[10.1080/00031305.2017.1305291](https://dx.doi.org/10.1080/00031305.2017.1305291)
