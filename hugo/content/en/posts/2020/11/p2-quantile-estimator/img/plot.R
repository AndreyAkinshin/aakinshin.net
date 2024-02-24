library(ggplot2)
library(Hmisc)
library(ggdark)
library(evd)
library(svglite)
library(ggpubr)
library(tidyr)

cbRed <- "#D55E00"; cbBlue <- "#56B4E9"; cbGreen <- "#009E73"; cbOrange <- "#E69F00"
cbNavy <- "#0072B2"; cbPink <- "#CC79A7"; cbYellow <- "#F0E442"; cbGrey <- "#999999"
cbPalette <- c(cbRed, cbBlue, cbGreen, cbOrange, cbNavy, cbPink, cbYellow, cbGrey)
ggsave_nice <- function(name, plot = last_plot(), tm = theme_bw(), dark_and_light = TRUE, ext = "svg", dpi = 300) {
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

draw <- function(name) {
  df <- read.csv(paste0(name, ".csv"))
  df <- df[, !(names(df) %in% c("x"))]
  df <- gather(df, "Type", "Value", 2:5)
  ggplot(df, aes(x = index, y = Value, group = Type, col = Type)) +
    geom_line() +
    ggtitle(paste(name, " distribution")) +
    scale_color_manual(values = cbPalette) +
    labs(col = "Quantile estimator")
  ggsave_nice(name)
}
draw("gumbel")
draw("normal")
draw("beta")
draw("bimodal")
draw("uniform")
