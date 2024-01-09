---
title: Hodges-Lehmann ratio estimator vs. Bhattacharyya's scale ratio estimator
date: 2023-12-26
tags:
- mathematics
- statistics
- research
features:
- math
---

Previously, I [discussed]({{< ref hl-ratio >}}) an idea of a ratio estimator based on the Hodges-Lehmann estimator.
This idea looks so simple and natural that I was sure that it must have already been proposed and studied.
However, when I started to search for it, it turned out that it was not as easy as I expected.
Moreover, some papers attribute this idea to Bhattacharyya, which is not accurate.
In this post, we discuss the difference between these two approaches.

<!--more-->

### The Hodges-Lehmann ratio estimator

For two samples $\mathbf{x} = ( x_1, x_2, \ldots, x_n )$ and $\mathbf{y} = ( y_1, y_2, \ldots, y_m )$,
  the classic Hodges-Lehmann location shift estimator $\operatorname{HL}$ is defined as follows:

$$
\operatorname{HL}(\mathbf{x}, \mathbf{y}) =
  \underset{1 \leq i \leq n,\,\, 1 \leq j \leq m}{\operatorname{median}} \left(x_i - y_j \right).
$$

It seems natural to extend this idea and
  estimate the ratio between two samples as the median of the ratios of their elements.
We call this approach the Hodges-Lehmann ratio estimator $\operatorname{HLR}$:

$$
\operatorname{HLR}(\mathbf{x}, \mathbf{y}) =
  \underset{1 \leq i \leq n,\,\, 1 \leq j \leq m}{\operatorname{median}} \left(x_i / y_j \right).
$$

This ratio estimator can also be obtained from the classic location shift estimator using the log transformation:

$$
\operatorname{HLR}(\mathbf{x}, \mathbf{y}) =
  \exp \bigl( \operatorname{HL}(\log \mathbf{x}, \log \mathbf{y}) \bigr).
$$

This approach is applicable only for distribution with positive support.
Therefore, we assume that $x_i, y_j > 0$.
If the second distribution is a scaled version of the first one ($k\cdot Y = X$),
  the ratio estimator estimates the scale ratio factor $k$.

### Bhattacharyya's scale ratio estimator

In [[Bhattacharyya1977]](#Bhattacharyya1977), a similar idea is considered.
However, the paper investigates not the ratio of random variables but the ratio of their scale parameters.
This approach is shift-invariant and, therefore, ignores the actual absolute values of the random variables.
In Section 2, the author specifies an assumption of zero medians for both distributions:

$$
\operatorname{median}(X) = \operatorname{median}(Y) = 0.
$$

Next, they introduce a definition of a relevant pair $(x_i, y_j)$.
In each relevant pair, both $x_i$ and $y_j$ should be both positive or both negative.
Finally, they introduce estimator $\hat{\Delta}$ defined as the median of ratios *among only relevant pairs*:

$$
\hat{\Delta}(\mathbf{x}, \mathbf{y}) =
  \underset{\substack{1 \leq i \leq n,\,\, 1 \leq j \leq m, \\ x_i \cdot y_j > 0}}{\operatorname{median}}
    \left( \frac{x_i}{y_j} \right).
$$

### Conclusion

It is easy to see that $\operatorname{HLR} \neq \hat{\Delta}$ in the general case.
While they can be consistent in the case of pure scale transform ($k\cdot Y = X$),
  they estimate different parameters.
The Hodges-Lehmann ratio estimator estimates the ratio between variable values from two distributions,
  while Bhattacharyya's scale ratio estimator estimates the ratio between the scale parameters of these distributions.

### References

* <b id="Lehmann1963">[Lehmann1963]</b>  
  Hodges, J. L., and E. L. Lehmann.
  “Estimates of Location Based on Rank Tests.” The Annals of Mathematical Statistics 34, no. 2 (June 1963): 598–611.  
  DOI: [10.1214/aoms/1177704172](https://dx.doi.org/10.1214/aoms/1177704172)
* <b id="Bhattacharyya1977">[Bhattacharyya1977]</b>  
  Bhattacharyya, Helen T. “Nonparametric Estimation of Ratio of Scale Parameters.” Journal of the American Statistical Association 72, no. 358 (June 1977): 459–63.  
  DOI: [10.1080/01621459.1977.10481021](https://dx.doi.org/10.1080/01621459.1977.10481021)
* <b id="Padgett1982">[Padgett1982]</b>  
  Padgett, W. J., and L. J. Wei.
  “Estimation of the Ratio of Scale Parameters in the Two Sample Problem with Arbitrary Right Censorship.”
  Biometrika 69, no. 1 (1982): 252–56.  
  DOI: [10.1093/biomet/69.1.252](https://dx.doi.org/10.1093/biomet/69.1.252)
* <b id="Price1996">[Price1996]</b>  
  Price, Robert Martin Jr. “Estimating the Ratio of Medians: Theory and Applications.” University of Wyoming, 1996.  
