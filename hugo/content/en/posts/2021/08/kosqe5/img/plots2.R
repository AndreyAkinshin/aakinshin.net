library(effsize)
library(Hmisc)
library(tidyr)
library(ggplot2)
library(ggdark)
library(svglite)
library(plyr)
library(latex2exp)
library(knitr)
library(stringr)

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

draw <- function(n, p, k, kind) {
  a <- (n + 1) * p
  b <- (n + 1) * (1 - p)

  f1 <- function(x) x^(a-1) * (1-x)^(b - 1)
  f2 <- function(x) (x+k/n)^(a-1) * (1-x-k/n)^(b - 1)
  f0 <- function(x) f1(x) - f2(x)

  if (kind == "l")
    x0 <- 0
  else if (kind == "r")
    x0 <- 1 - k / n
  else {
    xs <- seq(0, 1 - k/n, by = 0.01)
    df <- rbind(
      data.frame(x = xs, y = f1(xs), type = "A"),
      data.frame(x = xs, y = f2(xs), type = "B")
    )
    x0 <- uniroot(f0, range(xs))$root
  }

  L <- x0
  R <- x0 + k/n
  dbeta(L, a, b)
  dbeta(R, a, b)

  xs <- seq(0, 1, by = 0.0001)
  ys <- dbeta(xs, a, b)
  xs2 <- xs[xs >= L & xs <= R]
  ys2 <- dbeta(xs2, a, b)
  title <- paste0("HID of Beta function (n = ", n , ", p = ", p, ", k = ", k, ")")
  ggplot(data.frame(x = xs, y = ys), aes(x, y)) +
    geom_area(aes(x, y), data.frame(x = xs2, y = ys2), fill = cbRed, alpha = 0.4) +
    geom_line(col = cbRed) +
    geom_vline(xintercept = L, col = cbBlue) +
    geom_vline(xintercept = R, col = cbBlue) +
    geom_hline(yintercept = min(dbeta(L, a, b), dbeta(R, a, b)), col = cbBlue, linetype = "dashed") +
    labs(x = "x", y = "density", title = title)
}

draw(9, 0.25, 3, "c")
ggsave_nice("hdi-c")
draw(9, 0.1, 3, "l")
ggsave_nice("hdi-l")
draw(9, 0.9, 3, "r")
ggsave_nice("hdi-r")
