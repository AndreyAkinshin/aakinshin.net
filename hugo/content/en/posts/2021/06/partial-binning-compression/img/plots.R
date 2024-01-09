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
library(DiscreteWeibull)

cbRed <- "#D55E00"; cbBlue <- "#56B4E9"; cbGreen <- "#009E73"; cbOrange <- "#E69F00"
cbNavy <- "#0072B2"; cbPink <- "#CC79A7"; cbYellow <- "#F0E442"; cbGrey <- "#999999"
cbPalette <- c(cbRed, cbBlue, cbGreen, cbOrange, cbNavy, cbPink, cbYellow, cbGrey)
ggsave_nice <- function(name, plot = last_plot(), tm = theme_bw(), dark_and_light = T, ext = "png", dpi = 300) {
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

p1 <- 0.6
p2 <- 1 - p1
step <- 0.01

x1 <- seq(0, 1, by = step)
y1 <- rep(p1, length(x1))

x2 <- seq(1 + step, 10, by = step)
df <- Vectorize(function(x) {
  x <- x - 1
  (dweibull(x, 0.5, 3) * 0.5 + dweibull(x, 3, 4) * 0.5) * p2
})
y2 <- df(x2)

x <- c(x1, x2)
y <- c(y1, y2)
df <- data.frame(x, y)
ggplot(df, aes(x, y)) +
  geom_area(fill = cbRed, alpha = 0.5) +
  labs(title = "Partially binned density plot", x = "Duration, ms", y = "Density") +
  scale_x_continuous(breaks = seq(0, 10, 1)) +
  geom_vline(xintercept = 1, col = cbBlue, linetype = "dashed", size = 1.5)
ggsave_nice("density")
