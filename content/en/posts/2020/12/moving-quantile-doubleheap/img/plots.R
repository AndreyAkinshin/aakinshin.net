library(ggplot2)
library(Hmisc)
library(ggdark)
library(evd)
library(svglite)
library(ggpubr)
library(tidyr)
library(plyr)

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


set.seed(42)
n <- 200
L <- 9
x <- seq(1, n, by = 1)
d <- 10 + sin(x / 20) * 5 + rnorm(n, sd = 1.5) +
  ifelse(sample(0:9, n, T) > 0, rep(0, n), runif(n, 20, 50))
m <- sapply(1:n, function(k) median(tail(head(d, k), L)))
a <- sapply(1:n, function(k) mean(tail(head(d, k), L)))
df <- rbind(
  data.frame(x = x, y = d, type = "Raw data"),
  data.frame(x = x, y = m, type = "Moving median"),
  data.frame(x = x, y = a, type = "Moving mean")
)
df$type <- factor(df$type, c("Raw data", "Moving median", "Moving mean"))
ggplot(df, aes(x, y, col = type, size = type)) +
  geom_point() +
  ylim(0, max(d)) +
  scale_color_manual(values = c(cbBlue, cbRed, cbYellow)) +
  scale_size_manual(values = c(0.5, 1.0, 0.5)) +
  xlab("Iteration") +
  ylab("Duration") +
  theme(legend.title = element_blank())
ggsave_nice("example")
