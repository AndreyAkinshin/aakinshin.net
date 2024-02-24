library(effsize)
library(Hmisc)
library(tidyr)
library(ggplot2)
library(ggdark)
library(svglite)
library(plyr)
library(dplyr)
library(latex2exp)
library(knitr)
library(stringr)
library(jsonlite)

rm(list = ls())

# Parameters
DEPS <- 0.06 # Default Planck-taper window eps
INT.EPS <- 1e-6 # Integration eps
QRDE.STEP <- 0.001

# Helpers
cbRed <- "#D55E00"; cbBlue <- "#56B4E9"; cbGreen <- "#009E73"; cbOrange <- "#E69F00"
cbNavy <- "#0072B2"; cbPink <- "#CC79A7"; cbYellow <- "#F0E442"; cbGrey <- "#999999"
cbPalette <- c(cbRed, cbBlue, cbGreen, cbOrange, cbNavy, cbPink, cbYellow, cbGrey)
ggsave_nice <- function(name, plot = last_plot(), tm = theme_bw(), dark_and_light = T, ext = "png", dpi = 200) {
  width <- 1.5 * 1600 / dpi
  height <- 1.5 * 900 / dpi
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

# CDF of Planck-taper windowed Beta function
pbeta2 <- function(q, shape1, shape2, l, r, eps) sapply(q, function(q0) {
  if (q0 <= l)
    return(0)
  if (q0 >= r)
    return(1)
  if (shape1 == 0 || shape2 == 0)
    return(pbeta(q0, shape1, shape2))
  
  # Planck-taper window on [0;1]
  ptw <- Vectorize(function(x) {
    if (x > 0.5)
      return(ptw(1 - x))
    if (x > eps)
      return(1)
    return(1 / (1 + exp(eps / x - eps / (eps - x))))
  })
  
  f1 <- function(x) dbeta(x, shape1, shape2)
  f2 <- function(x) ifelse(l < x & x < r, ptw((x - l) / (r - l)), 0)
  
  f3.raw <- function(x) f1(x) * f2(x)
  f3.raw.area <- integrate(f3.raw, 0, 1, rel.tol = INT.EPS)$value
  f3 <- function(x) f3.raw(x) / f3.raw.area
  F3 <- function(x) integrate(f3, l, x, rel.tol = INT.EPS)$value
  return(F3(q0))
})

getBetaHdi <- function(a, b, width) {
  eps <- 1e-9
  if (a < 1 + eps & b < 1 + eps) # Degenerate case
    return(c(NA, NA))
  if (a < 1 + eps & b > 1) # Left border case
    return(c(0, width))
  if (a > 1 & b < 1 + eps) # Right border case
    return(c(1 - width, 1))
  if (width > 1 - eps)
    return(0, 1)
  
  # Middle case
  mode <- (a - 1) / (a + b - 2)
  pdf <- function(x) dbeta(x, a, b)
  
  l <- uniroot(
    f = function(x) pdf(x) - pdf(x + width),
    lower = max(0, mode - width),
    upper = min(mode, 1 - width),
    tol = 1e-9
  )$root
  r <- l + width
  return(c(l, r))
}

thd <- function(x, probs) sapply(probs, function(p) {
  x <- sort(x)
  n <- length(x)
  a <- (n + 1) * p
  b <- (n + 1) * (1 - p)
  width <- sqrt(n) / n
  hdi <- getBetaHdi(a, b, width)
  window <- pbeta(hdi, a, b)
  cdf <- function(xs) sapply(xs, function(x) {
    if (x <= hdi[1])
      return(0)
    if (x >= hdi[2])
      return(1)
    return((pbeta(x, a, b) - window[1]) / (window[2] - window[1]))
  })
  cdfs <- cdf(0:n/n)
  W <- tail(cdfs, -1) - head(cdfs, -1)
  sum(x * W)
})
thd2 <- function(x, probs) sapply(probs, function(p) {
  x <- sort(x)
  n <- length(x)
  a <- (n + 1) * p
  b <- (n + 1) * (1 - p)
  width <- sqrt(n) / n
  hdi <- getBetaHdi(a, b, width)
  cdf <- function(x) pbeta2(x, a, b, hdi[1], hdi[2], DEPS)
  cdfs <- cdf(0:n/n)
  W <- tail(cdfs, -1) - head(cdfs, -1)
  sum(x * W)
})

qrde.df <- function(x, qe, title = "", step = QRDE.STEP) {
  probs <- seq(step, 1 - step, by = step)
  q <- qe(x, probs)
  n <- length(x)
  
  x <- c()
  y <- c()
  factor <- 1 / (length(q) - 1)
  for (i in 1:(length(q) - 1)) {
    ql <- q[i]
    qr <- q[i + 1]
    h <- factor / (qr - ql)
    x <- c(x, ql, qr)
    y <- c(y, h, h)
  }
  return(data.frame(x, y, title, n))
}

draw.qrde <- function() {
  
  build.df <- function(n) {
    set.seed(42)
    x <- rnorm(n)
    rbind(
      qrde.df(x, hdquantile, "HD"),
      qrde.df(x, thd, "THD-SQRT"),
      qrde.df(x, thd2, "THD-SQRT*")
    )
  }
  
  df <- rbind(
    build.df(10),
    build.df(13)
  )
  
  ggplot(df) +
    geom_line(aes(x, y, col = title)) +
    #geom_rug(data = data.frame(x = x, y = 0), aes(x, y), sides = "b") +
    scale_color_manual(values = c(cbGreen, cbBlue, cbRed)) + 
    facet_wrap(vars(n), labeller = label_both, scales = "free") +
    labs(x = "values", y = "density", col = "Estimator",
         title = "Quantile-respectful density estimation")
  ggsave_nice("qrde")
}

draw.ptw <- function(eps = 0.1) {
  ptw <- Vectorize(function(x) {
    if (x > 0.5)
      return(ptw(1 - x))
    if (x > eps)
      return(1)
    return(1 / (1 + exp(eps / x - eps / (eps - x))))
  })
  x <- seq(0, 1, by = 0.001)
  y <- ptw(x)
  ggplot(data.frame(x, y), aes(x, y)) +
    geom_area(fill = cbRed, alpha = 0.4) +
    labs(y = "",
         title = paste0("Planck-taper window (ε=", eps, ")"))
  ggsave_nice("ptw")
}

draw.qrde()
draw.ptw()