---
title: "The importance of kernel density estimation bandwidth"
date: "2020-10-13"
tags:
- mathematics
- statistics
- research
- Density plots
- bandwidth
- KDE
features:
- math
---

Below see two kernel density estimations.
What could you say about them?

{{< imgld kde-riddle >}}

Most likely, you say that the first plot is based on a uniform distribution,
  and the second one is based on a multimodal distribution with four modes.
Although this is not obvious from the plots,
  both density plots are based on the same sample:

```txt
21.370, 19.435, 20.363, 20.632, 20.404, 19.893, 21.511, 19.905, 22.018, 19.93,
31.304, 32.286, 28.611, 29.721, 29.866, 30.635, 29.715, 27.343, 27.559, 31.32,
39.693, 38.218, 39.828, 41.214, 41.895, 39.569, 39.742, 38.236, 40.460, 39.36,
50.455, 50.704, 51.035, 49.391, 50.504, 48.282, 49.215, 49.149, 47.585, 50.03
```
The only difference between plots is in [bandwidth selection](https://en.wikipedia.org/wiki/Kernel_density_estimation#Bandwidth_selection)!

Bandwidth selection is crucial when you are trying to visualize your distributions.
Unfortunately, most people just call a regular function to build a density plot and don't think about how the bandwidth will be chosen.
As a result, the plot may present data in the wrong way, which may lead to incorrect conclusions.
Let's discuss bandwidth selection in detail and figure out how to improve the correctness of your density plots.
In this post, we will cover the following topics:

* Kernel density estimation
* How bandwidth selection affects plot smoothness
* Which bandwidth selectors can we use
* Which bandwidth selectors should we use
* Insidious default bandwidth selectors in statistical packages

<!--more-->

### Kernel density estimation

If we have a sample $x = \{x_1, x_2, \ldots, x_n \}$ and we want to build a corresponding density plot,
  we can use the [kernel density estimation](https://en.wikipedia.org/wiki/Kernel_density_estimation).
It's a function which is defined in the following way:

$$
\widehat{f}_h(x) = \frac{1}{nh} \sum_{i=1}^n K\Big(\frac{x-x_i}{h}\Big),
$$

where

* $K$ is the [kernel](https://en.wikipedia.org/wiki/Kernel_(statistics)#Nonparametric_statistics)
    (a simple non-negative function like the normal or uniform distribution),
* $h$ is the [bandwidth](https://en.wikipedia.org/wiki/Kernel_density_estimation#Bandwidth_selection)
    (a real positive number that defines smoothness of the density plot).

{{< example >}}
*Input:* $x = \{3, 4, 7\}$, $h = 1$, $K$ is the normal kernel.  
To build the kernel density estimation, we should perform two simple steps:
1. For each $x_i$, draw a normal distribution $\mathcal{N}(x_i, h^2)$ (the mean value $\mu$ is $x_i$, the variance $\sigma^2$ is $h^2$).
2. Sum up all the normal distributions from Step 1 and divide the sum by $n$.

That's all.
The sum of individual normal distributions around each sample element is our kernel density estimation.
That's what we usually see in the density plots that are based on a sample:

{{< imgld_medium kde-build1 >}}

{{< /example >}}

The kernel selection is a broad and exciting topic,
  but we are not going to discuss it in this post.
Let's assume that we always work with the normal kernel.
With this assumption, the only thing that we should choose is bandwidth.

### How bandwidth selection affects plot smoothness

A poorly chosen bandwidth value may lead to undesired transformations of the density plot:

* A *small* bandwidth leads to *undersmoothing*.  
  It means that the density plot will look like a combination of individual peeks (one peek per each sample element).
* A *huge* bandwidth leads to *oversmoothing*.  
  It means that the density plot will look like a unimodal distribution and hide all non-unimodal distribution properties
    (e.g., if a distribution is multimodal, we will not see it in the plot).

{{< example >}}
*Input:* $x = \{3, 4, 7\}$, $h \in \{ 0.2, 0.3, 0.4, 0.5, 1, 1.5 \}$, $K$ is the normal kernel.  
For the given bandwidth values, we have six different kernel density estimations:

{{< imgld_medium kde-build2 >}}

The bigger bandwidth we set, the smoother plot we get.  
Let's analyze what happens with increasing the bandwidth:

* $h = 0.2$: the kernel density estimation looks like a combination of three individual peaks
* $h = 0.3$: the left two peaks start to merge
* $h = 0.4$: the left two peaks are almost merged
* $h = 0.5$: the left two peaks are finally merged, but the third peak is still standing alone
* $h = 1.0$: the two merged peaks start to absorb the third peak, but the distribution is still bimodal
* $h = 1.5$: no signs of multimodality, we have a wide and smooth unimodal distribution

{{< /example >}}

{{< example >}}
*Input:* $x$ is the original 40-element sample from the beginning of this post,
  $h \in \{ 0.5, 1, 2, 3, 4, 5 \}$, $K$ is the normal kernel.  
{{< imgld_medium kde-build3 >}}
Here we have a situation which is similar to the previous example,
  but now we have a sample of a decent size.
From the raw data we know, that the distribution is most likely multimodal.
And we expect to get a plot with four modes.
Now let's look at what we actually get with different $h$ values:

* $h = 0.1$: the plot looks like a combination of dozens of individual spikes; this is not what we want
* $h = 0.5$: now we have four modes (as expected), but they look two noisy and rough; not good enough
* $h = 1.0$: here we have four smooth and clearly separated modes; this is the result that we are looking for
* $h = 2.0$: the modes start merging, we still see a multimodal distribution, but the modes are not clearly separated
* $h = 3.5$: we have a wide wobbly distribution with a slight echo of multimodality which is almost indistinguishable from noise
* $h = 5.0$: we have a flat unimodal distribution; no signs of multimodality

From the above options, $h = 1.0$ is the winner; it gives us the best representation of the underlying data.
{{< /example >}}

Now we see the real impact of bandwidth selection.
When the bandwidth value is poorly chosen, we get undersmoothing or oversmoothing.
In both cases, the true picture is hidden from us.
This dilemma leads us to the next question: how to choose a good bandwidth value in advance?

### Which bandwidth selectors can we use

So, we need an algorithm that chooses the optimal bandwidth value and avoids oversmoothing and undersmoothing.

{{< imgld kde-smoothing >}}

Such an algorithm is called *bandwidth selector* (or *bandwidth estimator*).
Let's look at some popular selectors that we can use.
I start with the 40-element sample from the beginning of the post and bandwidth selectors available in standard R functions.
Below you can see density plots that are drawn using different built-in bandwidth selectors from R:
 `bw.nrd0` (Silverman's rule of thumb),
 `bw.nrd` (Scott's rule of thumb),
 `bw.bcv` (biased cross-validation),
 `bw.ucv` (unbiased cross-validation),
 `bw.SJ` (Sheather & Jones method),
 and manual (you can just set any constant that you want).

{{< imgld kde-comparison >}}

As you can see, not all the bandwidth selectors give reliable results.
Now it's time to look at different methods in detail.

The first two methods are the most famous and straightforward:

* **Scott's rule of thumb** ([[Scott1992]](#Scott1992)): $h \approx 1.06 \cdot \hat{\sigma} n^{-1/5}$
* **Silverman's rule of thumb** ([[Silverman1986]](#Silverman1986)): $h = 0.9 \cdot \min ( \hat{\sigma}, IQR/1.35 ) n^{-1/5}$

Although they are simple and easy to compute, they have limitations.
The first one requires the data from the normal distribution.
If you work with another kind of distribution, you will not get meaningful results using Scott's rule of thumb.
The second rule is more robust but, as we can see, it doesn't work well in complicated cases.

Thus, in simple cases (e.g., in the case of unimodal distribution),
  you can safely use the Scott's or Silverman's rule of thumb (the Silverman's rule is recommended because it's more robust)
They work extremely fast and produce an excellent bandwidth value for the normal distribution and distributions close to normal.

However, if you are not sure about the form of your distribution, you may need a non-parametric bandwidth selector.
Here are a few examples of existing selectors:

* **Cross-validation methods**
  * **Maximum likelihood cross-validation (MLCV)** ([[Habbema1974]](#Habbema1974), [[Duin1976]](#Duin1976))
  * **Biased cross-validation (BCV)** ([[Scott1987]](#Scott1987))
  * **Unbiased cross-validation (UCV)** ([[Rudemo1982]](#Rudemo1982), [[Bowman1984]](#Bowman1984))
  * **Complete cross-validation (CCV)** ([[Jones1991]](#Jones1991))
  * **Modified cross-validation (MCV)** ([[Stute1992]](#Stute1992))
  * **Trimmed cross-validation (TCV)** ([[Feluch1992]](#Feluch1992))
  * ...
* **Plug-in methods**
  * **Park and Marron method** ([[Park1990]](#Park1990))
  * **Sheather and Jones method** ({{< link sheather1991 >}})
  * **Hall method** ([[Hall1991]](#Hall1991))
  * **Taylor bootstrap method** ([[Taylor1989]](#Taylor1989))
  * **Modifications of the Taylor bootstrap method** ([[Faraway1990]](#Faraway1990), [[Hall1990]](#Hall1990), [[Cao1993]](#Cao1993))
  * ...
* **Mixing methods**
  * **Mixing the bandwidths: Do-validation** ([[Mammen2011]](#Mammen2011))
  * **Mixing the estimators: the contrast method** ([[Ahmad2004]](#Ahmad2004))
  * ...

In practice, most of them produce much better results on multimodal distributions than the Scott's and Silverman's rules of thumb
  (e.g., see the Unbiased cross-validation and Sheather & Jones in the above picture).
Don't forget that the price for accuracy is performance: they work slower than a simple formula.
However, in most cases, you shouldn't worry about it: it's hard to notice a difference in performance in a single experiment if your sample contains less than `1_000_000` elements.

If you want know more about non-parametric bandwidth selectors, you can find nice overviews in [[Guidoum2015]](#Guidoum2015)), [[Heidenreich2013]](#Heidenreich2013)), and [[Schindler2012]](#Schindler2012).

### Which bandwidth selectors should we use

Unfortunately, there is no universal bandwidth selector that fits all the situations.

If you are 100% sure that your data follows the normal distribution, the Silverman's rule of thumb will be the best choice:
  it's fast and accurate.

However, if you don't know the actual distribution of your data and want to build a density estimation to *explore* the distribution form,
  Scott's and Silverman's rules are your worst enemies.
In most cases, they hide important distribution properties (like multimodality) and
  force you to think that the underlying distribution is close to unimodal.
In such cases, it's better to use an alternative approach.

My favorite option is to use the **Sheather and Jones method** because of the following reasons:
* **It works great**  
  It's pretty robust and produces nice density plots in most situations.
* **It's highly available**  
  You can use it using R, Wolfram Mathematica, Matlab, and many other statistical packages.
* **It's relatively fast**  
  Of course, this method works slower than the Scott's and Silverman's rules of thumb,
    but it's still pretty fast in practice.

Thus, the Sheather and Jones method is my tool of choice in most situations.

If you are not happy with this method in terms of computational efficiency or accuracy (it heavily depends on the data you have),
  some other approaches may work much better for your particular dataset (check out the "Conclusion" part in [[Heidenreich2013]](#Heidenreich2013))).
Don't hesitate to try different bandwidth selectors, but don't forget to double-check your results.

### Insidious default bandwidth selectors in statistical packages

It's time to review some API and check which bandwidth selectors are used by default in different statistical packages.

* **R**  
  By default, most of the standard kernel density estimation functions
    ([`density`](https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/density),
     [`geom_density`](https://ggplot2.tidyverse.org/reference/geom_density.html) from
     [`ggplot2`](https://ggplot2.tidyverse.org/index.html))
    uses `nrd0` which corresponds to the Silverman's rule of thumb.
  There is a lovely sentence in the documentation which explains why it's used by default:
  *"The default, "nrd0", has remained the default for historical and compatibility reasons, rather than as a general recommendation, where e.g., "SJ" would rather fit."*
* **Wolfram Mathematica**  
  By default, [`SmoothKernelDistribution`](https://reference.wolfram.com/language/ref/SmoothKernelDistribution.html) uses `Silverman` (Silverman's rule of thumb).
  Meanwhile, other options are available (`LeastSquaresCrossValidation`, `Oversmooth`, `Scott`, `SheatherJones`, `Silverman`, `StandardDeviation`, `StandardGaussian`).
* **Matlab**  
  By default, [`ksdensity`](https://www.mathworks.com/help/stats/ksdensity.html) uses a bandwidth value which "the optimal for normal densities."
  I didn't find the title of the used selector, but I guess it should be Scott's or Silverman's rule of thumb.
  An implementation of the Sheather and Jones method can be found [here](https://www.mathworks.com/matlabcentral/fileexchange/10921-kernel-density-estimation-of-2-dim-with-sj-bandwidth).
  Another non-parametric bandwidth selector can be found [here](https://www.mathworks.com/matlabcentral/fileexchange/14034-kernel-density-estimator).
* **SciPy**  
  By default, [`scipy.stats.gaussian_kde`](https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.gaussian_kde.html) uses
    `scott` (Scott's rule of thumb).
  The Silverman's rule of thumb and custom selectors are also available, but there are no built-in non-parametric bandwidth selectors.

As you can see, most popular statistical packages use default bandwidth selectors that are optimal only for the normal distribution.
Of course, I didn't check all the existing statistical libraries, but I guess it's a common tendency.

Personally, I think that these defaults are awful (even though they are extremely fast)
  because they lead to deceiving visualization for non-normal distribution.
One can argue that if somebody didn't verify the distribution for normality,
  the documentation will help to understand that the default bandwidth selector doesn't work well for the given data.
Unfortunately, it doesn't work this way: not every developer always reads the documentation.
Even if you know everything about bandwidths and defaults, it's hard to always keep it in mind.
For example, I draw density plots using `ggplot2` in R almost every day,
  but I usually forget to add the magic spell `bw = "SJ"` two or three times per month.
(I know that I can write util functions with better defaults and use it everywhere, but I want to keep my scripts small and portable.)
Today, it's almost impossible to globally change the defaults because it will break backward compatibility).
So, all that remains for us is to always carefully think about used bandwidth selectors
  wherever we use the kernel density estimation.

### Conclusion

There are many different bandwidth selectors that you can use in kernel density estimation.
Unfortunately, the default bandwidth selector in your favorite statistical package may lead to wrong visualizations.
To avoid problems with data interpretation, I recommend three simple rules:

1. **Be aware of the bandwidth selector that you use**  
   You shouldn't blindly use the default value from your favorite statistical package.
   It would be better to carefully think about the used bandwidth selector and explain to yourself why it fits your data.
   It would be much better if you share this explanation together with your density plots.
2. **Use a non-parametric bandwidth selector if you don't know the underlying distribution**  
   My personal recommendation is the Sheather and Jones method (e.g., `bw.SJ` in R, `"SheatherJones"` in Wolfram Mathematica, [`bandwidth_SJ`](https://www.mathworks.com/matlabcentral/fileexchange/10921-kernel-density-estimation-of-2-dim-with-sj-bandwidth) in Matlab).
   However, you can use any bandwidth selector that you want
     while you understand why you apply this particular selector and
     while you are sure that it fits your situation.
3. **Double-check that the data actually fits the density estimation**  
   You can never be sure that your estimation is correct until you verify it.
   It's OK to use estimation plots without additional checks during research,
     but it's always a good idea to double-check it before you publish/report/apply/use it.

### References

* <b id="Scott1992">[Scott1992]</b>  
  Scott, D. W. (1992) Multivariate Density Estimation: Theory, Practice, and Visualization. New York: Wiley.
* <b id="Silverman1986">[Silverman1986]</b>  
  Silverman, B. W. (1986). Density Estimation. London: Chapman and Hall.
* <b id="Sheather1991">[Sheather1991]</b>  
  Sheather, S. J. and Jones, M. C. (1991). A reliable data-based bandwidth selection method for kernel density estimation. Journal of the Royal Statistical Society series B, 53, 683–690. http://www.jstor.org/stable/2345597.
* <b id="Guidoum2015">[Guidoum2015]</b>  
  Guidoum, Arsalane Chouaib. "Kernel estimator and bandwidth selection for density and its derivatives." The kedd package, version 1 (2015).
* <b id="Heidenreich2013">[Heidenreich2013]</b>  
  Heidenreich, Nils-Bastian, Anja Schindler, and Stefan Sperlich. "Bandwidth selection for kernel density estimation: a review of fully automatic selectors." AStA Advances in Statistical Analysis 97, no. 4 (2013): 403-433.
* <b id="Schindler2012">[Schindler2012]</b>  
  Schindler, Anja. "Bandwidth selection in nonparametric kernel estimation." (2012).
* <b id="Habbema1974">[Habbema1974]</b>  
  Habbema, J. D. F., Hermans, J., and Van den Broek, K. (1974). A stepwise discrimination analysisprogram using density estimation.Compstat 1974: Proceedings in Computational Statistics.Physica Verlag, Vienna.
* <b id="Duin1976">[Duin1976]</b>  
  Duin, R. P. W. (1976). On the choice of smoothing parameters of Parzen estimators of probabilitydensity functions.IEEE Transactions on Computers,C-25, 1175–1179.
* <b id="Scott1987">[Duin1976]</b>  
  Scott, D.W. and George, R. T. (1987). Biased and unbiased cross-validation in density estimation.Journal of the American Statistical Association,82, 1131–1146.
* <b id="Rudemo1982">[Rudemo1982]</b>  
  Rudemo, M. (1982). Empirical choice of histograms and kernel density estimators.ScandinavianJournal of Statistics,9, 65–78.
* <b id="Bowman1984">[Bowman1984]</b>  
  Bowman, A. W. (1984). An alternative method of cross-validation for the smoothing of kerneldensity estimates. Biometrika,71, 353–360.
* <b id="Jones1991">[Jones1991]</b>  
  Jones, M. C. and Kappenman, R. F. (1991). On a class of kernel density estimate bandwidthselectors. Scandinavian Journal of Statistics,19, 337–349
* <b id="Stute1992">[Stute1992]</b>  
  Stute, W. (1992). Modified cross validation in density estimation. Journal of Statistical Planningand Inference,30, 293–305.
* <b id="Feluch1992">[Feluch1992]</b>  
  Feluch, W. and Koronacki, J. (1992). A note on modified cross-validation in density estimation.Computational Statistics and Data Analysis,13, 143–151.
* <b id="Park1990">[Park1990]</b>  
  Park, B.U., Marron, J.S.: Comparison of data-driven bandwidth selectors. J. Am. Stat. Assoc.85, 66–72(1990)
* <b id="Hall1991">[Hall1991]</b>  
  Hall, P., Sheater, S.J., Jones, M.C., Marron, J.S.: On optimal databased bandwidth selection in kernel densityestimation. Biometrika 78, 263–269 (1991)
* <b id="Taylor1989">[Taylor1989]</b>  
  Taylor, C.C.: Bootstrap choice of the smoothing parameter in kernel density estimation. Biometrika76,705–712 (1989)
* <b id="Faraway1990">[Faraway1990]</b>  
  Faraway, J.J., Jhun, M.: Bootstrap choice of bandwidth for density estimation. J. Am. Stat. Assoc.85,1119–1122 (1990)
* <b id="Hall1990">[Hall1990]</b>  
  Hall, P.: Using the bootstrap to estimate mean square error and select smoothing parameters in nonparametricproblems. J. Multivar. Anal.32, 177–203 (1990)
* <b id="Cao1993">[Cao1993]</b>  
  Cao, R.: Bootstrapping the mean integrated squared error. J. Multivar. Anal.45, 137–160 (1993)
* <b id="Mammen2011">[Mammen2011]</b>  
  Mammen, E., Martínez-Miranda, M.D., Nielsen, J.P., Sperlich, S.: Do-validation for kernel density estima-tion. J. Am. Stat. Assoc.106, 651–660 (2011)
* <b id="Ahmad2004">[Ahmad2004]</b>  
  Ahmad, I.A., Ran, I.S.: Data based bandwidth selection in kernel density estimation with parametric start via kernel contrasts. J. Nonparametr. Stat.16, 841–877 (2004)