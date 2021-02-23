library(effsize)
library(Hmisc)
library(tidyr)
library(ggplot2)
library(ggdark)
library(svglite)
library(plyr)
library(latex2exp)
library(knitr)
library(EnvStats)

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

x <- seq(-4, 4, by = 0.01)
df <- data.frame(
  x = x,
  A = dnorm(x),
  B = dnormMix(x, sd1 = 1, sd2 = 49, p.mix = 0.05),
  C = dnormMix(x, sd1 = 1, sd2 = 9, p.mix = 0.1)
) %>% gather("type", "y", -1)

ggplot(df, aes(x, y, col = type)) +
  geom_line() +
  ylab("Density") +
  theme(legend.title = element_blank()) +
  scale_color_manual(values = cbPalette)
ggsave_nice("density1")

ggplot(df, aes(x, y, col = type)) +
  geom_line() +
  ylab("Density") +
  theme(legend.title = element_blank()) +
  scale_color_manual(values = cbPalette, labels = c("A (s=1)", "B (s=11)", "C (s=3)"))
ggsave_nice("density2")

x <- seq(-25, 25, by = 0.1)
df <- data.frame(
  x = x,
  D1 = dnorm(x, sd = 1),
  D11 = dnorm(x, sd = 11),
  D3 = dnorm(x, sd = 3)
) %>% gather("type", "y", -1)
df$type <- factor(df$type, levels = c("D1", "D11", "D3"))
ggplot(df, aes(x, y, col = type)) +
  geom_line() +
  ylab("Density") +
  theme(legend.title = element_blank()) +
  scale_color_manual(values = cbPalette, labels = c("s = 1", "s = 11", "s = 3")) +
  ggtitle("Normal distributions")
ggsave_nice("density3")
