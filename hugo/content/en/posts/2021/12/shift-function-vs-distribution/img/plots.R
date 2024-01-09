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
draw <- function(name, title, f, r, col) {
  x <- seq(r[1], r[2], by = 0.01)
  y <- f(x)
  p <- ggplot(data.frame(x, y), aes(x, y)) +
    geom_line(col = col) +
    ggtitle(title) +
    ylim(min(y, 0), NA)
  show(p)
  ggsave_nice(name, p)
}
draw.shift <- function(index, comment, f) {
  draw(paste0("shift", index), paste0("Shift function between ", comment), f, c(0, 1), cbGreen)
}
draw.distr <- function(index, comment, f, r) {
  draw(paste0("distr", index), paste0("Density of the shift distribution between ", comment), f, r, cbRed)
}

draw.shift(1, "N(0,1) and N(0,1)", function(x) 0)
draw.distr(1, "N(0,1) and N(0,1)", function(x) dnorm(x, sd = sqrt(2)), c(-3, 3))

draw.shift(2, "N(0,1) and N(2,1)", function(x) 2)
draw.distr(2, "N(0,1) and N(2,1)", function(x) dnorm(x, mean = 2, sd = sqrt(2)), c(-1, 5))

draw.shift(3, "N(0,1) and N(100,1)", function(x) 100)
draw.distr(3, "N(0,1) and N(100,1)", function(x) dnorm(x, mean = 100, sd = sqrt(2)), c(97, 103))

draw.shift(4, "U(0,1) and U(-1,0)", function(x) 1)
draw.distr(4, "U(0,1) and U(-1,0)", function(x) ifelse(x < 1, x, 2 - x), c(0, 2))