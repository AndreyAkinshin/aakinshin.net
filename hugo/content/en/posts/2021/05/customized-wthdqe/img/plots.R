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
ggsave_nice <- function(name, plot = last_plot(), tm = theme_bw(), dark_and_light = TRUE, ext = "png", dpi = 300) {
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

alpha <- 0.95
iterations.total <- 10000
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
whd <- hdg(function(x, W) {
  n <- length(x)
  k <- (n - 1) %/% 2
  x[(n - k + 1):n] <- x[n - k]
  sum(W * x)
})
thd <- hdg(function(x, W) {
  n <- length(x)
  k <- (n - 1) %/% 2
  x <- x[1:(n-k)]
  W <- W[1:(n-k)] / sum(W[1:(n-k)])
  sum(W * x)
})

check <- function(title, n, rdist, qdist, qest) {
  true.median <- qdist(0.5)
  values <- c()
  for (i in 1:iterations.total) {
    sample <- rdist(n)
    est.median <- qest(sample, 0.5)
    values <- c(values, est.median)
  }
  data.frame(estimator = title, x = values)
}
checku <- function(title, n, rdist, qdist) {
  true.median <- qdist(0.5)
  df <- rbind(
    check("hf7", n, rdist, qdist, function(x, p) hf7(x, p)),
    check("hd", n, rdist, qdist, function(x, p) hd(x, p)),
    check("whd", n, rdist, qdist, function(x, p) whd(x, p)),
    check("thd", n, rdist, qdist, function(x, p) thd(x, p))
  )
  df$estimator <- factor(df$estimator, c("hf7", "hd", "whd", "thd"))
  p <- ggplot(df, aes(x = x, col = estimator)) +
    geom_vline(xintercept = qdist(0.5), col = cbGrey) +
    geom_density(bw = "SJ") +
    scale_x_continuous(limits = c(0, qdist(0.9)), breaks = seq(0, 20, by = 1)) +
    scale_color_manual(values = cbPalette) +
    labs(x = "estimations", title = paste0("Estimation PDF for ", title, " distribution (n = ", n, ")"))
  ggsave_nice(paste0(title, n), p)
  show(p)
  df0 <- df %>%
    mutate(e = abs(x - true.median)) %>%
    group_by(estimator) %>%
    summarise(
      bias = mean(x - true.median),
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
checku.norm <- function(n) checku("normal", n, function(n) rnorm(n), function(p) qnorm(p))
checku.pareto <- function(n) checku("pareto", n, function(n) rpareto(n, 1), function(p) qpareto(p, 1))

set.seed(42)
checku.norm(5)
checku.pareto(3)
checku.pareto(4)
checku.pareto(5)
checku.pareto(6)
checku.pareto(7)

draw.pareto <- function() {
  x <- seq(0, 10, by = 0.001)
  y <- dpareto(x, 1)
  ggplot(data.frame(x, y), aes(x, y)) +
    geom_line(col = cbRed) +
    labs(title = "Pareto distribution (xm = 1, alpha = 1)", y = "density")
  ggsave_nice("pareto-pdf")
}
draw.pareto()