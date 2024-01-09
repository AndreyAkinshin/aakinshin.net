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
  weights <- exp(-lambda * (n:1))
  whdquantile(x, probs, weights)
}

exp.smooth <- function(x, alpha) {
  s <- c(x[1])
  for (i in 2:length(x)) {
    s <- c(s, alpha * x[i] + (1 - alpha) * s[i - 1])
  }
  s
}

exp.smooth.med <- function(x, hl) {
  sapply(1:length(x), function(n) whdquantule.exp(x[1:n], 0.5, hl))
}


set.seed(42)
n <- 1000
x <- 1:n
y <- 10 + sin(x / 20) * 5 +
  x / 50 +
  runif(n, -3, 3) +
  ifelse(runif(n) > 0.9, runif(n, 0, 40), 0)
df <- data.frame(x, y)

draw.raw <- function() {
  ggplot(df, aes(x, y)) +
    geom_point(col = cbBlue) +
    labs(title = "Raw data", x = "Iteration", y = "Value")
  ggsave_nice("raw")
}

draw.mean <- function(alpha) {
  df0 <- data.frame(x = x, y = exp.smooth(y, alpha))
  title <- paste0("Mean exponential smoothing (alpha = ", alpha, ")")
  p <- ggplot(df, aes(x, y)) +
    geom_point(col = cbBlue) +
    geom_line(data = df0, aes(x, y), col = cbRed, size = 1.5) +
    labs(title = title, x = "Iteration", y = "Value")
  show(p)
  ggsave_nice(paste0("mean", alpha * 100), p)
}

draw.median <- function(hl) {
  df0 <- data.frame(x = x, y = exp.smooth.med(y, hl))
  title <- paste0("Median exponential smoothing (half-life = ", hl, ")")
  p <- ggplot(df, aes(x, y)) +
    geom_point(col = cbBlue) +
    geom_line(data = df0, aes(x, y), col = cbRed, size = 1.5) +
    labs(title = title, x = "Iteration", y = "Value")
  show(p)
  ggsave_nice(paste0("median", hl), p)
}

draw.pareto <- function() {
  loc <- 1
  shape <- 1.05
  true.mean <- shape * loc / (shape - 1)
  true.mean
  true.mean.p <- round(ppareto(true.mean, loc, shape), 2) * 100
  true.median <- loc * 2^(1/shape)
  
  x <- seq(loc, 25, by = 0.01)
  y <- dpareto(x, location = loc, shape = shape)
  df <- data.frame(x, y)
  p <- ggplot(df, aes(x, y)) +
    geom_hline(yintercept = 0) +
    geom_area(col = cbPalette[2], fill = cbPalette[2]) +
    geom_vline(xintercept = true.mean, col = cbPalette[1]) +
    annotate("text",
             x = true.mean,
             y = max(y),
             hjust = 1.1,
             col = cbPalette[1],
             size = 5,
             label = paste0("Mean (", true.mean.p, "th percentile)")) +
    ggtitle(paste0("Pareto(", loc, ", ", shape, "): Probability density function")) +
    ylab("density") +
    geom_vline(xintercept = true.median, col = cbPalette[3], size = 1.5) +
    annotate("text",
             x = true.median,
             y = max(y),
             hjust = -0.1,
             col = cbPalette[3],
             size = 5,
             label = "Median") +
    scale_x_continuous(breaks = seq(0, 25, by = 1))
  show(p)
  ggsave_nice("pareto-mean")
}

draw.raw()

draw.mean(0.9)
draw.mean(0.5)
draw.mean(0.1)

draw.median(10)
draw.median(200)

draw.pareto()
