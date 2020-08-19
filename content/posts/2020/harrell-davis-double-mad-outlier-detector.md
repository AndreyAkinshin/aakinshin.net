---
title: "Yet another robust outlier detector"
date: "2020-06-22"
tags:
- Statistics
- Outliers
- MAD
- Harrell-Davis
- R
- Perfolizer
features:
- math
---

Outlier detection is an important step in data processing.
Unfortunately, if the distribution is not normal (e.g., right-skewed and heavy-tailed), it's hard to choose
  a robust outlier detection algorithm that will not be affected by tricky distribution properties.
During the last several years, I tried many different approaches, but I was not satisfied with their results.
Finally, I found an algorithm to which I have (almost) no complaints.
It's based on the *double median absolute deviation* and the *Harrell-Davis quantile estimator*.
In this post, I will show how it works and why it's better than some other approaches.

<!--more-->

### Adopting to non-parametric distributions with MAD

In the world of normal distributions, the typical approach for outlier detection is based on *the standard deviation*.
It uses the following thresholds for the outliers:

$$
\textrm{Lower} = \textrm{Mean} - k \cdot \textrm{StdDev}, \quad
\textrm{Upper} = \textrm{Mean} + k \cdot \textrm{StdDev}, \quad
k_{\textrm{default}} = 3.
$$

With these thresholds, we mark all the values outside the $ [ \textrm{Lower}; \textrm{Upper} ] $ range as outliers.
Unfortunately, this approach doesn't work well when the distribution is not normal.

In the world of non-parametric distributions, there is another popular approach called *Tukey's fences* ([[Tukey1997]](#Tukey1997)).
It defines outlier thresholds as follows:

$$
\textrm{Lower} = Q_1 - k \cdot \textrm{IQR}, \quad
\textrm{Upper} = Q_3 + k \cdot \textrm{IQR}, \quad
k_{\textrm{default}} = 1.5,
$$

where $ \textrm{IQR} = Q_3 - Q_1 $ is the interquartile range.
It works well, but it's not robust enough because it's defined only be quartile values $ Q_1 $ and $ Q_3 $.
These quartile values are calculated based on a few sample values and ignore the rest of the sample.

