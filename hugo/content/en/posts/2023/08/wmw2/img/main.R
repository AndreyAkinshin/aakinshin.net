# Scripts ----------------------------------------------------------------------
source("utils.R")

# Functions --------------------------------------------------------------------
wmw <- function(x, y, w = rep(1, length(x)), v = rep(1, length(y))) {
  # Weighted Mann-Whitney U-statistic (alternative = "greater")
  w <- w / sum(w)
  v <- v / sum(v)
  index <- expand.grid(i = 1:length(x), j = 1:length(y))
  S <- function(a, b) (sign(a - b) + 1) / 2
  sum(S(x[index$i], y[index$j]) * w[index$i] * v[index$j])
}

rmix <- function(n, m) c(rnorm(n, 10), rnorm(m, 20))
rmix1 <- function(n, k) rmix(k, n - k)
rmix2 <- function(n, k) rmix(n - k, k)
fw <- function(n, k) c(rep(0.5 / k, k), rep(0.5 / (n - k), n - k))
fv <- function(n, k) c(rep(0.5 / (n - k), n - k), rep(0.5 / k, k))

wmw_sim <- function(n, k, rep = 10000) {
  w <- fw(n, k)
  v <- fv(n, k)
  replicate(rep, wmw(rmix1(n, k), rmix2(n, k), w, v))
}

# Figures ----------------------------------------------------------------------
figure_den <- function() {
  df <- do.call("rbind", lapply(c(10, 25, 100, 500), \(n) data.frame(n, x = wmw_sim(n, 1))))
  ggplot(df, aes(x, col = factor(n))) +
    geom_density(bounds = c(0, 1)) +
    scale_color_manual(values = cbp$values) +
    xlim(0, 1) +
    labs(x = "U", y = "Density", col = "N (Sample size)")
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
