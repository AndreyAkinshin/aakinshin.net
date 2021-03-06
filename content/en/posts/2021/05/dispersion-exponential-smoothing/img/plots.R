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
library(EnvStats)
library(patchwork)

cbRed <- "#D55E00"; cbBlue <- "#56B4E9"; cbGreen <- "#009E73"; cbOrange <- "#E69F00"
cbNavy <- "#0072B2"; cbPink <- "#CC79A7"; cbYellow <- "#F0E442"; cbGrey <- "#999999"
cbPalette <- c(cbRed, cbBlue, cbGreen, cbOrange, cbNavy, cbPink, cbYellow, cbGrey)
ggsave_nice <- function(name, plot = last_plot(), tm = theme_bw(), dark_and_light = TRUE, ext = "png", dpi = 200) {
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

wquantile.generic <- function(x, probs, cdf.gen, weights = NA) {
  n <- length(x)
  if (any(is.na(weights)))
    weights <- rep(1 / n, n)
  nw <- sum(weights) / max(weights)

  indexes <- order(x)
  x <- x[indexes]
  weights <- weights[indexes]

  weights <- weights / sum(weights)
  cdf.probs <- cumsum(c(0, weights))

  sapply(probs, function(p) {
    cdf <- cdf.gen(nw, p)
    q <- cdf(cdf.probs)
    w <- tail(q, -1) - head(q, -1)
    sum(w * x)
  })
}

# Weighted Harrell-Davis quantile estimator
whdquantile <- function(x, probs, weights = NA) {
  cdf.gen <- function(n, p) return(function(cdf.probs) {
    pbeta(cdf.probs, (n + 1) * p, (n + 1) * (1 - p))
  })
  wquantile.generic(x, probs, cdf.gen, weights)
}

whdquantule.exp <- function(x, probs, hl) {
  n <- length(x)
  lambda <- log(2) / hl
  weights <- exp(-lambda * ((n-1):0))
  whdquantile(x, probs, weights)
}

mad.exp <- function(x, hl) {
  med <- whdquantule.exp(x, 0.5, hl)
  whdquantule.exp(abs(x - med), 0.5, hl)
}

iqr.exp <- function(x, hl) {
  q1 <- whdquantule.exp(x, 0.25, hl)
  q3 <- whdquantule.exp(x, 0.75, hl)
  q3 - q1
}

exp.smooth.med <- function(x, hl) {
  sapply(1:length(x), function(n) whdquantule.exp(x[1:n], 0.5, hl))
}

exp.smooth.mad <- function(x, hl) {
  sapply(1:length(x), function(n) mad.exp(x[1:n], hl))
}

exp.smooth.iqr <- function(x, hl) {
  sapply(1:length(x), function(n) iqr.exp(x[1:n], hl))
}

set.seed(5)
n <- 1000
x <- 1:n
y <- 100 +
  x / 3 +
  rnorm(n, sd = 5 + 100 * abs(sin(x / 1000 * 4 * pi)))
df <- data.frame(x, y)

draw <- function(hl) {
  df1 <- data.frame(x = x, y = exp.smooth.med(y, hl))
  df2 <- rbind(
    data.frame(x = x, y = exp.smooth.iqr(y, hl), type = "IQR"),
    data.frame(x = x, y = exp.smooth.mad(y, hl), type = "MAD")
  )
  title1 <- paste0("Median exponential smoothing (half-life = ", hl, ")")
  title2 <- paste0("Dispersion exponential smoothing (half-life = ", hl, ")")
  p1 <- ggplot(df, aes(x, y)) +
    geom_point(col = cbBlue) +
    geom_line(data = df1, aes(x, y), col = cbRed, size = 1.5) +
    labs(title = title1, x = "Iteration", y = "Value")
  p2 <- ggplot(df2, aes(x, y, col = type)) +
    geom_line() +
    scale_color_manual(values = c(cbPink, cbGreen, cbNavy)) +
    labs(title = title2, x = "Iteration", y = "Value") +
    theme(legend.title = element_blank())
  p <- p1 / p2
  show(p)
  ggsave_nice(paste0("smoothing", hl), p)
}

draw(50)
