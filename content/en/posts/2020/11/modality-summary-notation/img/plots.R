library(ggplot2)
library(Hmisc)
library(ggdark)
library(evd)
library(svglite)
library(ggpubr)
library(tidyr)
library(e1071)

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

draw <- function(x) {
  types <- c("Lower outlier", "Mode #1", "Intermodal outliers", "Mode #2", "Upper outliers", "None")
  apply.type <- function(df, low, high, type) {
    df[df$x >= low & df$x <= high,]$type <- type
    df
  }
  apply.types <- function(df, r1, r2, r3, r4, r5) {
    df <- apply.type(df, r1[1], r1[2], types[1])
    df <- apply.type(df, r2[1], r2[2], types[2])
    df <- apply.type(df, r3[1], r3[2], types[3])
    df <- apply.type(df, r4[1], r4[2], types[4])
    df <- apply.type(df, r5[1], r5[2], types[5])
    df$type <- factor(df$type, levels = types)
    df$group <- c(0)
    for (i in 2:nrow(df)) {
      if (df[i,]$type != df[i - 1,]$type)
        df[i,]$group <- df[i - 1,]$group + 1
      else
        df[i,]$group <- df[i - 1,]$group
    }
    df
  }
  
  den <- density(x, bw = 0.2, n = 2^10)
  df.den <- data.frame(
    x = den$x,
    y = den$y,
    type = c("None")
  )
  rf <- function(a, b) range(df.den[df.den$x >= a & df.den$x < b & df.den$y > 0.00001, ]$x)
  r1 <- rf(0, 3)
  r2 <- rf(6, 14)
  r3 <- rf(17, 23)
  r4 <- rf(26, 34)
  r5 <- rf(36, 40)
  df.den <- apply.types(df.den, r1, r2, r3, r4, r5)
  
  df.rug <- data.frame(x, type = "None")
  df.rug <- apply.types(df.rug, r1, r2, r3, r4, r5)
  
  pallete <- c(cbOrange, cbNavy, cbGreen, cbBlue, cbYellow, cbGrey)
  ggplot() +
    geom_line(data = df.den, aes(x, y, col = type, group = group), size = 0.8) +
    geom_rug(data = df.rug, aes(x, col = type), size = 0.8) +
    scale_color_manual(values = head(pallete, length(types)), breaks = types) +
    theme(legend.title = element_blank()) +
    scale_x_continuous(limits = c(0, 40), breaks = seq(0, 40, by = 5)) +
    ylab("density")
}

x <- c(1, 2, 10.695, 9.71, 11.882, 9.935, 8.133, 11.701, 11.056, 11.386, 10.253, 9.701,
       11.11, 7.893, 9.842, 7.576, 8.913, 9.912, 10.473, 9.234, 10.016, 8.949, 10.505,
       10.321, 7.608, 10.64, 8.351, 8.737, 10.544, 9.9, 11.171, 9.398, 10.145, 11.411,
       7.732, 10.515, 7.16, 9.891, 10.066, 10.05, 11.327, 10.198, 9.816, 10.878, 10.271,
       11.093, 8.758, 10.656, 9.143, 8.972, 8.1, 10.255, 10.704, 10.631, 8.537, 11.462,
       9.046, 9.906, 9.356, 10.794, 9.93, 10.14, 9.371, 12.637, 10.39, 9.04, 10.729,
       10.079, 11.909, 8.498, 10.035, 7.879, 10.468, 9.677, 9.551, 9.324, 11.736, 10.341,
       9.305, 9.844, 8.662, 11.76, 9.628, 10.571, 10.639, 10.171, 9.672, 9.669, 9.696,
       11.265, 13.115, 9.655, 9.273, 10.957, 9.903, 10.426, 9.612, 9.652, 9.375, 11.348,
       8.931, 8.918, 19, 30.84, 31.587, 29.535, 31.072, 29.55, 29.796, 30.071,
       29.907, 28.993, 28.683, 28.864, 28.032, 29.807, 30.77, 28.906, 30.987, 30.119
       , 32.344, 31.341, 31.557, 30.094, 30.405, 29.373, 30.029, 30.516, 29.301, 29.334
       , 29.625, 30.407, 30.466, 29.722, 30.05, 29.249, 28.212, 28.807, 29.912, 29.431,
       30.145, 28.775, 27.692, 30.856, 31.433, 29.213, 30.901, 30.529, 28.33, 29.793,
       30.006, 30.841, 31.762, 30.591, 30.305, 30.872, 29.23, 30.43, 30.468, 31.226, 29.77,
       29.016, 28.899, 29.786, 31.599, 28.976, 30.78, 28.972, 29.919, 29.092, 31.308,
       31.128, 30.596, 28.966, 31.16, 28.825, 30.75, 28.252, 29.317, 29.998, 29.424
       , 29.629, 29.211, 31.043, 31.487, 29.683, 29.828, 31.349, 31.427, 30.067, 30.126
       , 29.149, 29.452, 29.215, 28.047, 29.566, 30.016, 30.517, 28.904, 28.883, 29.591
       , 30.387, 28.956, 37, 38, 39)
