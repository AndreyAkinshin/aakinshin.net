---
title: "Andreas Löffler's implementation of the exact p-values calculations for the Mann-Whitney U test"
date: 2024-01-23
tags:
- mathematics
- statistics
- research
- mann-whitney
features:
- math
---

Mann-Whitney is one of the most popular non-parametric statistical tests.
Unfortunately, most test implementations in statistical packages are far from perfect.
The exact p-value calculation is time-consuming and can be impractical for large samples.
Therefore, most implementations automatically switch to the asymptotic approximation, which can be quite inaccurate.
Indeed, the classic normal approximation could produce
  [enormous]({{< ref r-mann-whitney-incorrect-p-value >}})
  [errors]({{< ref python-mann-whitney-incorrect-p-value >}}).
Thanks to the [Edgeworth expansion]({{< ref mw-edgeworth2 >}}), the accuracy can be improved,
  but it is still not always satisfactory enough.
I prefer using the exact p-value calculation whenever possible.

The computational complexity of the exact p-value calculation using the classic recurrent equation
  suggested by Mann and Whitney is $\mathcal{O}(n^2 m^2)$ in terms of time and memory.
It's not a problem for small samples, but for medium-size samples,
  it is slow, and it has an extremely huge memory footprint.
This gives us an unpleasant dilemma:
  either we use the exact p-value calculation (which is extremely time and memory-consuming),
  or we use the asymptotic approximation (which gives poor accuracy).

Last week, I got acquainted with a brilliant algorithm for the exact p-value calculation
  suggested by Andreas Löffler in 1982.
It's much faster than the classic approach, and it requires only $\mathcal{O}(n+m)$ memory.

<!--more-->

### The algorithm idea

Let us say we compare two samples of sizes $n$ and $m$, and the Mann-Whitney U statistic value is $u$.
To obtain the p-value, we need $p_{n,m}(u)$ (see [[Mann1947]](#Mann1947), page 51),
  which is typically defined using the following recurrent equation:

$$
p_{n,m}(u) = p_{n-1,m}(u - m) + p_{n,m-1}(u).
$$

In [[Löffler1982]](#Loeffler1982), Andreas Löffler derives an alternative recurrent equation:

$$
p_{n,m}(u) = \frac{1}{u} \sum_{i=0}^{u-1} p_{n,m}(i) \cdot \sigma_{n,m}(u - i),
$$

$$
\sigma_{n,m}(u) = \sum_{u \operatorname{mod} d} \varepsilon_d d,\quad\textrm{where}\;
\varepsilon_d = \begin{cases}
1, & \textrm{where}\; 1 \leq d \leq n, \\
0, & \textrm{else}, \\
-1, & \textrm{where}\; m+1 \leq d \leq m+n.
\end{cases}
$$

The formula derivation uses a smart trick based on a generating function, and it takes only two pages.
Here is a reference implementation in C#
  (the most straightforward one, further optimizations are possible; no big numbers support):

```cs
public long[] MannWhitneyLoeffler(int n, int m, int u)
{
    int[] sigma = new int[u + 1];
    for (int d = 1; d <= n; d++)
    for (int i = d; i <= u; i += d)
        sigma[i] += d;
    for (int d = m + 1; d <= m + n; d++)
    for (int i = d; i <= u; i += d)
        sigma[i] -= d;

    long[] p = new long[u + 1];
    p[0] = 1;
    for (int a = 1; a <= u; a++)
    {
        for (int i = 0; i < a; i++)
            p[a] += p[i] * sigma[a - i];
        p[a] /= a;
    }

    return p;
}
```

### Further reading

For a better understanding of the suggested approach, I recommend reading the original papers:
  [[Mann1947]](#Mann1947) and [[Löffler1982]](#Loeffler1982).
Also, it is worth reading the corresponding discussion about the adoption of this approach in R and SciPy:

* [r-devel mailing list discussion (2024-January/083124)](https://stat.ethz.ch/pipermail/r-devel/2024-January/083124.html)
* [R 18655: Enhancements to `*wilcox` functions for large population sizes](https://bugs.r-project.org/show_bug.cgi?id=18655)
* [SciPy discussion](https://github.com/scipy/scipy/pull/4933#issuecomment-1898082691)

### References

* <b id="Mann1947">[Mann1947]</b>  
  Mann, H. B., and D. R. Whitney.
  “On a Test of Whether One of Two Random Variables Is Stochastically Larger than the Other.”
  The Annals of Mathematical Statistics 18, no. 1 (March 1947): 50–60.  
  DOI: [10.1214/aoms/1177730491](https://dx.doi.org/10.1214/aoms/1177730491)
* <b id="Loeffler1982">[Löffler1982]</b>  
  Andreas Löffler.
  “Über eine Partition der nat. Zahlen und ihre Anwendung beim U-Test” (1982).  
  [Original PDF (In German)](https://upload.wikimedia.org/wikipedia/commons/f/f5/LoefflerWilcoxonMannWhitneyTest.pdf)  
  [English translation](https://upload.wikimedia.org/wikipedia/de/1/19/MannWhitney_151102.pdf)
