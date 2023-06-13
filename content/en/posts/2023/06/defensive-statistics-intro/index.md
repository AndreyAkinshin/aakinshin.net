---
title: Introducing the defensive statistics
date: 2023-06-13
tags:
- mathematics
- statistics
- research
features:
- math
---

> Normal or approximately normal subjects are less useful objects of research than their pathological counterparts.
>
> --- Sigmund Freud, "The Psychopathology of Everyday Life"

In the realm of software development, reliability is crucial.
This is especially true when creating systems
  that automatically analyze performance measurements to maintain optimal application performance.
To achieve the desired level of reliability, we need a set of statistical approaches
  that provide accurate and trustworthy results.
These approaches must work even when faced with varying input data sets and multiple violated assumptions,
  including malformed and corrupted values.
In this blog post, I introduce "Defensive Statistics" as an appropriate methodology for tackling this challenge.

<!--more-->

When working with an automatic analysis system, it is vital to establish a statistical protocol in advance.
This should be done without any prior knowledge of the target data.
Additionally, we have no control over the measurements gathered and reported,
  as these components are maintained by other developers.
For the system to be considered reliable, it must consistently provide accurate reports on any set of input values.
This must hold true regardless of data malformation or distortion.
Ensuring a low Type I error rate is essential for the trustworthiness of our system.
Unfortunately, most classic statistical methods have
  unsupported [pathological](https://en.wikipedia.org/wiki/Pathological_(mathematics)) corner cases
  that arise outside the declared assumptions.

To address these challenges, our statistical methods must meet several key requirements:

* Incorporate nonparametric statistical methods,
    as relying on the normal distribution or other parametric models may lead to incorrect results.
* Use robust statistics to effectively handle extreme outliers that appear in the case of heavy-tailed distributions.
* Work with various data types, including discrete distributions, continuous-discrete mixtures,
    and the Dirac delta distribution with zero variance.
  Even if the underlying distribution is supposed to be continuous,
    the discretization effect may appear due to the limited resolution of measurement devices.
* Anticipate and account for multimodality in real-life distributions,
    as well as low-density regions in the middle of the distribution (even around the median).
* Prioritize small sample sizes, considering the expense and time constraints associated with data gathering.
* Support weighted samples to address non-homogenous data
    and allow proper aggregation of measurements from various repository revisions.

While none of the corner cases should lead to system dysfunction,
  we care about statistical efficiency for the majority of input datasets,
  in which the typical assumptions are satisfied.
Therefore, methods of protection from the corner cases should not lead to tangible efficiency loss.

Since there isn't a pre-existing term that encapsulates these requirements, I propose the term "Defensive Statistics."
This term is inspired by [defensive programming](https://en.wikipedia.org/wiki/Defensive_programming),
  which also prioritizes reliable program execution in cases of invalid, corrupted, or unexpected input.
The main objectives of defensive statistics are:

* Always provide valid and reliable results for any input data set, no matter how many original assumptions are violated.
* Maximize statistical efficiency when most input data sets follow a typical set of assumptions.

Manual one-time investigations may not require a high level of reliability since errors can be addressed by hand.
However, methods of defensive statistics are essential
  for the automatic analysis of a wide range of uncontrollable inputs.
By incorporating the discussed principles into our work,
  we can ensure that our software consistently delivers accurate and trustworthy results.
This remains true even when faced with complex and unpredictable data sets.
Adopting defensive statistics leads to more resilient, reliable, and efficient systems
  in the constantly evolving world of software development.
