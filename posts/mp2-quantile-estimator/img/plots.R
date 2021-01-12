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

df <- read.csv("data.csv") %>% gather("metric", "value", 2:4)

df$type <- ""
df[df$metric == "data",]$type <- "Raw"
df[df$metric == "estimation",]$type <- "Moving Median"
df[df$metric == "true",]$type <- "Moving Median"
df$type <- factor(df$type, levels = c("Raw", "Moving Median"))

df[df$metric == "data",]$metric <- "Data"
df[df$metric == "estimation",]$metric <- "MP²"
df[df$metric == "true",]$metric <- "True"
df$metric <- factor(df$metric, levels = c("Data", "True", "MP²"))

ggplot(df, aes(i, value, col = metric)) +
  geom_point(data = df[df$metric == "Data",], size = 0.2) +
  geom_line(data = df[df$metric != "Data",]) +
  geom_vline(xintercept = seq(100, 1000, by = 100), linetype = "dashed", col = cbGrey) +
  facet_grid(rows = vars(type)) +
  xlab("Iteration") +
  ylab("Value") +
  scale_color_manual(values = c(cbBlue, cbGreen, cbRed)) +
  scale_x_continuous(breaks = seq(0, 1000, by = 100)) +
  theme(legend.title=element_blank())
ggsave_nice("simulation")
