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
  sum(x < l | x > r) > 0
}
ad <- function(x, k) {
  q <- quantile(x, c(0.1, 0.5, 0.9))
  l <- q[1] - k * (q[2] - q[1])
  r <- q[3] + k * (q[3] - q[2])
  sum(x < l | x > r) > 0
}

run <- function(filename, distrname, rnd, rep = 1000) {
  set.seed(42)
  sim <- function(n) c(
    n = n,
    ad10 = sum(replicate(rep, ad(rnd(n), 1.0))) / rep,
    ad15 = sum(replicate(rep, ad(rnd(n), 1.5))) / rep,
    ad20 = sum(replicate(rep, ad(rnd(n), 2.0))) / rep,
    ad25 = sum(replicate(rep, ad(rnd(n), 2.5))) / rep,
    ad30 = sum(replicate(rep, ad(rnd(n), 3.0))) / rep,
    ad30 = sum(replicate(rep, ad(rnd(n), 3.5))) / rep
  )
  ns <- c(seq(6, 48, by = 2), seq(50, 90, by = 10), seq(100, 500, by = 50))
  df <- data.frame(t(sapply(ns, sim))) %>% gather("method", "value", -n)
  p <- ggplot(df, aes(n, value, col = method)) +
    geom_line() +
    scale_x_continuous(breaks = seq(0, max(ns), length.out = 11), limits = c(0, max(ns))) +
    scale_y_continuous(breaks = seq(0, 1, by = 0.05), limits = c(0, 1)) +
    scale_color_manual(values = cbPalette, labels = c("1.0", "1.5", "2.0", "2.5", "3.0", "3.5")) +
    labs(x = "Sample Size", y = "Probability", col = "k",
         title = paste0("Probability of observing outliers / ",distrname))
  show(p)
  ggsave_nice(filename, p)
}
run("normal", "Normal distribution", rnorm)
run("gumbel", "Gumbel distribution", rgumbel)
run("exp", "Exponential distribution", rexp)