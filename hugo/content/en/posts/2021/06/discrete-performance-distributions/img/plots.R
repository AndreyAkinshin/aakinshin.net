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


options(width = 80)
extract <- function(name) {
  df <- read.csv(paste0(name, ".csv"))
  df$Date <- as.POSIXct(df$Timestamp, "%YYYY-%mm-%dd %HH:%MM:%SS")
  df <- df %>% filter(Platform == "Mac OS X")
  df
}

process <- function(name, df = NULL) {
  if (is.null(df))
      df <- extract(name)
  ggplot(df, aes(Date, Value)) +
    geom_point(size = 0.5, col = cbBlue) +
    scale_y_continuous(limits = c(0, NA)) +
    ylab("Duration, ms")
  ggsave_nice(paste0(name, "-timeline"))

  ggplot(df, aes(Value)) +
    geom_histogram(binwidth = 1, col = cbGreen, fill = cbGrey, size = 0.5) +
    scale_y_continuous(expand = c(0, 0), limits = c(0, max(table(df$Value)) + 1)) +
    scale_x_continuous(limits = c(-0.5, NA)) +
    xlab("Duration, ms")
  ggsave_nice(paste0(name, "-hist"))

  x <- df$Value
  show(table(x))
  show(round(table(x) / length(x) * 100, 2))
}
process("findusages-total")
process("startup-base_LaF_creation")
process("orchard-AllAssembliesCount")
