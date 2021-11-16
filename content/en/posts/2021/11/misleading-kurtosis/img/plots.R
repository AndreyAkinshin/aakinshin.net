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

# Main
draw.kurt_intro <- function() {
  winger.R <- 3
  wigner <- Vectorize(function(x) 2 * sqrt(max(winger.R^2 - x^2, 0)) / (pi * winger.R^2))
  uni.R <- 3.5
  uni <- Vectorize(function(x) ifelse(abs(x) < uni.R, 1/(2*uni.R), 0))
  pal <- cbPalette
  size <- 1.5
  draw_function <- function(fun, index) stat_function(fun = fun, col = pal[index], size = 1.5)
  draw_text <- function(x0, y0, value, index)
    geom_text(x = x0, y = y0, size = 4.5, label = paste0("ExKurtosis=", value), col = pal[index])
  ggplot(data.frame(x = c(-5, 5)), aes(x = x)) +
    draw_function(dlaplace, 1) + 
    draw_function(dnorm, 2) +
    draw_function(wigner, 3) +
    draw_function(uni, 4) +
    draw_text(1.5, 0.45, 3, 1) +
    draw_text(2.0, 0.32, 0, 2) +
    draw_text(2.6, 0.21, -1, 3) +
    draw_text(3.6, 0.17, -1.2, 4) +
    theme(axis.line=element_blank(),
          axis.title.x=element_blank(), axis.text.x=element_blank(), axis.ticks.x=element_blank(),
          axis.title.y=element_blank(), axis.text.y=element_blank(), axis.ticks.y=element_blank())
  
  ggsave_nice("kurt_intro")
}
draw.multimodal <- function() {
  set.seed(42)
  x <- c(
    rlnorm(600, 0, 3),
    9 - rlnorm(500, 0, 1),
    10 + rlnorm(1000, 0, 1)
  )
  ggplot(data.frame(x), aes(x)) +
    geom_density(bw = "SJ", col = cbBlue, fill = cbBlue, alpha = .5) +
    xlim(-1, 15) +
    ggtitle("Multimodal distribution")
  ggsave_nice("multimodal")
}
draw.normal <- function() {
  set.seed(42)
  x <- rnorm(10000)
  ggplot(data.frame(x = x), aes(x)) +
    geom_density(bw = "SJ", col = cbBlue, fill = cbBlue, alpha = .5)
  ggsave_nice("normal")
  print(kurtosis(x))
  print(kurtosis(c(-1000, x)))
}

draw.kurt_intro()
draw.multimodal()
draw.normal()