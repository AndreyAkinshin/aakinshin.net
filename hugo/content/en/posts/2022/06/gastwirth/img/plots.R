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
library(purrr)
library(EnvStats)

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

# Functions
hlme <- function(x, f) {
  n <- length(x)
  df <- expand.grid(i = 1:n, j = 1:n)
  df <- df[f(df$i, df$j),]
  df$r <- (x[df$i] + x[df$j]) / 2
  median(df$r)
}
hl1me <- function(x) hlme(x, function(i, j) i < j)
location <- function(x) c(
  median = median(x),
  gastwirth = sum(quantile(x, c(1/3, 0.5, 2/3)) * c(0.3, 0.4, 0.3)),
  harrell.davis = as.numeric(hdquantile(x, 0.5)),
  hodges.lehmann = hl1me(x)
)

# Main
build.df <- function(name, rdist, n) {
  df <- data.frame(t(replicate(30000, location(rdist(n))))) %>% gather("estimator", "value")
  df$n <- n
  df$distribution <- name
  df
}
build.df2 <- function(name, rdist) {
  rbind(build.df(name, rdist, 5), build.df(name, rdist, 10), build.df(name, rdist, 20))
}
set.seed(1729)
df <- rbind(
  build.df2("Normal", rnorm),
  build.df2("Cauchy", rcauchy)
)
ggplot(df, aes(value, col = estimator)) +
  facet_grid(vars(distribution), vars(n), scales = "free") +
  geom_density(bw = "SJ") +
  scale_color_manual(values = cbPalette) +
  xlim(-2, 2) +
  xlab("estimation")
ggsave_nice("estimators")
