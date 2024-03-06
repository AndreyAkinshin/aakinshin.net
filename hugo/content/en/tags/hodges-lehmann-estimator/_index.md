---
title: Hodges–Lehmann Estimator
---

The Hodges–Lehmann Estimator is a robust measure of location and location shift.
Introduced in {{< link hodges1963 >}} and {{< link sen1963 >}}.


For a single sample $\mathbf{x} = ( x_1, x_2, \ldots, x_n )$,
  the Hodges-Lehmann location estimator (known as pseudo-median)
  is defined as the median of the Walsh (pairwise) averages:

$$
\operatorname{HL}(\mathbf{x}) =
  \underset{1 \leq i \leq j \leq n}{\operatorname{median}} \left(\frac{x_i + y_j}{2} \right).
$$

For two samples $\mathbf{x} = ( x_1, x_2, \ldots, x_n )$ and $\mathbf{y} = ( y_1, y_2, \ldots, y_m )$,
  the Hodges-Lehmann location shift estimator is defined as follows:

$$
\operatorname{HL}(\mathbf{x}, \mathbf{y}) =
  \underset{1 \leq i \leq n,\,\, 1 \leq j \leq m}{\operatorname{median}} \left(x_i - y_j \right).
$$

Asymptotic breakdown point: $\approx 29\%$; asymptotic Gaussian efficiency: $\approx 96\%$.

Reference R implementation (the default implementation is [buggy]({{< ref r-hodges-lehmann-problems >}})):

```r
hl <- function(x, y = NULL) {
  if (is.null(y)) {
    walsh <- outer(x, x, "+") / 2
    median(walsh[lower.tri(walsh, diag = TRUE)])
  } else {
    median(outer(x, y, "-"))
  }
}
```