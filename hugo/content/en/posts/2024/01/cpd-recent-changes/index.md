---
title: Change Point Detection and Recent Changes
date: 2024-01-09
tags:
- mathematics
- statistics
- research
- Change Point Detection
features:
- math
---

Change point detection (CPD) in time series analysis
  is an essential tool for identifying significant shifts in data patterns.
These shifts, or "change points," can signal critical transitions in various contexts.
While most CPD algorithms are adept at discovering historical change points,
  their sensitivity in detecting recent changes can be limited,
  often due to a key parameter: the minimum distance between sequential change points.
In this post, I share some speculations on how we can improve cpd analysis by combining two change point detectors.

<!--more-->

### The Minimum Distance Parameter in CPD

In many CPD methods, the minimum distance between consecutive change points is a crucial parameter.
Without it, theoretically, every data point could be considered a change point, rendering the analysis impractical.
However, setting this parameter requires careful consideration, especially in the nonparametric case.
A value too low, like 5, might lead to detecting frequent but insignificant changes.
For example, in a bimodal distribution with equal probabilities for "0" and "1",
  a sequence like $(0; 0; 0; 0; 0; 1; 1; 1; 1; 1)$ occurs with a probability of $1/1024 \approx 0.001$,
  potentially indicating a change point.
If we process thousands of time series and the underlying distributions have frequent bimodality patterns,
  we can get an unacceptably high number of false positive change points.

From my experience, a safer threshold in practical scenarios is typically around 20.
Note that the exact optimal value heavily depends on your business goal
  and that the choosing procedure should acknowledge declared assumptions about the data.
This defined minimum distance helps maintain a low false-positive rate while
  actual significant shifts are typically detected.

### The Challenge of Detecting Recent Changes

A critical limitation arises with this setup when detecting recent change points.
Consider a time series with a majority of values in a consistent range,
  followed by a sudden, drastic shift in the last few measurements.
For example:

$$
(\underbrace{102, 107, 104, 105, ..., 109}_{\textrm{Many values in }[100;110]},
  10\,126, 10\,863, 10\,978, 10\,867, 10\,864).
$$

The stark change in the last five points is an evident shift.
However, with a minimum distance parameter of 20,
  we need additional 15 measurements to confirm this as a change point.
If this measurements are collected daily, it would take more than two weeks to detect this change.
In many practical situations, this delay is unacceptable, as swift reaction to recent changes is crucial.

### A Dual Approach to CPD

To address this, we can consider a dual strategy that combines two change point detectors.
The first one is a fast approximate algorithm that can effectively process the entire time series in a reasonable time.
The second one is a slow precise algorithm that targets only the most recent measurements.

### Handling the End of Time Series

In our specialized "last change point detection task,"
  we can afford to use more computationally intensive algorithms, as the amount of data is inherently limited.
By focusing on the last segment of the time series (say, the last 20 measurements),
  we can enumerate all potential change point positions and
  apply robust algorithms that might otherwise be impractical for longer series (e.g., $\mathcal{O}(N^3)$).
Truncating the left sample to around 50 data points should suffice
  to detect obvious and significant changes without performance concerns.

The choice of algorithm for this task depends on specific needs and contexts.
There are numerous CPD algorithms available, each with its strengths and trade-offs.
A good comparison of various CPD algorithms can be found in {{< link truong2020 >}}.
The key is to select one that aligns well with the nature of the data and the required sensitivity to recent shifts.

### Conclusion

Every CPD algorithm has its strengths and weaknesses.
Every algorithm fits its specific use cases.
The more I try to find a single algorithm that solves real-world problems without additional adjustments,
  the more I realize that there are no such algorithms.
When we adopt a purely mathematical approach, we inevitably face some corner cases or limitations.
In order to achieve a truly practical and useful implementation for a complicated real problem,
  we usually have to build a custom solution.
One of the possible customization strategies is to combine multiple approaches.

By employing a dual approach that combines fast algorithms for the entire series
  with more precise methods for the end segment, we can enhance our ability to detect recent changes efficiently.
This strategy ensures that we are not only well-informed about historical shifts in our data
  but also agile in responding to emerging trends and anomalies.
