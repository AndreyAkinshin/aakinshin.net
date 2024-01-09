library(effsize)
library(Hmisc)
library(tidyr)
library(ggplot2)
library(ggdark)
library(svglite)
library(latex2exp)
library(knitr)
library(EnvStats)
library(dplyr)

cbRed <- "#D55E00"; cbBlue <- "#56B4E9"; cbGreen <- "#009E73"; cbOrange <- "#E69F00"
cbNavy <- "#0072B2"; cbPink <- "#CC79A7"; cbYellow <- "#F0E442"; cbGrey <- "#999999"
cbPalette <- c(cbRed, cbBlue, cbGreen, cbOrange, cbNavy, cbPink, cbYellow, cbGrey)
ggsave_nice <- function(name, plot = last_plot(), tm = theme_bw(), dark_and_light = T, ext = "png", dpi = 300) {
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

#---------------------------------
#---------------------------------
#---------------------------------

# Weighted generic quantile estimator (normalized max)
wquantile.generic.norm <- function(x, probs, cdf.gen, weights = NA) {
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

# Weighted Harrell-Davis quantile estimator (normalized max)
whdquantile.norm <- function(x, probs, weights = NA) {
  cdf.gen <- function(n, p) return(function(cdf.probs) {
    pbeta(cdf.probs, (n + 1) * p, (n + 1) * (1 - p))
  })
  wquantile.generic.norm(x, probs, cdf.gen, weights)
}

# Weighted Type 7 quantile estimator (normalized max)
wquantile.norm <- function(x, probs, weights = NA) {
  cdf.gen <- function(n, p) return(function(cdf.probs) {
    h <- p * (n - 1) + 1
    u <- pmax((h - 1) / n, pmin(h / n, cdf.probs))
    u * n - h + 1
  })
  wquantile.generic.norm(x, probs, cdf.gen, weights)
}

#---------------------------------
#---------------------------------
#---------------------------------

# Weighted generic quantile estimator (Kish's formula)
wquantile.generic.kish <- function(x, probs, cdf.gen, weights = NA) {
  n <- length(x)
  if (any(is.na(weights)))
    weights <- rep(1 / n, n)
  nw <- sum(weights)^2 / sum(weights^2)
  
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

# Weighted Harrell-Davis quantile estimator (Kish's formula)
whdquantile.kish <- function(x, probs, weights = NA) {
  cdf.gen <- function(n, p) return(function(cdf.probs) {
    pbeta(cdf.probs, (n + 1) * p, (n + 1) * (1 - p))
  })
  wquantile.generic.kish(x, probs, cdf.gen, weights)
}

# Weighted Type 7 quantile estimator(Kish's formula)
wquantile.kish <- function(x, probs, weights = NA) {
  cdf.gen <- function(n, p) return(function(cdf.probs) {
    h <- p * (n - 1) + 1
    u <- pmax((h - 1) / n, pmin(h / n, cdf.probs))
    u * n - h + 1
  })
  wquantile.generic.kish(x, probs, cdf.gen, weights)
}

#---------------------------------
#---------------------------------
#---------------------------------

draw <- function(name, time, values) {
  lifetime <- 5
  weights <- exp(-(time - 1) / lifetime * log(2))
  medians.norm <- sapply(time, function(k) whdquantile.norm(values[1:k], 0.5, rev(weights[1:k])))
  medians.kish <- sapply(time, function(k) whdquantile.kish(values[1:k], 0.5, rev(weights[1:k])))
  df.median <- rbind(
    data.frame(x = time, y = medians.norm, type = "Normalzied max"),
    data.frame(x = time, y = medians.kish, type = "Kish's formula")
  )
  df.median$type <- factor(df.median$type, levels = c("Normalzied max", "Kish's formula"))
  pl <- ggplot() +
    geom_point(data = data.frame(x = time, y = values), mapping = aes(x, y), col = cbBlue, size = 0.5) +
    xlab("Iteration") + ylab("Duration, sec") +
    geom_line(data = df.median, mapping = aes(x, y, col = type)) +
    scale_color_manual(values = c(cbRed, cbYellow)) +
    labs(col = "Eff. sample size")
  show(pl)
  ggsave_nice(name, pl)
}

set.seed(42)
time <- 1:100
values <- c(
 20 + rnorm(50),
 40 + rnorm(30),
 30 + rnorm(20)
)
draw("cp", time, values)

set.seed(42)
n <- 1000
time <- 1:n
values <- 10 + sin(time / 20) * 5 +
  time / 50 +
  runif(n, -3, 3) +
  ifelse(runif(n) > 0.9, runif(n, 0, 40), 0)
draw("wave", time, values)