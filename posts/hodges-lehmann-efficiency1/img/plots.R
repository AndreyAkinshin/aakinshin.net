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
hdme <- function(x) as.numeric(hdquantile(x, 0.5))
hlme <- function(x, f) {
  n <- length(x)
  df <- expand.grid(i = 1:n, j = 1:n)
  df <- df[f(df$i, df$j),]
  df$r <- (x[df$i] + x[df$j]) / 2
  median(df$r)
}
hl1me <- function(x) hlme(x, function(i, j) i < j)
hl2me <- function(x) hlme(x, function(i, j) i <= j)
hl3me <- function(x) hlme(x, function(i, j) T)

# Main
gen <- function(n) {
  x <- rnorm(n)
  c(n = n,
    sm = median(x),
    hd = hdme(x),
    hl1 = hl1me(x),
    hl2 = hl2me(x),
    hl3 = hl3me(x))
}
set.seed(42)
df <- do.call("rbind", lapply(3:30, function(n) {
  as.data.frame(t(replicate(10000, gen(n))))
}))
df2 <- df %>% gather("estimator", "value", -n)
df3 <- df2 %>%
  group_by(n, estimator) %>%
  summarise(mse = var(value)) %>%
  data.frame()
df3$mse.baseline <- sapply(1:nrow(df3), function(i) df3[df3$n == df3[i,]$n & df3$estimator == "sm",]$mse)
df3$mse <- df3$mse.baseline / df3$mse
df3 <- df3[df3$estimator != "sm",]

ggplot(df3, aes(n, mse, col = estimator)) +
  geom_point() +
  geom_line() +
  geom_hline(yintercept = 1, col = cbGrey) +
  scale_color_manual(values = cbPalette) +
  scale_x_continuous(breaks = unique(df3$n)) +
  theme(legend.position="bottom") +
  labs(col = "Median estimator", y = "Relative efficiency")
ggsave_nice("eff")
