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

draw.beta <- function(trimmed = F) {
  n <- 10
  p <- 0.5
  a <- (n + 1) * p
  b <- (n + 1) * (1 - p)

  if (trimmed) {
    hdi <- getBetaHdi(a, b, 1 / sqrt(n))
    L <- hdi[1]
    R <- hdi[2]
    filename <- "tbeta"
    title <- paste0("Truncated Beta(", a, ", ", b, ") PDF")
  } else {
    L <- 0
    R <- 1
    filename <- "beta"
    title <- paste0("Beta(", a, ", ", b, ") PDF")
  }
  
  scale <- 1 / (pbeta(R, a, b) - pbeta(L, a, b))
  step <- 0.001
  x <- c(L, seq(L, R, by = step), R)
  y <- c(0, dbeta(seq(L, R, by = step), a, b), 0) * scale
  df <- data.frame(x, y)
  
  x.segm <- 1:(n-1)/n
  x.segm <- x.segm[x.segm >= L & x.segm <= R]
  df.segm <- data.frame(
    x1 = x.segm,
    y1 = 0,
    x2 = x.segm,
    y2 = dbeta(x.segm, a, b) * scale
  )
  
  wx <- (c(x.segm, R) + c(L, x.segm)) / 2
  wy <- dbeta(wx, a, b) * scale / 2
  wy[wy < 0.1] <- wy[wy < 0.1] + 0.2
  wi <- floor(wx * 10) + 1
  wt <- paste0("W", wi, "")
  df.w <- data.frame(x = wx, y = wy, text = wt)
  
  p <- ggplot(df, aes(x, y)) +
    geom_line() +
    geom_segment(
      aes(x = x1, y = y1, xend = x2, yend = y2),
      data = df.segm,
      linetype = "dashed") +
    geom_text(data = df.w, mapping = aes(x, y, label = text)) +
    scale_x_continuous(breaks = 0:10/10, limits = c(0, 1), expand = c(0, 0)) +
    scale_y_continuous(expand = c(0, 0)) +
    labs(y = "density", title = title)
  
  show(p)
  ggsave_nice(filename)
}

draw.beta(F)
draw.beta(T)