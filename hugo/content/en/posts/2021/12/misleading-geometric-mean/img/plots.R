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

x <- seq(0, 1, by = 0.001)
y <- dweibull(x, 0.1)
ggplot(data.frame(x, y), aes(x, y)) +
  geom_line() +
  ggtitle("Density of the Weibull distribution (scale=1, shape=0.1)")
ggsave_nice("weibull")

gm <- function(x) exp(mean(log(x)))
set.seed(42)
u <- sort(replicate(1000, gm(runif(100)) / gm(runif(100))))
head(u, 5)
tail(u, 5)

set.seed(42)
u <- sort(replicate(1000, gm(rweibull(100, 0.1)) / gm(rweibull(100, 0.1))))
head(u, 5)
tail(u, 5)

