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

source("../src/simulation.R")

draw <- function(prob, alpha) {
  df <- check.all(prob, alpha)
  p <- ggplot(df %>% gather("estimator", "coverage", 3:4)) +
    geom_hline(yintercept = alpha, linetype = "dashed", col = cbGrey) +
    geom_line(aes(n, coverage, col = estimator)) +
    facet_wrap(vars(name), ncol = 4) +
    labs(
      title = paste0("Observed coverage of ", alpha * 100, "% confidence intervals (P", prob * 100, ")"),
      col = "CI Estimator") +
    scale_color_manual(values = c(cbRed, cbGreen))
  filename <- paste0("coverage-p", prob * 100, "-a", alpha * 100)
  ggsave_nice(filename, p, dpi = 200)
}

set.seed(42)
for (prob in c(0.25, 0.5, 0.75, 0.9))
  for (alpha in c(0.9, 0.95, 0.99))
    draw(prob, alpha)