To resolve this problem, we can use a more robust measure of statistical dispersion called *the median absolute deviation (MAD)* ([[Leys2013]](#Leys2013)).
For the sample $ X = \{ X_1, X_2, \ldots, X_n \} $, it can be defined as follows:

$$
\textrm{MAD} = C \cdot \textrm{median}(|X_i - \textrm{median}(X)|).
$$

For the normally distributed values, there is a well-known relationship between the standard deviation and the median absolute deviation:

$$
\textrm{StdDev} \approx 1.4826 \cdot \textrm{median}(|X_i - \textrm{median}(X)|).
$$

Thus, we can use $ C = 1.4826 $ (which is also known as *the consistency constant*) to make $ \textrm{MAD} $ a consistent estimator for the standard deviation estimation.
With the MAD approach, we can define the outlier thresholds as follows:

$$
\textrm{Lower} = \textrm{Median} - k \cdot \textrm{MAD}, \quad
\textrm{Upper} = \textrm{Median} + k \cdot \textrm{MAD}, \quad
k_{\textrm{default}} = 3.
$$

In the case of the normal distribution, it works the same way as the standard deviation approach.
Meanwhile, it detects outliers in non-parametric distributions much better.
Also, it's more robust than Tukey's fences because it respects all values from the given sample.

According to [[Yang2019]](#Yang2019), MAD is not inferior in popularity to the Tukey's fences in recent scientific publications.

### Adopting to nonsymmetric distributions with Double MAD

The classic MAD approach defines a symmetric interval around the median.
This does not work great for the left-skewed, right-skewed, and other kinds of nonsymmetric distributions.
Consider the following sample from a right-skewed distribution: (100, 101, 102, 103, 110, 111, 112, 120, 121, 122, 140, 160, 180, 200, 220, 240, 2000, 2001, 2002).
The obvious outliers are (2000, 2001, 2002).
If we apply the MAD approach, we will get the following numbers:

$$
\textrm{Median} = 122, \quad \textrm{MAD} = 31.1346, \quad \textrm{Lower} = 28.5962, \quad \textrm{Upper} = 215.4038.
$$

Thus, 220 and 240 will be marked as outliers because they exceed the upper threshold.

This problem can be resolved with the help of the Double MAD approach ([[Rosenmai2013]](#Rosenmai2013)).
The idea is simple: for the obtained median value, we should calculate two median absolution deviations.
One deviation should be calculated for the numbers below the median and one for the numbers above the median:

$$
M = \textrm{median}(X), \quad
X^{(l)} = \{ x | x \in X \wedge x \leq M \}, \quad
X^{(u)} = \{ x | x \in X \wedge x \geq M \},
$$

$$
\textrm{MAD}^{(l)} = C \cdot \textrm{median}(|X^{(l)}_i - M|), \quad
\textrm{MAD}^{(u)} = C \cdot \textrm{median}(|X^{(u)}_i - M|).
$$

Next, we can define outlier thresholds using $ \textrm{MAD}^{(l)} $ for $ \textrm{Lower} $ and $ \textrm{MAD}^{(u)} $ for $ \textrm{Upper} $:

$$
\textrm{Lower} = M - k \cdot \textrm{MAD}^{(l)}, \quad \textrm{Upper} = M + k \cdot \textrm{MAD}^{(u)}.
$$

For the above example, we have the following values:

$$
M = 122, \quad \textrm{MAD}^{(l)} = 17.0499, \quad \textrm{MAD}^{(u)} = 130.4688,
$$

$$
\textrm{Lower} = 70.8503, \quad \textrm{Upper} = 513.4064.
$$

Now we mark all values that exceed $ \textrm{Upper} $ as outliers.
In our cases, the outlier set is (2000, 2001, 2002).

### Adopting to bimodal distributions with the Harrell-Davis quantile estimator

The MAD formula involves the median estimation.
Unfortunately, the most common ["straightforward"](https://en.wikipedia.org/wiki/Median#Finite_data_set_of_numbers) approach
  to calculate the median value is not always robust enough.
Consider the following sample: (4, 10, 15, 18, 19, 20, 501, 502, 503, 504, 3000).
The straightforward sample median value is 20.

However, it may not be the best estimation of the population median.
Here we have a bimodal distribution based on two sample subgroups: (4, 10, 15, 18, 19, 20) and (501, 502, 503, 504).
The last sample value 3000 is an outlier.
We got 20 as the median value "by chance" because the first group contains one number more than the second group with the outlier.
The true median of the population is most likely somewhere between 20 and 501.

This problem can be resolved with the help of the Harrell-Davis quantile estimator ([[Harrell1982]](#Harrell1982)).
It defines estimation for th $ p^{\textrm{th}} $ quantile as follows:

$$
Q_p = \Sigma_{i=1}^{n} W_{n,i} X_i,
$$

$$
W_{n,i} = I_{i/n} \{p(n+1)), (1-p)(n+1) \} - I_{(i-1)/n} \{ p(n+1), (1-p)(n+1) \},
$$

where $ I_x \{ a, b \} $ denotes the incomplete beta function.
This formula may look scary, but it provides a more robust median estimation than the straightforward approach.
In the above example, the Harrell-Davis estimation is 202.0452.

Using the MAD approach, we have the following numbers:

$$
\textrm{Median} = 20, \quad \textrm{MAD} = 23.7216,
$$

$$
\textrm{Lower} = -51.1648, \quad \textrm{Upper} = 91.1648,
$$

$$
\textrm{Outliers} = \{ 501, 502, 503, 504, 3000 \}.
$$

The whole right mode was marked as a set of outliers.
It's not the result that we actually want.

Using the Double MAD approach, we have:

$$
\textrm{Median} = 20, \quad \textrm{MAD}^{(l)} = 5.1891, \quad \textrm{MAD}^{(u)} = 715.3545,
$$

$$
\textrm{Lower} = 4.4327, \quad \textrm{Upper} = 2166.0635,
$$

$$
\textrm{Outliers} = \{ 4, 3000 \}.
$$

It looks better: the right mode is not considered as a set of outliers anymore.
However, we have another problem: 4 is marked as an outlier because it's less than the lower threshold.

Now let's try the Harrell-Davis-powered Double MAD approach:

$$
\textrm{Median} = 202.0452, \quad \textrm{MAD}^{(l)} = 276.4030, \quad \textrm{MAD}^{(u)} = 660.4467,
$$

$$
\textrm{Lower} = -627.1638, \quad \textrm{Upper} = 2183.3854,
$$

$$
\textrm{Outliers} = \{ 3000 \}.
$$

Hooray, we finally got the correct set of outliers!

### Another example

Let's consider another example that compares different combinations of the discussed approaches.
We take `BaseSample` from the beta-distribution $ \textrm{Beta}(1, 10) $ multilied by 10000.
Next, we add different combinations of lower or upper outliers and check how the following outlier detector work:

* `TukeySimple`: Tukey's fences with the straightforward quantile estimation
* `TukeyHd`: Tukey's fences with the Harrell-Davis quantile estimation
* `MadSimple`: MAD with the straightforward quantile estimation
* `MadHd`: MAD with the Harrell-Davis quantile estimation
* `DoubleMadSimple`: Double MAD with the straightforward quantile estimation
* `DoubleMadHd`: Double MAD with the Harrell-Davis quantile estimation

Here are the results:

```md
BaseSample = {
  9, 47, 50, 71, 78, 79, 97, 98, 117, 123,
  136, 138, 143, 145, 167, 185, 202, 216, 217, 229,
  235, 242, 257, 297, 300, 315, 344, 347, 347, 360,
  362, 368, 387, 400, 428, 455, 468, 484, 493, 523,
  557, 574, 586, 605, 617, 618, 634, 641, 646, 649,
  674, 678, 689, 699, 703, 709, 714, 740, 795, 798,
  839, 880, 938, 941, 983, 1014, 1021, 1022, 1165, 1183,
  1195, 1250, 1254, 1288, 1292, 1326, 1362, 1363, 1421, 1549,
  1585, 1605, 1629, 1694, 1695, 1719, 1799, 1827, 1828, 1862,
  1991, 2140, 2186, 2255, 2266, 2295, 2321, 2419, 2919, 3612}

Lower1 = {-2000, BaseSample}
Lower2 = {-2001, -2000, BaseSample}
Lower3 = {-2002, -2001, -2000, BaseSample}

                Lower1          Lower2                Lower3
TukeySimple     -2000,2919,3612 -2001,-2000,2919,3612 -2002,-2001,-2000,2919,3612
TukeyHd         -2000,2919,3612 -2001,-2000,2919,3612 -2002,-2001,-2000,2919,3612
MadSimple       -2000,2919,3612 -2001,-2000,2919,3612 -2002,-2001,-2000,2919,3612
MadHd           -2000,2919,3612 -2001,-2000,2919,3612 -2002,-2001,-2000,2919,3612
DoubleMadSimple -2000,3612      -2001,-2000,3612      -2002,-2001,-2000,3612
DoubleMadHd     -2000           -2001,-2000           -2002,-2001,-2000

Upper1 = {BaseSample, 6000}
Upper2 = {BaseSample, 6000, 6001}
Upper3 = {BaseSample, 6000, 6001, 6002}

                Upper1         Upper2              Upper3
TukeySimple     2919,3612,6000 2919,3612,6000,6001 2919,3612,6000,6001,6002
TukeyHd         3612,6000      3612,6000,6001      3612,6000,6001,6002
MadSimple       2919,3612,6000 2919,3612,6000,6001 2919,3612,6000,6001,6002
MadHd           2919,3612,6000 2919,3612,6000,6001 2919,3612,6000,6001,6002
DoubleMadSimple 3612,6000      6000,6001           6000,6001,6002
DoubleMadHd     6000           6000,6001           6000,6001,6002

Both1 = {-2000, BaseSample, 6000}
Both2 = {-2001, -2000, BaseSample, 6000, 6001}
Both3 = {-2002, -2001, -2000, BaseSample, 6000, 6001, 6002}

                Both1                Both2                           Both3
TukeySimple     -2000,2919,3612,6000 -2001,-2000,2919,3612,6000,6001 -2002,-2001,-2000,3612,6000,6001,6002
TukeyHd         -2000,3612,6000      -2001,-2000,3612,6000,6001      -2002,-2001,-2000,3612,6000,6001,6002
MadSimple       -2000,2919,3612,6000 -2001,-2000,2919,3612,6000,6001 -2002,-2001,-2000,2919,3612,6000,6001,6002
MadHd           -2000,2919,3612,6000 -2001,-2000,2919,3612,6000,6001 -2002,-2001,-2000,2919,3612,6000,6001,6002
DoubleMadSimple -2000,6000           -2001,-2000,6000,6001           -2002,-2001,-2000,6000,6001,6002
DoubleMadHd     -2000,6000           -2001,-2000,6000,6001           -2002,-2001,-2000,6000,6001,6002
```

As we can see, only `DoubleMadHd` produces the expected outliers in all the cases.

### Reference implementations

If you use R, here is the function that you can use in your scripts:

```r
library(Hmisc)

removeOutliers <- function(x) {
  hdmedian <- function(u) as.numeric(hdquantile(u, 0.5))
  
  x <- x[!is.na(x)]
  m <- hdmedian(x)
  deviations <- abs(x - m)
  lowerMAD <- 1.4826 * hdmedian(deviations[x <= m])
  upperMAD <- 1.4826 * hdmedian(deviations[x >= m])
  
  return(x[x >= m - 3 * lowerMAD & x <= m + 3 * upperMAD])
}
```

If you use C#, you can take an implementation from
  the latest nightly version (0.3.0-nightly.30+) of [Perfolizer](https://github.com/AndreyAkinshin/perfolizer)
  (you need `DoubleMadOutlierDetector`).

### Conclusion

In this post, we built a robust outlier detector based on Double MAD and the Harrell-Davis quantile estimator.
It works well with different kinds of non-parametric distributions, including nonsymmetric and bimodal data sets.

Of course, it's not a universal approach that handles all the possible cases.
Since we don't have a strict outlier definition, it's always possible to find examples of results that are "incorrect"
  from the researcher's point of view for any outlier detection algorithm.

I tested the suggested approach on a huge number of data sets based on software performance measurements.
The corresponding distributions are often right-skewed and heavily-tailed, so it's pretty hard to find the correct set of outliers.
However, I (almost) have never been disappointed with the results.

Sometimes, the algorithm may skip some outliers around the thresholds.
This happens because it "tries" to detect only the most "obvious" outlier values.
If it's not OK for your case, the outlier sensitivity can be tuned by the scale factor $ k $.
However, in my experiments, $ k = 3 $ works fine for most cases.

I hope that the Harrell-Davis-powered Double MAD approach may help you as well in your next outlier hunting journey.

### References

* <b id="Tukey1997">[Tukey1997]</b>  
  Tukey, John W. Exploratory data analysis. Vol. 2. 1977.
* <b id="Leys2013">[Leys2013]</b>  
  Leys, Christophe, Christophe Ley, Olivier Klein, Philippe Bernard, and Laurent Licata.
  "Detecting outliers: Do not use standard deviation around the mean, use absolute deviation around the median."
  *Journal of Experimental Social Psychology* 49, no. 4 (2013): 764-766.
* <b id="Yang2019">[Yang2019]</b>  
  Yang, Jiawei, Susanto Rahardja, and Pasi Fränti.
  "Outlier detection: how to threshold outlier scores?."
  *In Proceedings of the International Conference on Artificial Intelligence, Information Processing and Cloud Computing*, pp. 1-6. 2019.  
  https://www.researchgate.net/publication/337883760_Outlier_detection_how_to_threshold_outlier_scores
* <b id="Rosenmai2013">[Rosenmai2013]</b>  
  Rosenmai, Peter.
  "Using the Median Absolute Deviation to Find Outliers."
  *Eureka Statistics.*
  November 25, 2013.
  Accessed June 22, 2020.  
  https://eurekastatistics.com/using-the-median-absolute-deviation-to-find-outliers/
* <b id="Harrell1982">[Harrell1982]</b>  
  Harrell, F.E. and Davis, C.E., 1982. A new distribution-free quantile estimator.
  *Biometrika*, 69(3), pp.635-640.  
  https://pdfs.semanticscholar.org/1a48/9bb74293753023c5bb6bff8e41e8fe68060f.pdf
