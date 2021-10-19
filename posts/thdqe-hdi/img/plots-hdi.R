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

rm(list = ls())

### Helpers
cbRed <- "#D55E00"; cbBlue <- "#56B4E9"; cbGreen <- "#009E73"; cbOrange <- "#E69F00"
cbNavy <- "#0072B2"; cbPink <- "#CC79A7"; cbYellow <- "#F0E442"; cbGrey <- "#999999"
cbPalette <- c(cbRed, cbBlue, cbGreen, cbOrange, cbNavy, cbPink, cbYellow, cbGrey)
ggsave_nice <- function(name, plot = last_plot(), tm = theme_bw(), dark_and_light = T, ext = "png", dpi = 300) {
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

source("../src/thdqe.R")

build.df <- function(sum, width, p, title) {
  a <- sum * p
  b <- sum * (1 - p)
  comment <- paste0(title, "\na = ", a, ", b = ", b)
  hdi <- getBetaHdi(a, b, width)

  x <- seq(0, 1, by = 0.01)
  y <- dbeta(x, a, b)
  if (y[1] > 6 || y[length(y)] > 6) {
    x <- seq(0.01, 0.99, by = 0.01)
    y <- dbeta(x, a, b)
  }
  
  max.value <- ifelse(y[1] < y[2] & y[length(y) - 1] > y[length(y)], max(y), 6)
  visible <- y <= max.value
  inside <- x >= hdi[1] & x <= hdi[2]
  y <- pmin(y, max.value)
  data.frame(x, y, p, visible, inside, comment)
}

draw.hdi <- function(sum = 10, width = 0.3, ps = c(0.05, 0.5, 0.95)) {
  df <- rbind(
    build.df(sum, width, 0.05, "Left border case"),
    build.df(sum, width, 0.50, "Middle case"),
    build.df(sum, width, 0.95, "Right border case")
  )
  df$comment <- factor(df$comment, levels = unique(df$comment))
  p <- ggplot(df, aes(x, y)) +
    geom_area(data = df[df$inside,], aes(x, y), fill = cbRed, alpha = 0.4) +
    geom_line(data = df[df$visible,], aes(x, y)) +
    facet_wrap(vars(comment)) +
    labs(
      title = paste0("HDI of Beta distribution (a + b = ", sum , ", interval width = ", width, ")"),
      y = "density"
    )
  show(p)
  ggsave_nice("hdi", p)
}

draw.hdi()
