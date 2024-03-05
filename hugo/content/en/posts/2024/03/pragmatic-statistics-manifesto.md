---
title: Pragmatic Statistics Manifesto
date: 2024-03-05
tags:
- mathematics
- statistics
- research
- Pragmatic Statistics
---

Statistics is one of the most confusing, controversial, and depressing disciplines I know.
So many different approaches, so many different opinions, so many arguments, so many person-years of wasted time,
  and so many flawed peer-reviewed papers.

What we want from statistics is an easy-to-use tool that would nudge us toward asking the right questions
  and then straightforwardly guide us on how to design proper and relevant statistical procedures.
What we have is a bunch of vaguely described sets of strange equations,
  a few arbitrarily chosen magical numbers as thresholds,
  and no clear understanding of what to do.

In the scientific community, there are a lot of adherents of
  *Frequentist* statistics (both Neyman-Pearson and Fisherian),
  *Bayesian* statistics,
  *Likelihood* statistics,
  *Nonparametric* statistics,
  *Robust* statistics,
  and many other statistics.
And almost no one discusses *Pragmatic* statistics.
I feel like we really need something which is called *Pragmatic* statistics.
However, it should not be just a set of "blessed" approaches but rather a mindset.

Let me make an attempt to speculate on the principles
  that should form the foundation of the *Pragmatic* statistics approach.
In future posts, I will show how to apply these principles to solve real-world problems.

<!--more-->

## Manifesto

* **Pragmatic statistics is useful statistics.**  
  We use statistics to actually get things done and solve actual problems.
  We do not use statistics to make our work more "scientific" or just because everyone else does it.

* **Pragmatic statistics is [goal-driven statistics]({{< ref effect-magnitude-goals >}}).**  
  We always clearly define the goals we want to achieve and the problems we want to solve.
  We do not apply statistics to just check out how the data looks like
    and we do not draw conclusions from exploratory research without additional confirmatory research.

* **Pragmatic statistics is verifiable statistics.**  
  Based on the clearly defined goals, we should build a verification framework
    that allows checking if the considered statistical approaches match the goals.
  Therefore, choosing the proper research design among several options should be a mechanical process.

* **Pragmatic statistics is efficient statistics.**  
  We aim to get the maximum statistical efficiency.
  We understand that the data collection is not free and we want to fully utilize the information we obtain.

* **Pragmatic statistics is [eclectic statistics]({{< ref eclectic-statistics >}}).**  
  We do not ban statistical methods just because they are "bad."
  We are ready to use any combination of methods from different statistical paradigms while they solve the problem.

* **Pragmatic statistics is estimation statistics.**  
  We focus on practical significance instead of statistical significance.
  We never ask, "Is there an effect?"; we always assume that an effect always exists
    and our primary question is about the magnitude of the effect.

* **Pragmatic statistics is [robust statistics]({{< ref robust-statistics-books >}}).**  
  We are ready to handle extreme outliers in our data and heavy-tailed distributions in our models.

* **Pragmatic statistics is nonparametric statistics.**  
  While we try to utilize existing parametric assumptions to increase efficiency,
    we embrace deviations from the given parametric model and adjust the approaches for the nonparametric case.

* **Pragmatic statistics is [defensive statistics]({{< ref ds >}}).**  
  We aim to support all the corner cases.
  While robust and nonparametric approaches help us to handle moderate deviations from the model,
    severe assumption violations should not lead to misleading or incorrect inference.

* **Pragmatic statistics is [weighted statistics]({{< ref preprint-wqe >}}).**  
  We do not treat all the obtained measurements equally.
  Instead, we try to extend the model with weight coefficients that reflect the representativeness of the measurements.
