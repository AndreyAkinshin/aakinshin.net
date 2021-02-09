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

Park.bias <- c(
  NA, -0.163388, -0.3275897, -0.2648275, -0.178125, -0.1594213, 
  -0.1210631, -0.1131928, -0.0920658, -0.0874503, -0.0741303, -0.0711412, 
  -0.0620918, -0.060021, -0.0534603, -0.0519047, -0.0467319, -0.0455579, 
  -0.0417554, -0.0408248, -0.0376967, -0.036835, -0.0342394, -0.033539, 
  -0.0313065, -0.0309765, -0.029022, -0.0287074, -0.0269133, -0.0265451, 
  -0.0250734, -0.0248177, -0.023646, -0.0232808, -0.0222099, -0.0220756, 
  -0.0210129, -0.0207309, -0.0199272, -0.019714, -0.0188446, -0.0188203, 
  -0.0180521, -0.0178185, -0.0171866, -0.0170796, -0.0165391, -0.0163509, 
  -0.0157862, -0.0157372, -0.015282, -0.0149951, -0.0146042, -0.0145007, 
  -0.0140391, -0.0139674, -0.0136336, -0.0134819, -0.0130812, -0.0129708, 
  -0.0126589, -0.0125598, -0.0122696, -0.0121523, -0.0118163, -0.0118244, 
  -0.0115177, -0.0114479, -0.0111309, -0.0110816, -0.0108875, -0.0108319, 
  -0.0106032, -0.0105424, -0.0102237, -0.0102132, -0.0099408, -0.0099776, 
  -0.0097815, -0.0097399, -0.0094837, -0.0094713, -0.009239, -0.0092875, 
  -0.0091508, -0.0090145, -0.0088191, -0.0088205, -0.0086622, -0.0085714, 
  -0.0084718, -0.0083861, -0.0082559, -0.008265, -0.0080977, -0.0080708, 
  -0.007881, -0.0078492, -0.0077043, -0.0077614)

predict.HayesPark <- function(n) ifelse(
  n <= 100,
  1 / (qnorm(0.75) * (1 + Park.bias[n])),
  1 / (qnorm(0.75) * (1 - 0.76213 / n - 0.86413 / n^2)))

n <- 1:100
df <- data.frame(
  n = n,
  factor = predict.HayesPark(n),
  type = ifelse(n %% 2 == 1, "odd", "even"))

ggplot(df, aes(n, factor)) +
  geom_line(col = cbGrey, alpha = 0.5) +
  geom_point(aes(shape = type, col = type), size = 0.9) +
  scale_color_manual(values = cbPalette) +
  scale_y_continuous(breaks = c(round(1 / qnorm(0.75), 4), seq(1.6, 2.2, by = 0.2))) +
  theme(legend.title = element_blank(), plot.title = element_text(hjust = 0.5)) +
  geom_hline(yintercept = 1 / qnorm(0.75)) +
  ggtitle("MAD bias-correction factors")
ggsave_nice("factors")
#kable(df[,c("n", "factor")])