outliers <- c(1, 2, 19, 37, 38, 39)

draw(x) +
  labs(caption = "{1.00, 2.00} + [7.16; 13.12]_100 + {19.00} + [27.69; 32.34]_100 + {37.00..39.00}_3") +
  theme(plot.caption = element_text(size=6))
ggsave_nice("thumbnail")

set.seed(42)
x <- rnorm(100, 10)
x <- c(x, x + 20)
ggplot(data.frame(x), aes(x)) +
  geom_density(bw = "SJ") +
  xlim(0, 40) +
  geom_vline(xintercept = 20, col = cbRed) +
  annotate("text", x = 21, y = 0.17, hjust = 0, label = "Median", col = cbRed)
ggsave_nice("median1")

set.seed(42)
x <- 10 + rbeta(1000, 1, 10)
x.median <- as.numeric(hdquantile(x, 0.5))
x.density <- density(x, bw = "SJ")
x.mode <- x.density$x[which.max(x.density$y)]
ggplot(data.frame(x), aes(x)) +
  geom_density(bw = "SJ") +
  xlim(9.5, 10.5) +
  geom_vline(xintercept = x.median, col = cbRed) +
  geom_vline(xintercept = x.mode, col = cbBlue) +
  annotate("text", x = x.median + 0.01, y = 8, hjust = 0, label = "Median", col = cbRed) +
  annotate("text", x = x.mode - 0.01, y = 8, hjust = 1, label = "Mode", col = cbBlue)
ggsave_nice("median2")

x.skewness <- skewness(x)
ggplot(data.frame(x), aes(x)) +
  geom_density(bw = "SJ") +
  xlim(9.5, 10.5) +
  geom_vline(xintercept = x.mode, col = cbBlue) +
  annotate("text", x = x.mode - 0.01, y = 8, hjust = 1, label = "Mode", col = cbBlue) +
  labs(caption = paste0("Skewness = ", x.skewness)) +
  theme(plot.caption = element_text(size = 20))
ggsave_nice("skewness")

set.seed(42)
x <- c(rnorm(1000, 10), 5, 15)
x.mr <- range(x[x > 5 & x < 15])
x.density <- density(x, bw = "SJ")
x.mode <- x.density$x[which.max(x.density$y)]
x.q1 <- as.numeric(hdquantile(x, 0.25))
x.q3 <- as.numeric(hdquantile(x, 0.75))
x.dh <- max(x.density$y) * 1.1
ggplot(data.frame(x), aes(x)) +
  geom_density(bw = "SJ") +
  xlim(4, 16) +
  geom_vline(xintercept = x.mode, col = cbBlue) +
  annotate("text", x = x.mode, y = x.dh, hjust = 0.5, label = "Mode", col = cbBlue) +
  geom_vline(xintercept = x.q1, col = cbOrange) +
  annotate("text", x = x.q1 - 0.1, y = x.dh - 0.05, hjust = 1, label = "Q1", col = cbOrange) +
  geom_vline(xintercept = x.q3, col = cbOrange) +
  annotate("text", x = x.q3 + 0.1, y = x.dh - 0.05, hjust = 0, label = "Q3", col = cbOrange) +
  geom_vline(xintercept = x.mr, col = cbGreen) +
  geom_segment(x = x.mr[1], xend = x.mr[2], y = 0.3, yend = 0.3, col = cbGreen, arrow = arrow(length = unit(0.03, "npc"))) +
  geom_segment(x = x.mr[2], xend = x.mr[1], y = 0.3, yend = 0.3, col = cbGreen, arrow = arrow(length = unit(0.03, "npc"))) +
  annotate("text", x = x.mr[1] + 0.3, y = 0.308, hjust = 0, vjust = 0, label = "Mode range", col = cbGreen) +
  geom_rug()
ggsave_nice("quartiles")
