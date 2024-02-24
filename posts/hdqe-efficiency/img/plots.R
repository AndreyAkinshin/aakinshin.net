library(effsize)
library(Hmisc)
library(tidyr)
library(ggplot2)
library(ggdark)
library(svglite)
library(plyr)
library(latex2exp)
library(knitr)
library(stringr)

cbRed <- "#D55E00"; cbBlue <- "#56B4E9"; cbGreen <- "#009E73"; cbOrange <- "#E69F00"
cbNavy <- "#0072B2"; cbPink <- "#CC79A7"; cbYellow <- "#F0E442"; cbGrey <- "#999999"
cbPalette <- c(cbRed, cbBlue, cbGreen, cbOrange, cbNavy, cbPink, cbYellow, cbGrey)
ggsave_nice <- function(name, plot = last_plot(), tm = theme_bw(), dark_and_light = TRUE, ext = "png", dpi = 100) {
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

names <- c("Symmetric", "RightSkewedUnimodal", "RightSkewedBimodal", "SyntheticLatencyBrendanGregg")
for (name in names) {
  df <- read.csv(paste0(name, "_Efficiency.csv"))
  df$distribution <- factor(df$distribution, levels = as.vector(unique(df$distribution)))
  df$type <- factor(ifelse(df$efficiency > 1, "good", "bad"), levels = c("good", "bad"))
  ncol <- max(4, round(sqrt(length(unique(df$distribution)))))
  ns <- unique(df$n)
  for (n in ns) {
    ggplot(df[df$n == n,], aes(quantile, efficiency, col = type)) +
      geom_hline(yintercept = 1, linetype = "dotted") +
      geom_line(col = "grey", alpha = 0.5) +
      geom_point(size = 1) +
      facet_wrap(vars(distribution), ncol = ncol) +
      scale_x_continuous(limits = c(0, 1)) +
      scale_color_manual(values = c("#009E73", "#D55E00")) +
      ggtitle(paste0("Relative efficiency of HDQE (n = ", n, ")")) +
      ylim(0, 3) +
      theme(legend.position="none")
    ggsave_nice(paste0(name, "_N", str_pad(n, 2, pad = "0"), "_Efficiency"))
  }
  
  dfd <- read.csv(paste0(name, "_Pdf.csv"))
  dfd$distribution <- factor(dfd$distribution, levels = as.vector(unique(dfd$distribution)))
  ggplot(dfd, aes(x, pdf)) +
    geom_line(col = "#56B4E9") +
    facet_wrap(vars(distribution), scales = "free", ncol = ncol) +
    ylab("density") +
    theme(axis.text.y=element_blank(), axis.ticks.y=element_blank()) +
    ylim(c(0, NA)) +
    ggtitle(paste0("Reference distribution probability density functions (", name, ")"))
  ggsave_nice(paste0(name, "_Pdf"))
}
