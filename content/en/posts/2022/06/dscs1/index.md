---
title: Dynamical System Case Study 1 (symmetric 3d system)
thumbnail: sim3-color-dark
date: 2022-06-05
tags:
- Mathematics
- Dynamical Systems
features:
- math
---

Let's consider the following dynamical system:

$$
\begin{cases}
  \dot{x}_1 = f(x_3) - x_1,\\
  \dot{x}_2 = f(x_1) - x_2,\\
  \dot{x}_3 = f(x_2) - x_3,
\end{cases}
$$

where $f(x) = \alpha / (1+x^m)$ is a Hill function.
In this case study, we explore the phase portrait of this system for $\alpha = 18,\; m = 3$.

<!--more-->

### Preparation

First of all, let's find the stationary point of this system.
Since in such point $\dot{x}_1=\dot{x}_2=\dot{x}_3=0$, we have the following equation:

$$
x_1 = f(f(f((x_1)))).
$$

Since $x_1$ is monotonically increasing and $f(f(f(x_1))))$ is monotonically decreasing,
  this equation has exactly one solution.
It's easy to see that this solution is $x_0=x_1=x_2=x_3=2$.

Next, we build the corresponding linearization matrix:

$$
M = \begin{bmatrix}
-1 & 0 & f'(x_0)\\
f'(x_0) & -1 & 0\\
0 & f'(x_0) & -1
\end{bmatrix}.
$$

Since $f'(x) = -\alpha m x^{m - 1} / (x ^ m + 1)^2$, we have:

$$
f'(x_0) = -18 * 3 * 2^2 / (2^3+1)^2 = -216 / 81 = -8/3 \approx -2.66667.
$$

Thus,

$$
M = \begin{bmatrix}
-1 & 0 & -8/3\\
-8/3 & -1 & 0\\
0 & 8/3 & -1
\end{bmatrix}.
$$

Now we can get the eigenvalues $\lambda_i$ and eigenvectors $e_i$:

$$
\lambda_1 \approx -3.666667,\quad
\lambda_2 \approx 0.333333+2.309401i,\quad
\lambda_3 \approx 0.333333-2.309401i,
$$

$$
\begin{bmatrix} e_1 \\ e_2 \\ e_3 \end{bmatrix} =
\begin{bmatrix}
-0.5773503,      & -0.5773503,      & -0.5773503\\
-0.2886751+0.5i, & -0.2886751-0.5i, &  0.5773503\\
-0.2886751-0.5i, & -0.2886751+0.5i, &  0.5773503
\end{bmatrix}.
$$

The most expressive phase portrait could be obtained using a projection on $(e_2, e_3)$ or
  $(\Re(e_2), \Im(e_2)) = (\Re(e_3), -\Im(e_3))$.

### Phase portraits

In order to explore phase portraits, we perform several simulation studies.
In each simulation, we generate several trajectories from random start points and draw three plots:
1. A projection of simulated trajectories on $(\Re(e_2), \Im(e_2))$.
   Each trajectory has own color from a rainbow palette.
   The limit cycle is shown using the black color.
2. A projection of simulated trajectories on $(\Re(e_2), \Im(e_2))$.
   For each trajectory point, the color defines the current speed ($\sqrt{\dot{x}_1^2+\dot{x}_2^2+\dot{x}_3^2}$).
   The limit cycle is shown using the black color.
   The beginning of each trajectory is drop in order to provide a more consistent picture.
3. A 3D projection of simulation trajectories on $(e1_, \Re(e_2), \Im(e_2))$.
   These visualizations are heavy, so you should click on "Show 3D plot" in order to explore the plot.

#### Simulation 1 (10 trajectories)

In this simulation, we generate 10 trajectories from random start points around the stationary point
  uniformly taken in $(x_1, x_2, x_3)$.

{{< imgld sim1-simple >}}

{{< imgld sim1-color >}}

{{< iframe sim1 "Show 3D plot" >}}

#### Simulation 2 (100 trajectories)

In this simulation, we generate 100 trajectories from random start points around the stationary point
  uniformly taken in $(x_1, x_2, x_3)$.

{{< imgld sim2-simple >}}

{{< imgld sim2-color >}}

{{< iframe sim2 "Show 3D plot" >}}

#### Simulation 3 (500 trajectories)

In this simulation, we generate 500 trajectories from random start points around the stationary point
  uniformly taken in $(e_1, e_2, e_3)$.

{{< imgld sim3-simple >}}

{{< imgld sim3-color >}}

{{< iframe sim3 "Show 3D plot" >}}

### Source code

{{< src "main.R" >}}
