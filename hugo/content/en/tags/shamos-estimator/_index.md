---
title: Shamos Estimator
features:
- math
---

Suggested in {{< link shamos1976 >}} (page 260), a robust measure of scale/spread.

For a sample $\mathbf{x} = \{ x_1, x_2, \ldots, x_n \}$, it is defined as follows:

$$
\operatorname{Shamos}_n = C_n \cdot \underset{i < j}{\operatorname{median}} (|x_i - x_j|),
$$

where $\operatorname{median}$ is a median estimator, $C_n$ is a scale factor,
  which is usually used to make the estimator consistent
  for the standard deviation under the normal distribution.
The asymptotic consistency factor: $C_\infty \approx 1.048358$.
The asymptotic Gaussian efficiency is of $\approx 86\%$; the asymptotic breakdown point is of $\approx 29\%$.
The finite-sample consistency factor and efficiency values can be found in {{< link park2020 >}}.

In {{< link rousseeuw1993 >}},
  it is claimed that the Rousseeuw-Croux estimator is a good alternative with much higher breakdown point of $50\%$
  and slightly decorated statistical efficiency (the asymptotic value is of $\approx 82%$).
However, for small samples the [efficiency gap]({{< ref shamos-vs-qn>}}) is huge, so I prefer the Shamos estimator.