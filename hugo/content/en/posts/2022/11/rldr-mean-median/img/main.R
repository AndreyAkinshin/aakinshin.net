# Scripts ----------------------------------------------------------------------
source("utils.R")

# Settings ---------------------------------------------------------------------
settings <- list(
)

# Functions --------------------------------------------------------------------

# Data -------------------------------------------------------------------------

# Tables -----------------------------------------------------------------------

# Figures ----------------------------------------------------------------------
figure_bimodal1 <- function() {
  x <- seq(-1, 5, by = 0.01)
  y <- ifelse((x >= 0 & x <= 1) | (x >= 2 & x <= 3), 0.5, 0)
  ggplot(data.frame(x, y), aes(x, y)) +
    geom_line() +
    labs(title = "Original bimodal distribution", y = "Density")
}

figure_bimodal2 <- function() {
  rbi <- function(n) runif(n) + sample(0:1, n, TRUE) * 2
  medians <- replicate(10000, median(rbi(100)))
  ggplot(data.frame(x = medians), aes(x)) +
    geom_density(bw = "SJ") +
    labs(title = "Median sampling distribution", y = "Density", x = "Median value")
}

figure_resistance <- function() {
  xk <- function(n, k) c(rep(0, k), rep(1, n - k))
  R <- function(estimator, n, s, k) abs(estimator(xk(n, k)) - estimator(xk(n, k - s)))
  RR <- function(estimator, n, s) max(sapply(s:n, function(k) R(estimator, n, s, k)))
  
  build_df <- function(title, estimator, s) {
    ns <- max(2, s):100
    data.frame(
      title = title,
      n = ns,
      s = s,
      r = sapply(ns, function(n) RR(estimator, n, s))
    )
  }
  
  build_df2 <- function(title, estimator) {
    ss <- 1:6
    do.call("rbind", lapply(ss, function(s) build_df(title, estimator, s)))
  }
  
  df <- rbind(
    build_df2("Mean", mean),
    build_df2("Median", median)
  )
  ggplot(df, aes(n, r, col = title)) +
    facet_wrap(vars(s), ncol = 3) +
    geom_point() +
    scale_color_manual(values = cbp$values) +
    labs(title = "Resistance to the low density regions",
         col = "Estimator",
         x = "Sample size (n)",
         y = "Resistance function") +
    theme(legend.position = "bottom")
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
