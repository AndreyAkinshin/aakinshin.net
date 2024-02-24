---
title: Eclectic statistics
date: 2024-01-16
tags:
- mathematics
- statistics
- research
- thoughts
features:
- math
---

In the world of mathematical statistics, there is a constant confrontation between adepts of different paradigms.
This is a constant source of confusion for many researchers who struggle to pick out the proper approach to follow.
For example, how to choose between the frequentist and Bayesian approaches?
Since these paradigms may produce inconsistent results
  (e.g., see [Lindley's paradox](https://en.wikipedia.org/wiki/Lindley%27s_paradox)),
  some choice has to be made.
The easiest way to conduct research is to pick a single paradigm and stick to it.
The right way to conduct research is to carefully think.

<!--more-->

In my learning journey, I have passed periods of being a fanatic of different paradigms.
I remember myself being
  an [NHST](https://en.wikipedia.org/wiki/Statistical_hypothesis_testing) adherent,
  a [p-value](https://en.wikipedia.org/wiki/P-value) hater,
  a [Bayesian](https://en.wikipedia.org/wiki/Bayesian_inference) enthusiast,
  a [likelihoodist](https://en.wikipedia.org/wiki/Likelihoodist_statistics) fan,
  and a [robust statistics](https://en.wikipedia.org/wiki/Robust_statistics) devotee.
Each time, I vigorously promoted my favorite approach and tried to convince everyone that it was the only correct one
  and that it should be applied everywhere.
Now, I feel like these arguments are pointless without context.
Each statistical method has its own area of applicability and its own limitations.
There are no "good" and "bad" approaches,
  there are only "proper" and "improper" approaches *in the context of a particular problem*.
Instead of arguing which statistical paradigm is better in general,
  it is better to focus on which paradigm is a better match for the given task.
For example, a great solution to the p-value problem is not
  a [blind p-value ban](https://www.taylorfrancis.com/chapters/edit/10.4324/9781315629049-17),
  but the [correctly used p-values](https://journals.sagepub.com/doi/10.1177/1745691620958012).

Each paradigm properly suits a special set of problems for which it was designed.
The primary work of a researcher is to thoroughly formalize the target problem:
  understand the true business goals, and write down all the requirements and limitations.
Only after that, one can start looking for proper statistical tools.
Having a properly written problem definition, this search becomes a mechanical task:
  we can just enumerate different techniques and check how they match the problem.
With a deep understanding of business goals,
  it's easy to build a validation mechanism for potential statistical approaches and compare them by formal criteria.
When we discuss statistics "in general," nobody could win in the paradigm battle.
Adherents of each approach implicitly assume their own context,
  which prevents them from productive discussions with their opponents.

Modern statistics provides a wide variety of approaches for different problems.
If you want to control the false-positive rate in a long series of experiments,
  the Neyman-Pearson [frequentist statistics](https://en.wikipedia.org/wiki/Frequentist_inference)
  provides great tools for that.
Want to get the most reasonable result for a single experiment?
[Bayesian statistics](https://en.wikipedia.org/wiki/Bayesian_inference) is the way to go.
If you don't have proper priors,
  check out the [likelihoodist statistics](https://en.wikipedia.org/wiki/Likelihoodist_statistics).
Curious about the practical significance?
The [estimation statistics](https://en.wikipedia.org/wiki/Estimation_statistics) are here to help.
The data is not normally distributed?
The [nonparametric statistics](https://en.wikipedia.org/wiki/Nonparametric_statistics) will come to the rescue.
Have frequent outliers?
The [robust statistics](https://en.wikipedia.org/wiki/Robust_statistics) will save the day.
Have multiple corner cases?
The [defensive statistics]({{< ref ds >}}) will help you out.

Once I accepted the beauty of the statistical method diversification,
  I got my next revelation: none of the classic statistical methods are applicable to real-life problems as-is.
The design of analysis procedures always implies some assumptions.
We have to operate with mathematical models that give us some approximation of reality,
  but these models are never perfect.
For example, there are hundreds of methods that require data normality,
  but the perfect normal distribution doesn't exist in nature.
Many researchers enjoy exploring the asymptotic properties of their favorite methods,
  but real-life samples typically contain a finite number of observations.
A typical assumption in the context of continuous distributions is the absence of tied values,
  but in practice, the resolution of our instruments is limited and ties are inevitable.
Every single assumption can be violated.

Everything is a tradeoff.
We can evaluate the applicability of a statistical method using various criteria.
Unfortunately, it's a rare situation when a single method perfectly matches all the criteria.
There is always a tradeoff between various properties.
The list of tradeoffs in statistics is imposing:
  [bias vs. variance](https://en.wikipedia.org/wiki/Bias%E2%80%93variance_tradeoff),
  accuracy vs. precision,
  robustness vs. efficiency,
  false-positive vs. false-negative vs. sample size vs. effect size,
  overfitting vs. underfitting,
  componential complexity vs. approximation accuracy,
  [double descent problem](https://en.wikipedia.org/wiki/Double_descent),
  and so on.
In most cases, we just physically can't achieve the best possible result in all the criteria simultaneously.
We have to define the proper balance between the business requirements.
Since "pure" mathematical methods tend to optimize a specific set of criteria,
  it is not always possible to achieve the optimal balance by sticking to a single approach.

A pragmatic alternative to the straightforward usage of a "pure" version of a statistical method
  is to combine multiple methodologies.
This approach can be referred to as ["eclectic statistics"](https://en.wikipedia.org/wiki/Eclecticism).
The core idea is not just to pick up the most appropriate paradigm for the current problem
  but to enhance its properties by incorporating additional techniques.
If we do not limit ourselves to a single solution,
  we can achieve awesome results with
    decent statistical efficiency and robustness,
    optimal tradeoffs between various criteria,
    and proper handling of corner cases.
