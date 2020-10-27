library(ggplot2)
library(gridExtra)
library(ggdark)
library(Hmisc)
library(tidyr)
library(svglite)
library(dplyr)
library(tidyr)
library(scales)
library(Rmisc)
library(stringr)

cbPalette <- rep(c("#D55E00", "#56B4E9", "#009E73", "#E69F00", "#0072B2", "#CC79A7"), 5)
ggsave_nice <- function(name, plot = last_plot(), tm = theme_bw(), dark_and_light = TRUE, ext = "svg", dpi = 300) {
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

cbAlpha <- 0.8

which.start <- function(x) {
  for (i in 1:length(x))
    if (x[i] > 1e-9)
      return(i)
  return(length(x))
}

which.end <- function(x) {
  for (i in length(x):1)
    if (x[i] > 1e-9)
      return(i)
  return(1)
}

approx.density.normalized <- function(data) {
  f <- approxfun(density(data, bw = "SJ"))
  return(function(x) {
    res <- f(x)
    res[is.na(res)] <- 0
    return(res)
  })
}

set.seed(42)
cleanup <- function(x) {
  q <- hdquantile(x, c(0.2, 0.8))
  sort(x[x > q[1] & x < q[2]])
}
xa <- cleanup((0.1 + rbeta(100, 1, 10)) * 10)
xa <- xa + runif(length(xa), min = min(xa), max = max(xa))
qa <- hdquantile(xa, probs = c(0.25, 0.71))
xb <- c(xa[xa < qa[1]] - 0.3, xa[xa > qa[1] & xa < qa[2]] - 0.25, xa[xa > qa[2]] + 0.3)

n <- 10000
range <- range(xb)
range <- c(range[1] - (range[2] - range[1]) * 0.25, range[2] + (range[2] - range[1]) * 0.25)
x <- seq(range[1], range[2], length.out = n)

fb <- approx.density.normalized(xb)
db <- fb(x)
hb <- 0
hh <- ha + max(da) * 1.5
label.offset.y = 0.01
label.offset.x = c(-0.07, -0.06, 0, 0, 0, 0.05, 0.05, -0.07, 0.05)

tm <- theme(
  axis.title = element_blank(),
  axis.text = element_blank(),
  axis.ticks = element_blank(),
  panel.border=element_blank(), 
  panel.spacing = unit(0, "cm"),
  panel.grid.major=element_blank(),
  panel.grid.minor=element_blank(),
  plot.margin = margin(0, 0, 0, 0, "cm"),
  legend.position = "none"
)

probs <- seq(0, 1, by = 0.1)
qb <- hdquantile(xb, probs)
qb[1] <- x[which.start(db)]
qb[11] <- x[which.end(db)]
k <- 11

p <- ggplot(data.frame(x = xb), aes(x)) +
  xlim(range[1], range[2]) +
  ylim(0, max(db) * 1.15) +
  geom_density(bw = "SJ") + 
  geom_segment(aes(x = range[1], xend = range[2], y = 0, yend = 0))

df <- data.frame(x = x, ymin = rep(0, n), ymax = db)
percent.label <- paste0(round(100 / (k - 1)), "%")
qdf <- data.frame(
  x = qb,
  xend = qb,
  y = rep(0, k),
  yend = fb(qb)
)
p <- p + geom_segment(data = qdf, mapping = aes(x = x, xend = xend, y = y, yend = yend))

for (i in 1:(k-1)) {
  xx <- seq(qb[i], qb[i + 1], length.out = n)
  xm <- (qb[i] + qb[i + 1]) / 2
  ymin <- rep(0, n)
  ymax <- fb(xx)
  if (i > 1) {
    p <- p +
      annotate(geom = "text",
               x = qb[i] + label.offset.x[i - 1],
               y = fb(qb[i]) + label.offset.y,
               vjust = 0,
               hjust = 0.5,
               size = 3,
               label = paste0("D", (i - 1)))
  }
  if (i == 1 || i == k - 1)
    xm <- (qb[i] + qb[i + 1]) / 2 - (i - k / 2) * 0.05
  p <- p +
    geom_ribbon(
      data = data.frame(x = xx, ymin = ymin, ymax = ymax),
      mapping = aes(x = x, ymin = ymin, ymax = ymax),
      fill = cbPalette[i], alpha = 0.3) +
    annotate(geom = "text", x = xm, y = fb(xm) / 2, label = percent.label, size = 2)
}

show(p)
ggsave_nice("riddle", p + tm)
