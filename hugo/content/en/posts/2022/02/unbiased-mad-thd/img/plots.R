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
df <- read.csv("../data/thd-sqrt.csv")
df$bias <- 1 - 1 / df$factor / qnorm(0.75)
df.train <- df[df$n >= 100,]
fit <- lm(bias ~ 0 + I(n^(-1)) + I(n^(-2)), data = df.train)
fit
a <- fit$coefficients[1]
b <- fit$coefficients[2]
df.plot <- data.frame(n = df.train$n, actual = df.train$factor)
df.plot$predicted <- 1 / (qnorm(0.75) * (1 - a / df.plot$n + b / df.plot$n^2)) 
ggplot(df.plot %>% gather("metric", "value", -n), aes(n, value, col = metric)) +
  geom_point() +
  geom_line(alpha = 0.5) +
  ggtitle("Factors for the trimmed Harrell-Davis quantile estimator") +
  geom_hline(yintercept = 1 / qnorm(0.75), col = cbNavy) +
  ylab("factor")
ggsave_nice("factors")