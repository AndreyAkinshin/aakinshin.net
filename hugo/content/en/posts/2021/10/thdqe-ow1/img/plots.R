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

getBetaHdi <- function(a, b, width) {
  eps <- 1e-9
  if (a < 1 + eps & b < 1 + eps) # Degenerate case
    return(c(NA, NA))
  if (a < 1 + eps & b > 1) # Left border case
    return(c(0, width))
  if (a > 1 & b < 1 + eps) # Right border case
    return(c(1 - width, 1))
  if (width > 1 - eps)
    return(0, 1)
  
  # Middle case
  mode <- (a - 1) / (a + b - 2)
  pdf <- function(x) dbeta(x, a, b)
  
  l <- uniroot(
    f = function(x) pdf(x) - pdf(x + width),
    lower = max(0, mode - width),
    upper = min(mode, 1 - width),
    tol = 1e-9
  )$root
  r <- l + width
  return(c(l, r))
}

thd <- function(x, probs) sapply(probs, function(p) {
  x <- sort(x)
  n <- length(x)
  a <- (n + 1) * p
  b <- (n + 1) * (1 - p)
  width <- sqrt(n) / n
  hdi <- getBetaHdi(a, b, width)
  window <- pbeta(hdi, a, b)
  cdf <- function(xs) sapply(xs, function(x) {
    if (x <= hdi[1])
      return(0)
    if (x >= hdi[2])
      return(1)
    return((pbeta(x, a, b) - window[1]) / (window[2] - window[1]))
  })
  cdfs <- cdf(0:n/n)
  W <- tail(cdfs, -1) - head(cdfs, -1)
  sum(x * W)
})

qrde.df <- function(x, qe, title = "", step = 0.001) {
  probs <- seq(step, 1 - step, by = step)
  q <- qe(x, probs)
  x <- c()
  y <- c()
  factor <- 1 / (length(q) - 1)
  for (i in 1:(length(q) - 1)) {
    ql <- q[i]
    qr <- q[i + 1]
    h <- factor / (qr - ql)
    x <- c(x, ql, qr)
    y <- c(y, h, h)
  }
  return(data.frame(x, y, title))
}

draw.qrde <- function() {
  set.seed(42)
  x <- rnorm(20)
  
  df <- rbind(
    qrde.df(x, hdquantile, "HD"),
    qrde.df(x, thd, "THD-SQRT")
  )
  ggplot(df) +
    geom_line(aes(x, y, col = title)) +
    geom_rug(data = data.frame(x = x, y = 0), aes(x, y), sides = "b") +
    scale_color_manual(values = cbPalette) + 
    labs(x = "values", y = "density", col = "Estimator",
         title = "Quantile-respectful density function")
  ggsave_nice("qrde")
}

draw.beta <- function(stage = 0) {
  L <- 0.1
  R <- 0.7
  n <- 5
  p <- 0.3
  a <- (n + 1) * p
  b <- (n + 1) * (1 - p)
  x <- seq(0, 1, by = 0.001)
  y <- dbeta(x, a, b)
  df <- data.frame(x, y)
  dfm <- df[df$x >= L & df$x <= R,]
  x.segm <- 0:n/n
  df.segm <- data.frame(
    x1 = x.segm,
    y1 = 0,
    x2 = x.segm,
    y2 = dbeta(x.segm, a, b)
  )
  
  p <- ggplot(df, aes(x, y))
  
  if (stage >= 2)
    p <- p + geom_area(data = dfm, fill = cbRed, alpha = 0.4)
  
  p <- p +
    geom_line() +
    geom_segment(
      aes(x = x1, y = y1, xend = x2, yend = y2),
      data = df.segm,
      linetype = "dashed") +
    scale_x_continuous(breaks = 0:10/10) +
    labs(y = "density")
  
  if (stage == 3) {
    df.p <- data.frame(
      x = c(0, L, L, R, R, 1),
      y = c(0, 0, 1, 1, 0, 0)
    )
    p <- p + geom_path(data = df.p, col = cbGreen, size = 2)
  }
  
  if (stage == 4) {
    dfm2 <- rbind(
      data.frame(x = L, y = 0),
      dfm,
      data.frame(x = R, y = 0)
    )
    scale <- 1 / (pbeta(R, a, b) - pbeta(L, a, b))
    dfm2$y <- dfm2$y * scale
    df.segm$y2 <- df.segm$y2 * scale
    p <- ggplot(dfm2, aes(x, y)) +
      geom_area(fill = cbRed, alpha = 0.4) +
      geom_line(size = 2) +
      geom_segment(
        aes(x = x1, y = y1, xend = x2, yend = y2),
        data = df.segm[df.segm$x1 >= L & df.segm$x1 <= R,],
        linetype = "dashed") +
      scale_x_continuous(limits = c(0, 1), breaks = 0:10/10) +
      labs(y = "density")
  }
  
  show(p)
  ggsave_nice(paste0("beta", stage))
}

draw.qrde()
draw.beta(1)
draw.beta(2)
draw.beta(3)
draw.beta(4)