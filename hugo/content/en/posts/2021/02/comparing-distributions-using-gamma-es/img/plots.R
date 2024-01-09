library(effsize)
library(Hmisc)
library(tidyr)
library(ggplot2)
library(ggdark)
library(svglite)
library(plyr)
library(latex2exp)

cbRed <- "#D55E00"; cbBlue <- "#56B4E9"; cbGreen <- "#009E73"; cbOrange <- "#E69F00"
cbNavy <- "#0072B2"; cbPink <- "#CC79A7"; cbYellow <- "#F0E442"; cbGrey <- "#999999"
cbPalette <- c(cbRed, cbBlue, cbGreen, cbOrange, cbNavy, cbPink, cbYellow, cbGrey)
ggsave_nice <- function(name, plot = last_plot(), tm = theme_bw(), dark_and_light = TRUE, ext = "png", dpi = 300) {
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

# Harrell-Davis quantile estimator
hdq <- function(x, probs) {
  sapply(probs, function(p) {
    n <- length(x)
    betacdf <- pbeta((0:n) / n, (n + 1) * p, (n + 1) * (1 - p))
    W <- tail(betacdf, -1) - head(betacdf, -1)
    sum(W * sort(x))
  })
}
# Harrell-Davis-powered median absolute deviation
hdmad <- function(x) 1.4826 * hdq(abs(x - hdq(x, 0.5)), 0.5)
# Harrell-Davis-powered pooled median absolute deviation
phdmad <- function(x, y) {
  nx <- length(x); ny <- length(y)
  sqrt(((nx - 1) * hdmad(x) ^ 2 + (ny - 1) * hdmad(y) ^ 2) / (nx + ny - 2))
}
# Gamma Effect Size for the given quantiles
gammaEffectSize <- function(x, y, probs) (hdq(y, probs) - hdq(x, probs)) / phdmad(x, y)

shiftFunction <- function(x, y, probs) hdq(y, probs) - hdq(x, probs)
ratioFunction <- function(x, y, probs) hdq(y, probs) / hdq(x, probs)

### Study 2
set.seed(42)
probs <- seq(0.25, 0.75, by = 0.01)
n <- 1000
mode <- 100
delta <- 4
sd <- c(5 * delta, 5 / 4 * delta)
x1 <- rnorm(n, mode, sd[1])
y1 <- rnorm(n, mode + delta, sd[1])
x2 <- rnorm(n, mode, sd[2])
y2 <- rnorm(n, mode + delta, sd[2])

draw.dist <- function() {
  df.dist <- rbind(
    data.frame(name = "x", sd = sd[1], value = x1),
    data.frame(name = "y", sd = sd[1], value = y1),
    data.frame(name = "x", sd = sd[2], value = x2),
    data.frame(name = "y", sd = sd[2], value = y2)
  )
  ggplot(df.dist, aes(value)) +
    geom_density(bw = "SJ") +
    facet_grid(rows = vars(name), cols = vars(sd), labeller = labeller(.rows = label_value, .cols = label_both)) +
    ylab("Density") +
    xlab("Value") +
    labs(caption = "Density: KDE (Normal kernel, Sheather & Jones)")
}
draw.dist() + geom_vline(
  data = data.frame(name = c("x", "y"), value = c(mode, mode + delta)),
  mapping = aes(xintercept = value),
  linetype = "dashed")
ggsave_nice("study2-density")

draw.func <- function(func, func.name, base.value, y.breaks = waiver()) {
  exrange <- function(x, f = 0.2) c(min(x) - (max(x) - min(x)) * f, max(x) + (max(x) - min(x)) * f)
  df <- rbind(
    data.frame(probs = probs, sd = sd[1], value = func(x1, y1, probs)),
    data.frame(probs = probs, sd = sd[2], value = func(x2, y2, probs))
  )
  ggplot(df, aes(probs, value)) +
    geom_line() +
    xlab("Quantiles") + ylab(func.name) +
    facet_grid(cols = vars(sd), labeller = labeller(.cols = label_both)) +
    geom_hline(yintercept = base.value, linetype = "dashed") +
    scale_y_continuous(limits = exrange(c(df$value, base.value)), breaks = y.breaks) +
    scale_x_continuous(breaks = seq(0, 1, by = 0.1))
}
draw.func(shiftFunction, "Shift", 0)
ggsave_nice("study2-shift")
draw.func(ratioFunction, "Ratio", 1)
ggsave_nice("study2-ratio")
draw.func(gammaEffectSize, "Gamma Effect Size", 0, c(0, 0.2, 0.5, 0.8))
ggsave_nice("study2-gamma")

### Study 1
mode1 <- 110
mode2 <- 120
delta <- 10
probs <- seq(0, 1, by = 0.01)
x <- c(rnorm(n, mode1), rnorm(n, mode2))
y <- c(rnorm(n, mode1 - delta), rnorm(n, mode2 + delta))

draw.dist2 <- function() {
  df.dist <- rbind(
    data.frame(name = "x", value = x),
    data.frame(name = "y", value = y)
  )
  ggplot(df.dist, aes(value)) +
    geom_density(bw = "SJ") +
    facet_grid(rows = vars(name), labeller = labeller(.rows = label_value)) +
    ylab("Density") +
    xlab("Value") +
    labs(caption = "Density: KDE (Normal kernel, Sheather & Jones)") +
    scale_x_continuous(breaks = seq(0, 200, by = 5))
}
draw.func2 <- function(func, func.name, base.value, y.breaks = waiver()) {
  exrange <- function(x, f = 0.2) c(min(x) - (max(x) - min(x)) * f, max(x) + (max(x) - min(x)) * f)
  df <- data.frame(probs = probs, value = func(x, y, probs))
  ggplot(df, aes(probs, value)) +
    geom_line() +
    xlab("Quantiles") + ylab(func.name) +
    geom_hline(yintercept = base.value, linetype = "dashed") +
    scale_y_continuous(limits = exrange(c(df$value, base.value)), breaks = y.breaks) +
    scale_x_continuous(breaks = seq(0, 1, by = 0.1))
}

draw.dist2()
ggsave_nice("study1-density")
draw.func2(gammaEffectSize, "Gamma Effect Size", 0, seq(-1, 1, by = 0.2))
ggsave_nice("study1-gamma")
