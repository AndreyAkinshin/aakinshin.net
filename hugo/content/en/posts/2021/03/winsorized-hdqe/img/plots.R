library(effsize)
library(Hmisc)
library(tidyr)
library(ggplot2)
library(ggdark)
library(svglite)
library(plyr)
library(latex2exp)
library(knitr)

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


draw <- function(n, p) {
  a <- p * (n + 1)
  b <- (1 - p) * (n + 1)
  x0 <- (0:n)/n
  x <- seq(0, 1, by = 0.01)
  y <- dbeta(x, a, b)
  ggplot(data.frame(x, y), aes(x, y)) +
    geom_line() +
    geom_segment(
      data = data.frame(x = x0, y = 0, xend = x0, yend = dbeta(x0, a, b)),
      mapping = aes(x, y, xend = xend, yend = yend)
      ) +
    scale_x_continuous(breaks = x0) +
    ggtitle(paste0("Beta(", a, "; ", b, "), n = ", n, ", p = ", p)) +
    theme(plot.title = element_text(hjust = 0.5))
}
draw(10, 0.5)
ggsave_nice("beta1")