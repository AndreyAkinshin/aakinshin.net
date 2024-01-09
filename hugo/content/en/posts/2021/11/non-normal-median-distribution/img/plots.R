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

# Utils
draw.f <- function(title, pdf, xlims) {
  x <- seq(xlims[1], xlims[2], by = 0.01)
  y <- pdf(x)
  ggplot(data.frame(x, y), aes(x, y)) +
    geom_line() +
    labs(title = title, x = "x", y = "density")
}
draw.rg <- function() {
  x <- seq(-3, 3, by = 0.01)
  y <- dnorm(x)
  y[x < 0] <- 0
  ggplot(data.frame(x, y), aes(x, y)) +
    geom_line(col = cbRed) +
    geom_segment(x = 0, y = 0, xend = 0, yend = 1, col = cbRed) +
    geom_point(x = 0, y = 1, shape = 17, col = cbRed, size = 3) +
    annotate("text", x = 0, y = 0.95, hjust = -0.3, label = "0.5", col = cbRed) +
    ggtitle("Density of the rectified Gaussian distribution") +
    ylab("density") +
    xlim(-3, 3) + ylim(0, 1)
}
draw1 <- function(title, rnd) {
  x <- sapply(1:10000, function(i) median(rnd()))
  ggplot(data.frame(x), aes(x)) +
    geom_density(bw = "SJ") +
    ggtitle(paste0("Density of sample medians (", title, ")"))
}
draw2 <- function(title, rnd, m, var) {
  df1 <- density(sapply(1:10000, function(i) median(rnd())))
  df2 <- data.frame(
    x = seq(0, 3, by = 0.01),
    y = dnorm(seq(0, 3, by = 0.01), m, sqrt(var))
  )
  df <- rbind(
    data.frame(x = df1$x, y = df1$y, type = "Sampling distribution"),
    data.frame(x = df2$x, y = df2$y, type = "Theoretical expectation")
  )
  ggplot(df, aes(x, y, col = type)) +
    geom_line() + 
    labs(
      title = paste0("Density of sample medians (", title, ")"),
      col = "",
      x = "sample median",
      y = "density") +
    scale_color_manual(values = cbPalette)
}

# Drawing
set.seed(1729)

draw.f("Density of the exponential distribution", dexp, c(0, 5))
ggsave_nice("exp-pdf")

draw2("Exponential distribution, n = 50",
      function() rexp(50), log(2), 1 / (4 * 50 * dexp(log(2))^2))
ggsave_nice("exp-medians1")

draw2("Exponential distribution, n = 5",
      function() rexp(5), log(2), 1 / (4 * 5 * dexp(log(2))^2))
ggsave_nice("exp-medians2")

draw.f(
  "Density of a bimodal distribution",
  function(x) dunif(x, -2, -1) + dunif(x, 1, 2),
  c(-3, 3))
ggsave_nice("bi-pdf")
draw1("Bimodal distribution",
      function() ifelse(sample(0:1, 10, T), runif(10, -2, -1), runif(10, 1, 2)))
ggsave_nice("bi-medians")

draw.rg()
ggsave_nice("rg-pdf")
draw1("Rectified Gaussian distribution",
      function() pmax(rnorm(10), 0)) + ylim(0, 5)
ggsave_nice("rg-medians")
