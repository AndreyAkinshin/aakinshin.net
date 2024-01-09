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

### Helpers
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

### Main
source("../src/beta-hdi.R")

build.df <- function(sum, p, width) {
  a <- sum * p
  b <- sum * (1 - p)
  comment <- paste0("a = ", a, ", b = ", b)
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

draw <- function(sum, width, ps = seq(0.05, 0.95, length.out = 25)) {
  df <- do.call("rbind", lapply(ps, function(p) build.df(sum, p, width)))
  df$comment <- factor(df$comment, levels = unique(df$comment))
  p <- ggplot(df, aes(x, y)) +
    geom_area(data = df[df$inside,], aes(x, y), fill = cbRed, alpha = 0.4) +
    geom_line(data = df[df$visible,], aes(x, y), col = cbBlue) +
    facet_wrap(vars(comment)) +
    labs(
      title = paste0("HDI of Beta distribution (a + b = ", sum , ", interval width = ", width, ")"),
      y = "density"
    )
  #show(p)
  filename <- paste0(
    "hdi_s", sum,
    "_w", round(width * 100),
    ifelse(length(ps) <= 2, 
           paste0("_p", round(ps * 100), collapse = ""),
           paste0("_ps", length(ps))))
  ggsave_nice(filename, p)
}
draw(10, 0.3, c(0.05, 0.95))
draw(10, 0.3, 0.3)
draw(10, 0.3, 0.2)

draw(10, 0.3)
draw(4, 0.3)
draw(10, 0.1)
draw(15, 0.1)
