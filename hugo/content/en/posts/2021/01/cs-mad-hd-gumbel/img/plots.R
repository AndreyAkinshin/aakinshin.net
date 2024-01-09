library(ggplot2)
library(Hmisc)
library(ggdark)
library(evd)
library(svglite)
library(ggpubr)
library(tidyr)
library(plyr)
library(dplyr)
library(stringr)

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

source("../src/study.R")
ggsave_nice("results-facet")

for (n in 3:10) {
  ggplot(gather(df[df$SampleSize == n,], "EstimatorType", "x", 2:3), aes(x, fill = EstimatorType)) +
    geom_density(bw = "SJ", alpha = 0.5) +
    scale_fill_manual(values = c("#D55E00", "#56B4E9")) +
    xlab("Absolute error of MAD estimations") +
    ylab("Density (normal kernel, Sheather & Jones)") +
    ggtitle(paste0("MAD absolute errors for Gumbel distribution (n = ", n, ")"))
  ggsave_nice(paste0("results-", str_pad(n, 2, pad = "0")), ext = "svg")
}

ggplot(stats, aes(SampleSize, score)) +
  geom_point(col = cbRed, size = 0.9) +
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, by = 0.1)) +
  scale_x_continuous(breaks = seq(0, max(stats$SampleSize), by = 5)) +
  geom_errorbar(aes(ymin = low, ymax = high), col = cbBlue) +
  geom_hline(yintercept = 0.5, col = cbGreen) +
  ylab("Harrell-Davis score (CI 99.9%)")
ggsave_nice("summary")
