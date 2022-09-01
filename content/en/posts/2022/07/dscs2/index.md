---
title: Dynamical System Case Study 2 (Piecewise linear LLL-system)
date: 2022-07-17
tags:
- mathematics
- dynamical-systems
- research
- case-study
features:
- math
---

We consider the following dynamical system:

$$
\begin{cases}
  \dot{x}_1 = L(a_1, k_1, x_3) - k_1 x_1,\\
  \dot{x}_2 = L(a_2, k_2, x_1) - k_2 x_2,\\
  \dot{x}_3 = L(a_3, k_3, x_2) - k_3 x_3,
\end{cases}
$$

where $L$ is a piecewise linear function:

$$
L(a, k, x) = \begin{cases}
ak & \quad \textrm{for}\; 0 \leq x \leq 1,\\
0 & \quad \textrm{for}\; 1 < x.
\end{cases}
$$

In this case study, we build a [Shiny](https://shiny.rstudio.com/) application that draws 3D phase portraits of this system for various sets of input parameters.

{{< imgld screen >}}

<!--more-->

### Shiny app parameters

The application allows controlling the following parameters:

* $a_1$, $a_2$, $a_3$, $k_1$, $k_2$, $k_3$: the dynamical system parameter.
* $\textrm{TotalTime}$: the total time simulation.
* $\textrm{SkipTime}$: the initial time interval that will not be presented on the plot.
* $N$: the number of simulated trajectories.
* $\textrm{Seed}$: the randomization seed that controls the initial positions of all the trajectories.

We uniformly generate the initial point for each simulated trajectory from the following area:

$$
[0.5; (2+a_1)/3]
\times
[0.5; (2+a_2)/3]
\times
[0.5; (2+a_3)/3].
$$

### Source code

The source code is also available on GitHub: https://github.com/AndreyAkinshin/pwLLL

**core.R**:

{{< src "core.R" >}}

**server.R**:

{{< src "server.R" >}}

**ui.R**:

{{< src "ui.R" >}}
