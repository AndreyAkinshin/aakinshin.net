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
library(gridExtra)
library(evd)
library(ggplot2)
library(e1071)
library(rmutil)

rm(list = ls())

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

# Main
tukey <- function(x, k) {
  q <- quantile(x, c(0.25, 0.5, 0.75))
  iqr <- q[3] - q[1]
  l <- q[1] - k * iqr
  r <- q[3] + k * iqr
  c(l, r)
}
sf <- function(x, p, k) {
  q <- quantile(x, c(p, 0.5, 1 - p))
  l <- q[1] - k * (q[3] - q[1])
  r <- q[3] + k * (q[3] - q[1])
  c(l, r)
}
af <- function(x, p, k) {
  q <- quantile(x, c(p, 0.5, 1 - p))
  l <- q[1] - 2 * k * (q[2] - q[1])
  r <- q[3] + 2 * k * (q[3] - q[2])
  c(l, r)
}

build <- function(x, type, detector) {
  fences <- detector(x)
  is.outlier <- x < fences[1] | x > fences[2]
  data.frame(x, is.outlier, type)
}
build2 <- function(x) rbind(
  build(x, "Tukey/k=1.5", function(x) tukey(x, 1.5)),
  build(x, "Tukey/k=3.0", function(x) tukey(x, 3)),
  build(x, "SF/p=0.1/k=1.0", function(x) sf(x, 0.1, 1)),
  build(x, "SF/p=0.1/k=1.5", function(x) sf(x, 0.1, 1.5)),
  build(x, "SF/p=0.1/k=2.0", function(x) sf(x, 0.1, 2)),
  build(x, "SF/p=0.1/k=2.5", function(x) sf(x, 0.1, 2.5)),
  build(x, "SF/p=0.1/k=3.0", function(x) sf(x, 0.1, 3)),
  build(x, "SF/p=0.1/k=3.5", function(x) sf(x, 0.1, 3.5)),
  build(x, "SF/p=0.1/k=4.0", function(x) sf(x, 0.1, 4)),
  build(x, "AF/p=0.1/k=1.0", function(x) af(x, 0.1, 1)),
  build(x, "AF/p=0.1/k=1.5", function(x) af(x, 0.1, 1.5)),
  build(x, "AF/p=0.1/k=2.0", function(x) af(x, 0.1, 2)),
  build(x, "AF/p=0.1/k=2.5", function(x) af(x, 0.1, 2.5)),
  build(x, "AF/p=0.1/k=3.0", function(x) af(x, 0.1, 3)),
  build(x, "AF/p=0.1/k=3.5", function(x) af(x, 0.1, 3.5)),
  build(x, "AF/p=0.1/k=4.0", function(x) af(x, 0.1, 4))
)

run <- function(title, filename, x) {
  df <- build2(x)
  df$type <- factor(df$type)

  p1 <- ggplot(data.frame(x), aes(x)) +
    geom_density(bw = "SJ") +
    geom_rug(sides = "b") +
    ggtitle(title)
  show(p1)
  ggsave_nice(paste0(filename, "-den"), p1)

    p2 <- ggplot(df, aes(x, type, col = is.outlier)) +
    geom_point() +
    scale_color_manual(values = c(cbGreen, cbRed)) +
    ggtitle(title)
  show(p2)
  ggsave_nice(filename, p2)
}

set.seed(42)
lo <- -20:-1
ro <- 1:20
n <- 1000
run("Uniform with outliers", "unif", c(lo, runif(n, -1, 1), ro))
run("Normal with outliers", "norm", c(lo, rnorm(n), ro))
run("Gumbel with outliers", "gumbel", c(lo, rgumbel(n), ro))
run("Exponential with outliers", "exp", c(lo, rexp(n), ro))
run("Lognormal (mlog=0,sdlog=1) with outliers", "lnorm", c(lo, rlnorm(n, 0, 1), ro))
run("Frechet (shape=1) with outliers", "frechet", c(lo, rfrechet(n), ro))
run("Weibull (shape=0.3) with outliers", "weibull", c(lo, rweibull(n, 0.3), ro))
