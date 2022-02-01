library(effsize)
library(Hmisc)
library(tidyr)
library(ggplot2)
library(ggdark)
library(svglite)
library(plyr)
library(dplyr)
library(latex2exp)
library(knitr)
library(stringr)
library(jsonlite)
library(gridExtra)
library(evd)
library(ggplot2)
library(e1071)
library(rmutil)

rm(list = ls())

# Helpers
cbRed <- "#D55E00"; cbBlue <- "#56B4E9"; cbGreen <- "#009E73"; cbOrange <- "#E69F00"
cbNavy <- "#0072B2"; cbPink <- "#CC79A7"; cbYellow <- "#F0E442"; cbGrey <- "#999999"
cbPalette <- c(cbRed, cbBlue, cbGreen, cbOrange, cbNavy, cbPink, cbYellow, cbGrey)
ggsave_nice <- function(name, plot = last_plot(), tm = theme_bw(), dark_and_light = T, ext = "png", dpi = 200) {
  width <- 1.5 * 1600 / dpi
  height <- 1.5 * 900 / dpi
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

# Help functions
mad.bias <- c(
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
mad.asympt <- qnorm(0.75)
mad.factor <- function(n) ifelse(
  n <= 100,
  1 / (mad.asympt * (1 + mad.bias[n])),
  1 / (mad.asympt * (1 - 0.76213 / n - 0.86413 / n^2)))
mad <- function(x) mad.factor(length(x)) * median(abs(x - median(x)))

shamos.bias <- c(
  NA, 0.1831500, 0.2989400, 0.1582782, 0.1011748, 0.1005038, 0.0676993,
  0.0609574, 0.0543760, 0.0476839, 0.0426722, 0.0385003, 0.0353028, 0.0323526,
  0.0299677, 0.0280421, 0.0262195, 0.0247674, 0.0232297, 0.0220155, 0.0208687,
  0.0199446, 0.0189794, 0.0182343, 0.0174421, 0.0166364, 0.0160158, 0.0153715,
  0.0148940, 0.0144027, 0.0138855, 0.0134510, 0.0130228, 0.0127183, 0.0122444,
  0.0118214, 0.0115469, 0.0113206, 0.0109636, 0.0106308, 0.0104384, 0.0100693,
  0.0098523, 0.0096735, 0.0094973, 0.0092210, 0.0089781, 0.0088083, 0.0086574,
  0.0084772, 0.0082120, 0.0081874, 0.0079775, 0.0078126, 0.0076743, 0.0075212,
  0.0074051, 0.0072528, 0.0071807, 0.0070617, 0.0069123, 0.0067833, 0.0066439,
  0.0065821, 0.0064889, 0.0063844, 0.0062930, 0.0061910, 0.0061255, 0.0060681,
  0.0058994, 0.0058235, 0.0057172, 0.0056805, 0.0056343, 0.0055605, 0.0055011,
  0.0053872, 0.0053062, 0.0052348, 0.0052075, 0.0051173, 0.0050697, 0.0049805,
  0.0048705, 0.0048695, 0.0048287, 0.0047315, 0.0046961, 0.0046698, 0.0046010,
  0.0045544, 0.0045191, 0.0044245, 0.0044074, 0.0043579, 0.0043536, 0.0042874,
  0.0042520, 0.0041864)

shamos.asympt <- qnorm(0.75) * sqrt(2)
shamos.factor <- function(n) ifelse(
  n <= 100,
  1 / (shamos.asympt * (1 + shamos.bias[n])),
  1 / (shamos.asympt * (1 + 0.414253297 / n - 0.442396799 / n^2)))
shamos <- function(x) shamos.factor(length(x)) * as.numeric(
  expand.grid(i = 1:length(x), j = 1:length(x)) %>%
    filter(i < j) %>%
    mutate(value = abs(x[i] - x[j])) %>%
    summarise(result = median(value)))

iqr <- function(x) range(quantile(x, c(0.25, 0.75)))
rd <- function(x) format(round(x, 3), nsmall = 3)

# Main
simulate <- function(name, n, rnd, iterations = 10000) {
  df0 <- data.frame(t(replicate(iterations, {
    x <- rnd(n)
    list(mad = mad(x), shamos = shamos(x))
  })))
  df0$mad <- as.numeric(df0$mad)
  df0$shamos <- as.numeric(df0$shamos)
  df <- df0 %>% gather("estimator", "value")
  df$estimator <- factor(df$estimator)

  title <- paste0(name, " / N = ", n)
  details <- function(x) paste0(
    "mean=", rd(mean(x)),
    ", median=", rd(median(x)),
    ", SD=", rd(sd(x)),
    ", IQR=", rd(iqr(x)),
    ", P99=", rd(quantile(x, 0.99))
    )
  caption <- paste0(
    "MAD: ", details(df0$mad), "\n",
    "Shamos: ", details(df0$shamos))

  p <- ggplot(df, aes(x = value, col = estimator)) + geom_density(bw = "SJ") +
    labs(title = title, caption = caption) +
    theme(
      plot.title = element_text(size = 18),
      plot.caption = element_text(size = 18)
      ) +
    scale_color_manual(values = cbPalette)
  show(p)
  ggsave_nice(paste0(tolower(name), "-", n))
}

set.seed(1729)
for (n in c(5, 10, 20)) {
  simulate("Normal", n, rnorm)
  simulate("Gumbel", n, rnorm)
  simulate("Frechet", n, rfrechet)
  simulate("Cauchy", n, rcauchy)
  simulate("Weibull", n, function(n) rweibull(n, 0.5))
}
