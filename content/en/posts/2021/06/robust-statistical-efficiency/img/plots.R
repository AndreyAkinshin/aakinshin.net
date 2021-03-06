library(effsize)
library(Hmisc)
library(tidyr)
library(ggplot2)
library(ggdark)
library(svglite)
library(latex2exp)
library(knitr)
library(EnvStats)
library(dplyr)

cbRed <- "#D55E00"; cbBlue <- "#56B4E9"; cbGreen <- "#009E73"; cbOrange <- "#E69F00"
cbNavy <- "#0072B2"; cbPink <- "#CC79A7"; cbYellow <- "#F0E442"; cbGrey <- "#999999"
cbPalette <- c(cbRed, cbBlue, cbGreen, cbOrange, cbNavy, cbPink, cbYellow, cbGrey)
ggsave_nice <- function(name, plot = last_plot(), tm = theme_bw(), dark_and_light = T, ext = "png", dpi = 300) {
  width <- 1600 / dpi
  height <- 900 / dpi
  if (dark_and_light) {
    old_theme <- theme_set(tm)
    ggsave(paste0(name, "-light.", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(dark_mode(tm, verbose = FALSE))
    ggsave(paste0(name, "-dark.", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(old_theme)
    invert_geom_defaults()
  } else {
    old_theme <- theme_set(tm)
    ggsave(paste0(name, ".", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(old_theme)
  }
}

iterations.total <- 20000
TQ <- 0.5
options(digits = 5)

hdg <- function(f) function(x, probs) sapply(probs, function(p) {
  x <- sort(x)
  n <- length(x)
  cdf.probs <- (0:n) / n
  cdfs <- pbeta(cdf.probs, (n + 1) * p, (n + 1) * (1 - p))
  W <- tail(cdfs, -1) - head(cdfs, -1)
  f(x, W)
})
hf7 <- function(x, probs) quantile(x, probs)
hd <- hdg(function(x, W) sum(W * x))
sv1 <- function(x, probs) {
  n <- length(x)
  if (n <= 2)
    return(quantile(x, probs))
  x <- sort(x)
  sapply(probs, function(p) {
    B <- function(x) dbinom(x, n, p)
    B(0) * (x[1] + x[2] - x[3]) / 2 +
      sum(sapply(1:n, function(i) (B(i) + B(i - 1)) * x[i] / 2)) +
      B(n) * (-x[n-2] + x[n-1] + x[n]) / 2
  })
}
no <- function(x, probs) {
  n <- length(x)
  if (n <= 2)
    return(quantile(x, probs))
  x <- sort(x)
  sapply(probs, function(p) {
    B <- function(x) dbinom(x, n, p)
    (B(0) * 2 * p + B(1) * p) * x[1] +
      B(0) * (2 - 3 * p) * x[2] -
      B(0) * (1 - p) * x[3] +
      sum(sapply(1:(n-2), function(i)
        (B(i) * (1 - p) + B(i + 1) * p) * x[i + 1])) -
      B(n) * p * x[n - 2] +
      B(n) * (3 * p - 1) * x[n - 1] +
      (B(n - 1) * (1 - p) + B(n) * (2 - 2 * p)) * x[n]
  })
}

check <- function(title, n, rdist, qdist, qest) {
  true.quantile <- qdist(TQ)
  values <- c()
  for (i in 1:iterations.total) {
    sample <- rdist(n)
    est.quantile <- qest(sample, TQ)
    values <- c(values, est.quantile)
  }
  data.frame(estimator = title, x = values)
}
checku <- function(seed, title, n, rdist, qdist) {
  set.seed(seed)

  true.quantile <- qdist(TQ)
  df <- rbind(
    check("hf7", n, rdist, qdist, function(x, p) hf7(x, p)),
    check("hd", n, rdist, qdist, function(x, p) hd(x, p)),
    check("sv1", n, rdist, qdist, function(x, p) sv1(x, p)),
    check("no", n, rdist, qdist, function(x, p) no(x, p))
  )
  estimators <- c("hf7", "hd", "sv1", "no")
  df$estimator <- factor(df$estimator, estimators)
  # p1 <- ggplot(df, aes(x = x, col = estimator)) +
  #   geom_vline(xintercept = qdist(TQ), col = cbGrey) +
  #   geom_density(bw = "SJ") +
  #   scale_x_continuous(limits = c(0, qdist(0.9)), breaks = seq(0, 20, by = 1)) +
  #   scale_color_manual(values = cbPalette) +
  #   labs(x = "estimations", title = paste0("Estimation PDF for ", title, " distribution (n = ", n, ")"))
  # ggsave_nice(paste0(title, n), p1)
  # show(p1)

  probs <- seq(0.01, 0.99, by = 0.001)
  estQuant <- function(estimator) data.frame(
    estimator = estimator,
    probs = probs,
    value = hdquantile(abs(df[df$estimator == estimator,]$x - true.quantile), probs)
  )
  df1 <- rbind(estQuant("hf7"), estQuant("hd"), estQuant("sv1"), estQuant("no"))
  df1$estimator <- factor(df1$estimator, estimators)
  p2 <- ggplot(df1, aes(probs, value, col = estimator)) +
    geom_hline(yintercept = 0, col = cbGrey) +
    geom_line() +
    ylim(min(df1$value), min(max(df1$value), 20)) +
    scale_color_manual(values = cbPalette) +
    scale_x_continuous(breaks = seq(0, 1, by = 0.1)) +
    labs(y = "absolute error", x = "quantile",
         title = paste0(title, " distribution, n = ", n))
  ggsave_nice(paste0(title, n, "-seed", seed), p2)
  show(p2)

  df0 <- df %>%
    mutate(e = abs(x - true.quantile)) %>%
    group_by(estimator) %>%
    summarise(
      # bias = mean(x - true.quantile),
      mse = sum(e^2) / iterations.total,
      p25 = hdquantile(e, 0.25),
      p50 = hdquantile(e, 0.50),
      p75 = hdquantile(e, 0.75),
      p90 = hdquantile(e, 0.90),
      p95 = hdquantile(e, 0.95),
      p99 = hdquantile(e, 0.99)
    )
  print(df0, row.names = F)
}
checku.norm <- function(seed, n) checku(seed, "normal", n, function(n) rnorm(n), function(p) qnorm(p))
checku.unif <- function(seed, n) checku(seed, "uniform", n, function(n) runif(n), function(p) qunif(p))
checku.pareto <- function(seed, n) checku(seed, "pareto", n, function(n) rpareto(n, 1), function(p) qpareto(p, 1))

checku.unif(1, 3)
checku.norm(1, 3)

checku.pareto(1, 3)
checku.pareto(2, 3)
checku.pareto(3, 3)
